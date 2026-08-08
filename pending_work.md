# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Open / needs attention (as of 2026-08-08 — session suspended mid-deploy)

> Full narrative in `DEVLOG.md`'s 2026-08-08 entry (see §9 for exactly where this was paused).
> All Flutter/CareConnect/node_app_server redesign work is committed and pushed. The one thing
> genuinely in-flight is deploying `node_app_server` to production — resume there first.

- **Resume point: finish merging `node_app_server`'s `feature/redesign-2026` into `main` and
  deploy.** Both deploy prerequisites are confirmed done (DB migration already run against
  production; `BADGE_TOKEN_KEY`/`NAS_CC_SERVICE_KEY`/`CARECONNECT_BASE_URL` already set in
  Render). The merge has **one real conflict**, isolated to the `/service-options` route in
  `app.js` — `main` independently has an older `app.get(...)`/`req.query` version of this route
  (predates the booking-flow simplification), while `feature/redesign-2026` has the current
  `app.post(...)`/`req.body` version the redesigned Flutter client actually calls. **Resolution:
  take the feature branch's version of the route entirely** (POST, `req.body`, the
  no-filter-when-empty department/groupname logic), but **keep `main`'s independent addition**
  of the global `unhandledRejection`/`uncaughtException`/pool `error` crash-prevention handlers
  that sit immediately after this route in `main` — they don't conflict with anything else and
  are worth keeping. To reproduce the conflict: `git merge feature/redesign-2026` from a branch
  based on `origin/main` — do this on a disposable branch first, not `main` directly, in case
  there's more to reconcile than what was found this session. After resolving: merge to `main`,
  push, confirm Render redeploys, then re-test the badge QR (Home dashboard + full-screen view)
  and a Data-Capture booking's instructions/photo-hints on-device — both were confirmed blocked
  purely on this deploy gap, not on any remaining code bug.

- **`main` and `feature/redesign-2026` have drifted more than expected** — `main` picked up 5
  commits since the branches diverged (`3bf1bc0`) that also exist, independently reimplemented,
  in the feature branch's own history (`added customerid in /create-booking`, `servoption API
  endpoint created`, `response format changed`, `added Unit...`, `test`). Only one of those
  turned out to actually conflict (`/service-options`, above) — the trial merge found nothing
  else — but worth being alert to during the real merge in case `git`'s line-level diffing missed
  a semantic clash that didn't show up as a textual conflict.

- **Commit `node_app_server`'s untracked `_tmp_poll_cc2.sh`** (or delete it) — leftover from
  earlier in the session, never reviewed, not part of this effort's actual work.

- **Revert `android/app/build.gradle`'s temporary version bump** (`versionCode 22` /
  `versionName "21.1.0"` → real `21` / `"21.0.1"`) before any real release build. Left in place
  deliberately for now since reverting would re-trigger the force-update dialog and block
  on-device testing. (Committed separately as `b05cbfe` specifically so this is easy to spot and
  revert on its own.)

- **Possible follow-up, not urgent:** the `/service-options` query still does `LIMIT 1` with no
  `ORDER BY` — if a unit ever has multiple `servoption` rows differing only by department (now
  unfiltered), which one wins is non-deterministic. Not observed as an actual problem yet; worth
  an `ORDER BY` or a data cleanup pass if it comes up.

- **Remaining manual verification** (most of this hasn't been walked through on-device yet, only
  what's noted as tested in the 2026-08-08 DEVLOG entry — and the badge/Data-Capture items below
  specifically need the deploy above to happen first):
  - Badge screen (Home dashboard preview + full-screen view) actually renders a live QR once
    `/badge-token` is deployed; decodes to opaque base64, not readable customerId/token text.
  - A Data-Capture booking's instructions/photo-hints actually load once `/service-options` is
    deployed.
  - My Bookings' new status-aware cards (Declined/Confirmed/Pending/Completed) and the "View
    Queue" button's CareConnect WebView link-out.
  - Service Provider Mode's quick-link cards (View Queues / Now Serving / Queue History) opening
    the right CareConnect page without CareConnect's own nav chrome showing.
  - Settings' new bottom-sheet pickers (Location/Region, Notifications, Language) and dark
    mode/font size regression check after the rewrite.
  - SignIn/SignUp final visual pass against their mockups.

- **iOS testing** — see `IOS_HANDOFF.md` in this same repo for the full picture (repo/branch
  locations, what's already resolved re: signing, why iOS doesn't need an Android-style
  force-update workaround). Not started yet.

- **From the two older, still-unmerged branches in the *other* checkout**
  (`C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`'s pre-redesign branches — check whether
  their content already landed inside `feature/redesign-2026` before assuming they're still
  needed separately):
  - `chore/archive-stale-keystores` — low urgency, gitignored files only, can merge/clean up
    whenever.
  - `fix/notification-channel-and-tap-handling` — channel pre-creation + My Bookings sort order.
    Worth double-checking whether the sort-order change is still present after the
    `request_new_booking.dart`/`home_provider.dart` rewrites, since it touched the same provider.
