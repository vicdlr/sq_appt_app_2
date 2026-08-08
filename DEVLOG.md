# sq_appt_app — Development Log

---

### 2026-08-08 — Full mockup-driven redesign built across all three repos; badge security fixed; live device-testing round found and fixed real bugs

**Context:** continuation of 2026-08-07's suspended session. The five enhancement items from that
session (plus the user's own 7 approved UI mockups in `D:\Claude\sq_appt_app\*.JPEG`) turned into
a much larger effort spanning `sq_appt_app_2`, `node_app_server`, and `SQ_CareConnect`, all on a
new `feature/redesign-2026` branch in each repo. Two architectural decisions came out of scoping
this: (1) the QR "SmartQ Badge" needed a real security fix, not just a restyle — it was leaking the
raw session `auth_token` and `fcmToken` in plaintext; (2) queue monitoring/handling should not be
rebuilt natively in Flutter — it links out to CareConnect via WebView instead, one implementation
reused by any channel.

**1. Badge security fix — shipped.** `node_app_server`: new `badgeToken.js` (AES-256-GCM,
`BADGE_TOKEN_KEY` env var), `GET /badge-token` returns an opaque token containing only
`customerId`, no expiry (it's a long-lived gate-pass identity, not a session token). Flutter caches
it via `SharedPref` so the badge still renders offline. Committed on `node_app_server`'s
`feature/redesign-2026` (`acb604e`).

**2. CareConnect queue-access bridge — shipped, merged to `master`.** New `PatientQueueAccessToken`
Prisma model + mint/consume routes (same pattern as CareConnect's existing `ImpersonationToken`),
gated by a new `x-nas-service-key` header (`NAS_CC_SERVICE_KEY`). `node_app_server` gained
`booking.handled_by` tracking and `POST /bookings/:bookingId/queue-access` as the actual trigger
point, so Flutter never talks to CareConnect directly. CareConnect's own redesign (ccadmin
Terminal, ccuser queue panel restyle against reference mockups, embedded-mode nav/padding hiding
via a `sessionStorage` flag survives Next.js client-side nav) is done and **already merged to
`master`** — confirmed via `git log` (`c9b912f`, `89dc77b`).

**3. Service Provider Mode — shipped.** `mdevice.is_service_provider` column + service-key-gated
flip route, set automatically when a clinic application is approved
(`setMobileServiceProviderFlag`). Flutter surfaces it for free via the existing `GET /profile`
payload; every Service-Provider-Mode UI element is fully hidden (not disabled) when the flag is
false.

**4. Flutter redesign against all 7 mockups — mostly built, partially committed.** SignIn/SignUp,
Home dashboard, Drawer, Get Ticket, Contact Us are committed on `sq_appt_app_2`'s
`feature/redesign-2026` (see `git log`: `5d01219`, `136b7fb`, `2c51b1a`, `ac3aa6b`, `82ad41f`, and
earlier). **The most recent round of work is implemented but not yet committed** (dirty working
tree) — this includes:
- Bottom nav cut from 5 tabs to 4 (Home / My Queues / Services / More) — "My Badge" removed
  per user request since it's already reachable from Home.
- Drawer reorganized — Settings/Logout moved out into the Home AppBar's profile `PopupMenuButton`.
- Settings screen fully rewritten to match `Settings.JPEG` (sectioned cards, bottom-sheet pickers
  replacing `CustomDropDown`).
- Home dashboard: Quick Actions grid, SmartQ Badge preview card, Service-Provider panel /
  Register-a-Service card (copy iterated live to "Register your Service/Clinic to CareConnect™ and
  manage your own queue with SmartQ", proper `WidgetSpan` superscript for the trademark).
- Booking flow (`request_new_booking.dart`) collapsed from 5 dropdown steps
  (Industry→Company→Department→Group→Unit) to 3 (Industry→Organisation→Service Provider), with a
  horizontal-slider industry picker, searchable organisation list, and a connector-line step
  indicator. Provider selection no longer needs a tick + Continue button — tapping a provider
  immediately proceeds.
- `home_provider.dart`: `setCompaniesList` made `async`; when an organisation resolves to exactly
  one provider, the app now auto-selects it and skips the "Service Provider" step entirely,
  jumping straight to the date/time (Appointment) or Data Capture page — most orgs in the real
  data are 1:1 with a provider, so this removes a mostly-pointless tap.

**5. Live device-testing round (fresh Android emulator, cold `flutter run` restart) — found and
fixed two real bugs:**
- **Data Capture form silently missing instructions/photo hints.** Root cause: the simplified
  3-step flow dropped the old Department/Group selection, but `node_app_server`'s
  `POST /service-options` required `department`/`groupname` keys to be *present* in the request
  body (400 `Missing required parameter: department` otherwise) and then filtered on
  `department = ''` when empty — an exact-match filter, not "don't care." Real seeded
  `servoption` rows have non-blank department values, so even after sending the keys the query
  still 404'd (`No service options found for the given filters.`). Fixed on both sides: Flutter
  now always sends `department`/`groupname` as empty strings; `app.js`'s `/service-options`
  handler now skips the filter entirely when they're empty instead of forcing a blank match.
  **Fixed in code (`node_app_server` `app.js`, uncommitted) but not deployed** — the emulator/app
  talks straight to production (`https://node-app-server.onrender.com`, deployed from `main`), and
  this fix lives on `feature/redesign-2026`, so Data Capture instructions are still broken live
  until this ships. Flagged to user; deploy decision pending (see `pending_work.md`).
- **"Steps stay green after a booking" — investigated, turned out not to be a real bug.** Ran a
  full real Appointment booking end-to-end (NKTI → chair 1 → Aug 21 9–10 AM → submitted
  successfully) on a freshly-restarted app process and confirmed the step indicator correctly
  resets to step 1 afterward. The behavior the user saw earlier was stale in-memory
  `HomeProvider` state surviving across hot reloads on a `flutter run` process that had been
  running since much earlier in the session — a full cold restart resolved it. No code change was
  needed for this one.
- Also verified live: organisations with multiple providers (NKTI, 3 providers) correctly still
  show the Service Provider step; single-provider orgs (SLMC Pharmacy) correctly auto-skip it.

**6. Known temporary hack still in place — must revert before any real build.**
`android/app/build.gradle` has `versionCode 22` / `versionName "21.1.0"` hardcoded (real values are
`21` / `"21.0.1"`) to bypass the server's hardcoded `minimum_version_android: "21.0.3"` force-update
check during testing. **Not reverted yet** — reverting now would re-block on-device testing.

**Files touched, by repo:**
- `node_app_server` (`feature/redesign-2026`): committed through `63a3118`
  (badge token, queue-access mint route, `handled_by`/`is_service_provider` columns, Data Capture
  webhook fields, Privacy/Terms/About restyle). `app.js`'s `/service-options` department/groupname
  filter fix is **uncommitted**.
- `SQ_CareConnect` (`master`): fully merged and committed, nothing outstanding from this effort.
- `sq_appt_app_2` (`feature/redesign-2026`): committed through `5d01219`; the bottom-nav/drawer/
  settings/home-dashboard/booking-flow work described in §4–5 above is implemented but
  **uncommitted** (dirty working tree — `android/app/build.gradle`, `lib/provider/home_provider.dart`,
  `lib/provider/theme_provider.dart`, `lib/view/auth/SignIn.dart`, `lib/view/auth/SignUp.dart`,
  `lib/view/home/app_drawer.dart`, `lib/view/home/bottom_nav_bar.dart`,
  `lib/view/home/contact_us.dart`, `lib/view/home/home_dashboard.dart`,
  `lib/view/home/request_new_booking.dart`, `lib/view/home/settings.dart`, `pubspec.yaml`, plus new
  untracked `assets/` and `lib/constant/app_colors.dart`).

---

### 2026-08-07 — Publish-setup verification (both platforms confirmed), notification/booking fixes started, badge-security redesign scoped

**Context:** first real session in this new VS Code workspace (`D:\Claude\sq_appt_app`, branch
`mobile-redesign`, cloned fresh off `improved`). See `CLAUDE_BRIEFING.md` for the full
locations/history writeup — this entry covers what changed since that briefing was written.

**1. Publish-setup checklist — fully resolved, both platforms.**
- **Android**: confirmed via Play Console (`Vic10809` account, a *different* Google account than
  App Store Connect's `vic@smartqsys.com` — worth remembering) that `keystore.jks`'s SHA-1/SHA-256
  exactly match the registered upload key. The other two keystores (`.keystore`, `releasekey.jks`)
  are confirmed stale.
- **iOS**: initial check found *zero* certificates and no valid distribution profile on the Apple
  Developer account (`FN232J5K2B`) — a hard blocker. User generated a CSR on their Mac same day
  and created a new Apple Distribution certificate + App Store distribution provisioning profile
  for `com.smartqsys.sqapptapp`, both confirmed present and valid until 2027/08/07.
- Also found and documented (not acted on, per user): App Store Connect's app "Name" field is
  literally `SQ Appt App` (user decided to keep it for now), and the contractor (Ashish Mittal)
  still has full-scope App Store Connect access including a login as recent as 2026-07-23 (user
  decided not to revoke).
- Committed (`86ddced`, `3f51e80`) and pushed to `origin/mobile-redesign`.

**2. Stale Android keystores archived.** In the *other* checkout
(`C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`, which stays on branch `improved` as the
known-good fallback — new work branches off it instead of touching it directly, per user
preference): new branch `chore/archive-stale-keystores`, moved `.keystore` and `releasekey.jks`
into `android/app/archived_unused_keystores/`. Nothing to commit there (both files are
gitignored, confirmed `android/.gitignore` already protects `key.properties`/`*.jks`/`*.keystore`
— that part of the original briefing was already stale/covered).

**3. Notification + booking-list fixes — implemented, NOT yet committed.** New branch
`fix/notification-channel-and-tap-handling` in `sq_appt_app_2` (off the same base as the keystore
branch). Addresses two items from `SQ_CareConnect`'s DEVLOG (2026-08-01 entry — push-notification
sound bug) plus one new one:
- **Channel pre-creation** (`main.dart`, `notification/notification.dart`): the
  `booking_updates` Android notification channel is now created at app startup with a fixed ID
  (`NotificationServices.bookingUpdatesChannelId`) matching `node_app_server`'s
  `FCM_ANDROID_CHANNEL_ID`, instead of being derived from the first incoming message's
  `channelId` (which is what broke sound originally — see CareConnect's DEVLOG for the full root
  cause). `showNotification` also now uses the fixed channel id directly rather than trusting the
  message.
- **CC-admin push tap-handling**: confirmed already present (a pre-existing uncommitted edit from
  before this session) — tapping a `service_provider_application` push opens SAM's `/cc-admin`
  page. Left as-is.
- **My Bookings sort order**: `home_provider.dart`'s `getAllBooking` had a *disabled* sort
  (`// bookingList.sort(...)`, commented out because the original used unsafe `!.compareTo` on a
  nullable `bookingDate`). Re-enabled with a null-safe version, descending (most recent first).
- `flutter analyze` clean on all three touched files (only pre-existing, unrelated style
  warnings). Not built/run on a device this session.

**4. Enhancement requests — discussed, mostly not yet implemented.** User raised five items:
1. **"App looks too plain"** — too vague to act on; deferred pending specifics/examples.
2. **Badge label cutoff on small screens** (`home_page.dart:96`, AppBar title "SmartQ Badge") —
   confirmed real (fixed-size `Text`, no shrink/wrap handling). Not yet fixed.
3. **QR badge security — real, serious issue, found and design agreed, not yet implemented.**
   The QR (`home_page.dart:164-165`) currently encodes `customerId + fcmToken + "sqs" +
   auth_token` as raw plaintext, no expiry, no signature. `auth_token` exposure = full session
   hijack risk for anyone who scans/photographs it; `fcmToken` exposure = anyone holding it can
   push arbitrary notifications straight to that device via Firebase, bypassing the backend
   entirely. Checked `SQ_WebKiosk` for an existing consumer/parser of this QR format — found
   none (its only QR usage is outbound feedback/info codes, not scanning customer badges), so no
   compatibility constraint from that side. **Agreed design**: `node_app_server` mints an opaque,
   encrypted (AES-GCM, server-only key) token containing just `customerId`, via a new endpoint
   (e.g. `GET /badge-token`); the app fetches and caches it locally (so the badge still displays
   offline) and displays *that* in the QR instead of raw credentials. No expiry — it's meant as a
   long-lived "gate pass" identity credential, not a session token, since (per the user) it's not
   yet known when/how a client will actually use it. Whoever eventually scans it (WebKiosk or
   otherwise) needs the matching decryption key distributed separately — out of scope until that
   consumer actually exists. **Not started** — needs `node_app_server` + Flutter changes.
4. **Booking request flow simplification** — confirmed current flow is Industry → Organisation →
   Department → Group → Unit (`request_new_booking.dart`), all dropdowns, Department/Group
   required before submit. User wants it cut down to Industry → Organisation → Unit only, as a
   button-based drill-down instead of dropdowns. **Not started.**
5. **My Bookings tap → clinic queue status — not a simple link, needs new backend work.** Found
   CareConnect's actual patient queue page (`SQ_CareConnect/app/bookings/page.tsx` +
   `/api/bookings/[id]/queue`), but it requires a logged-in CareConnect **ccuser web session**
   (cookie auth) and checks `booking.patientUserId === current.user.id`. The mobile app's
   identity lives entirely in `node_app_server` (customerId/auth_token) — a completely separate
   account system from CareConnect's ccuser accounts, so a naive deep-link won't work.
   **Direction floated but not yet confirmed with user**: a new token-based, single-booking
   queue view on the CareConnect side that doesn't require ccuser login (same pattern as the
   existing ticket-scan WebView already used elsewhere in the mobile app). **Not started.**

**Session suspended here** at the user's request, mid-way through the enhancement round, to
create this DEVLOG entry and `pending_work.md` before continuing later. See `pending_work.md` for
the concrete resume checklist.

**Files touched this session:**
- `D:\Claude\sq_appt_app\CLAUDE_BRIEFING.md` — committed, pushed.
- `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` — two new local branches
  (`chore/archive-stale-keystores`, `fix/notification-channel-and-tap-handling`), nothing
  committed on either yet. `improved` itself untouched.
- Read-only research in `SQ_CareConnect` and `SQ_WebKiosk` — no changes.
