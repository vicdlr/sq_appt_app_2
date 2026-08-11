# CareConnect Sync Handoff — for whoever (or whichever Claude session) is doing NAS work

> Written 2026-08-11 from the `SQ_CareConnect` session, mirroring the direction
> `MOBILE_SYNC_HANDOFF.md` (sitting in `D:\Claude\SQ_CareConnect\`) came from — that one was
> written by a concurrent mobile/NAS session for CareConnect's benefit; this one goes the other
> way. Two things: (1) a registration-form/schema change that touches NAS's Organisation
> hierarchy, already fully shipped, no NAS-side code change needed but worth knowing the new
> semantics; (2) a real, still-only-partially-confirmed notification bug where a fix landed on
> CareConnect's side but the actual root cause may need NAS-side verification to fully close out.

## 1. Registration field change: Organisation Name split from Service Provider Name

**Commit `165ef01`, 2026-08-09, already merged to `master` and deployed. No action needed on
NAS's side — this is background for anyone reading NAS provisioning calls and wondering why the
string being passed as `company` changed meaning.**

Registration (`ccregister`, `app/register-clinic/RegistrationForm.tsx`) used to have one "Clinic
Name" field that doubled as both the NAS Organisation name and the individual service provider's
own name. A hospital with multiple departments/doctors had no way to group them under one
Organisation. Now there are two fields:

- **Organisation Name** (new, required) — "Clinic / Organisation Name" for a `CLINIC`
  applicant, "Hospital Name" for `HOSPITAL_DEPT`. Feeds NAS's Organisation hierarchy level.
- **Service Provider Name** (the old `clinicName` field, kept as-is on the DB column to avoid a
  rename across existing rows — read it as "Service Provider Name" everywhere it's displayed) —
  the individual provider's own name, e.g. "Dr. Santos - Cardiology". This is what patients
  search/book against in Explore, shown together with its auto-assigned SP number.

On approval (`app/api/admin/applications/[id]/approve/route.ts` →
`lib/nas-hierarchy.ts`'s `provisionNasHierarchy`), `ensureOrganisation()` is now called with
`organisationName` instead of `clinicName`. Everything below Organisation in the hierarchy
(Department/Group/Unit) is unchanged. So: **multiple `ServiceProviderApplication` rows can now
resolve to the same NAS Organisation** (same `company` value in `/add-organisation`/
`/organisations`), where previously every approval implicitly created its own distinct
Organisation (since `clinicName` was almost always unique per applicant).

`prisma/schema.prisma`'s `ServiceProviderApplication.organisationName` (new column, migration
`20260809070701_add_organisation_name`, backfilled from `clinicName` for pre-existing rows —
each pre-existing row already has its own de-facto single-SP Organisation in NAS, so the
backfill matches what's actually provisioned there) has the full comment explaining this if you
need more detail while reading the schema directly.

CareConnect's own Explore flow, ccadmin's clinic picker, and ccadmin's settings page were all
updated to show `organisationName` alongside the SP name — pure CareConnect-side display/query
changes, nothing NAS needed to change to support this since NAS's Organisation/Department/Group/
Unit hierarchy already supported multiple units per Organisation; CareConnect just wasn't
grouping by it correctly before.

## 2. Notification bug — CareConnect-side fix shipped, NAS-side verification still open

**User report: "I didn't get notifications after booking." Two findings — one wasn't a bug, one
was a real long-standing one, fixed in commit `5b00311` (2026-08-10). Not yet confirmed
end-to-end against a real device/push.**

### Not a bug
The booking's Pending/Processing status was correct — the clinic was actually set to **Manual**
confirmation in ccadmin Settings (the user believed it was Automatic). Under Manual, a booking
legitimately sits pending until staff taps Confirm. No code change for this part.

### Real bug, fixed on CareConnect's side
`app/api/webhook/booking/route.ts`'s "New Appointment"/"New Appointment Request" push (fires on
every booking, any confirm mode — this is CareConnect notifying the clinic's doctor/secretary,
not the patient) used `policy.doctor.fcmToken` — **CareConnect's own local `User.fcmToken`
column, which is never written for a doctor/staff account anywhere in CareConnect's codebase**
(only ever populated for patients, via this same webhook's separate `mdevice` upsert).
`sendServiceNotification`'s `if (!fcmToken) return false` guard (`lib/notify.ts`) silently
no-op'd on every single booking, for every clinic, since this notification was added — no clinic
has ever actually received it.

Fixed by looking up the doctor's **live** fcmToken directly from NAS's shared `mdevice` table
(`lib/shared-db.ts`'s `findVerifiedMdeviceByEmail`, a direct read via `SHARED_DATABASE_URL` —
same Postgres instance NAS's own `POSTGRES_URL`/`connect.js` points at, not an API call to NAS),
keyed on `policy.doctor.email` (CareConnect's own `User.email`, which registration now hints
should be the doctor's **SmartQ App login email**). Same pattern
`app/api/admin/clinic/bookings/route.ts` already used correctly for its own doctor
notifications, so this wasn't a novel approach — just wasn't applied consistently to this one
call site.

The actual send still goes through NAS's `POST /send-notification` (service-key auth, not a
mobile-app user JWT) — `lib/notify.ts`'s `sendServiceNotification`, `NAS_BASE_URL` +
`NAS_SERVICE_KEY` env vars on CareConnect's Render service. That route exists in `app.js` on
`main`/`peer-notification`, guarded by an inline check against
`process.env.CARECONNECT_SERVICE_KEY`. The env var name is intentionally different on each side
(CareConnect: `NAS_SERVICE_KEY`, NAS: `CARECONNECT_SERVICE_KEY`) but they need to hold the *same
secret value* — **verified directly in the Render dashboard 2026-08-11: they match**
(`sq-careconnect`'s `NAS_SERVICE_KEY` and `node_app_server`'s `CARECONNECT_SERVICE_KEY` are both
`d005fba0621b...4c0a1`). Ruled out as the cause of any remaining notification gap.

### Verified 2026-08-11 (ruled out)

1. ~~Confirm `CARECONNECT_SERVICE_KEY` equals `NAS_SERVICE_KEY`~~ — **confirmed matching**, see
   above. Not the cause of any remaining issue.
2. ~~Confirm `FIREBASE_*` env vars are set on node_app_server's live Render deploy~~ — **confirmed
   present** (`FIREBASE_PRIVATE_KEY`, `FIREBASE_PRIVATE_KEY_ID`, etc. all set, not blank) via the
   same Render dashboard check. Values weren't validated against a real Firebase project (just
   confirmed non-empty), but nothing here points to a missing-config failure.
3. ~~Branch drift between `main` and `peer-notification`~~ — **not an issue**: checked Render's
   own deploy log for `node_app_server` directly (not just local git), and commit `0495a7a`
   ("Persist the 'Booking Received' push in the notifications table") is already live, deployed
   2026-08-10 8:20 PM. A local clone of `node_app_server` may still show `peer-notification`
   behind `main` if it hasn't been fetched recently — trust Render's own Events log over a local
   `git log` comparison for "is X actually deployed" questions. (The general branch-drift risk
   this project has seen before is still worth keeping in mind for *future* changes — just isn't
   what's biting this particular bug.)

### Still open — most likely remaining suspects

4. **The doctor/secretary must have actually used the SmartQ App with push permission granted,
   under the exact email CareConnect has on file as `policy.doctor.email`.** The fix can only
   find an fcmToken that exists — `findVerifiedMdeviceByEmail` requires a `mdevice` row with
   `registered >= 2` (NAS's own "fully verified" gate) and a non-null `fcmtoken`. If a given
   clinic's doctor manages everything through ccadmin in a browser and has never opened the
   mobile app on that login email, there is nothing to find regardless of how correct the code
   is — this would look identical to the original bug from the outside. Worth checking `mdevice`
   directly for a specific doctor's email if a report of "still no notification" comes in after
   this fix is confirmed deployed.
5. **Not yet tested end-to-end against a real device** — CareConnect's own `pending_work.md`
   flags this explicitly: book as a patient against a Manual-confirm clinic, confirm the doctor's
   own device actually receives the "New Appointment Request" push. Structurally sound (mirrors
   an already-working pattern exactly) but only verified by reading code so far.

## 3. Where to look for more

- `D:\Claude\SQ_CareConnect\DEVLOG.md` / `pending_work.md` — 2026-08-09 entry (Organisation
  split) and 2026-08-10 entry (notification fix), full narrative.
- `app/api/webhook/booking/route.ts`, `lib/notify.ts`, `lib/shared-db.ts` in `SQ_CareConnect` —
  the actual CareConnect-side code for both changes.
- `C:\Users\vic\AndroidStudioProjects\node_app_server`'s `app.js` — the `/send-notification`
  service-key route and the generic mobile-app `/send-notification` (two separate route
  registrations at different points in the file; the service-key one is registered first and
  falls through via `next()` for any caller without a valid key, so the original mobile-app route
  further down still works unchanged for real app users).
