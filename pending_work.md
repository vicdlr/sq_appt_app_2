# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Open / needs attention (as of 2026-08-08)

> Full narrative in `DEVLOG.md`'s 2026-08-08 entry. The mockup-driven redesign, badge security
> fix, CareConnect queue-access bridge, and Service Provider Mode are all built. CareConnect's
> side is fully merged to `master`. What's below is what's actually still open.

- **Deploy decision needed (blocks live functionality):** `node_app_server`'s
  `/service-options` fix (department/groupname now treated as "no filter" when empty, instead of
  requiring an exact blank match) lives on `feature/redesign-2026`, uncommitted. Production
  (`https://node-app-server.onrender.com`) deploys from `main` — until this ships, every
  Data-Capture-type booking on the live app fails to load its instructions/photo-capture hints
  (404 "No service options found"). Ask the user whether to deploy this fix alone or bundle it
  with the rest of the feature branch.

- **Commit the uncommitted `sq_appt_app_2` working tree** (all on `feature/redesign-2026`):
  bottom nav (5→4 tabs), drawer reorg, Settings rewrite, Home dashboard, booking-flow redesign
  (3-step + auto-skip-single-provider), plus new `lib/constant/app_colors.dart` and `assets/`.
  Currently dirty/uncommitted — see DEVLOG for the full file list.

- **Commit `node_app_server`'s `app.js`** (`/service-options` filter fix) once the deploy
  question above is resolved. Also an untracked stray file `_tmp_poll_cc2.sh` in that repo from
  earlier in the session — review and likely delete, not touched this round.

- **Revert `android/app/build.gradle`'s temporary version bump** (`versionCode 22` /
  `versionName "21.1.0"` → real `21` / `"21.0.1"`) before any real release build. Left in place
  deliberately for now since reverting would re-trigger the force-update dialog and block
  on-device testing.

- **Possible follow-up, not urgent:** the `/service-options` query still does `LIMIT 1` with no
  `ORDER BY` — if a unit ever has multiple `servoption` rows differing only by department (now
  unfiltered), which one wins is non-deterministic. Not observed as an actual problem yet; worth
  an `ORDER BY` or a data cleanup pass if it comes up.

- **Remaining manual verification** (per the original plan's Verification section — most of this
  hasn't been walked through on-device yet this round, only what's noted as tested in the
  2026-08-08 DEVLOG entry):
  - My Bookings' new status-aware cards (Declined/Confirmed/Pending/Completed) and the "View
    Queue" button's CareConnect WebView link-out.
  - Badge screen with the new encrypted `customerId`-only token (renders from cache offline,
    decodes to opaque base64 rather than readable text).
  - Service Provider Mode's quick-link cards (View Queues / Now Serving / Queue History) opening
    the right CareConnect page without CareConnect's own nav chrome showing.
  - Settings' new bottom-sheet pickers (Location/Region, Notifications, Language) and dark
    mode/font size regression check after the rewrite.
  - SignIn/SignUp final visual pass against their mockups.

- **From the two older, still-unmerged branches in the *other* checkout**
  (`C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`'s pre-redesign branches — check whether
  their content already landed inside `feature/redesign-2026` before assuming they're still
  needed separately):
  - `chore/archive-stale-keystores` — low urgency, gitignored files only, can merge/clean up
    whenever.
  - `fix/notification-channel-and-tap-handling` — channel pre-creation + My Bookings sort order.
    Worth double-checking whether the sort-order change is still present after the
    `request_new_booking.dart`/`home_provider.dart` rewrites, since it touched the same provider.
