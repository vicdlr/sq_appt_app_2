# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Open / needs attention (as of 2026-09-03, continued)

Full narrative for everything below lives in `DEVLOG.md`'s dated entries — this is just the
still-open punch list, trimmed of everything already resolved/superseded/shipped.

- **iOS build 1.0.7 (11) resubmitted to App Store review with current screenshots, status
  "Waiting for Review."** Original submission (2026-09-03) used stale `1.0.4`-carryover
  screenshots, was pulled ("remove this version from review"), then reused 3 already-existing
  current-UI screenshots from the 2026-08-24 CareConnect-flyer session
  (`sq_appt_app_2/screenshots/01_current_state.png`/`04_organisation.png`/`08_after_start_time.png`
  — Home, Book a Service, Request New Booking date/time) instead of a fresh emulator session,
  resized to Apple's required 1284×2778px via PowerShell/System.Drawing. **First resize attempt
  (default 32bpp ARGB) uploaded but failed Apple's server-side asset validation** (red error icons
  persisted after reload) — root cause not confirmed, but re-exporting as flat 24bpp RGB (no alpha
  channel) and re-uploading via the correct file-input element resolved it; also needed a longer
  wait after upload before Save (rushing straight to "Add for Review" after Save produced "uploads
  in progress" errors even though Save appeared to succeed). Resubmitted 2026-09-03; Apple's
  estimate is up to 48 hours, email notification on completion.
- **⚠️ iOS age rating: calculated 9+ but a manual override still forces 18+.** Found while
  answering Apple's newly-required Age Ratings questionnaire — deliberately left the override
  untouched (wasn't asked to change it, might have an undocumented reason). **Worth asking the
  user whether the 18+ override should be lowered** now that the underlying answers say 9+.
- **Android build 64 (48.0.16) approved and published to Production** — cleared Google's review
  same-day (much faster than the 7-day estimate), confirmed via Publishing overview showing
  "Changes ready to publish" → clicked "Publish 1 change" (user confirmed first) → "Last published
  on September 3, 2026," no pending changes. Play Store's screenshots (Store listing, separate
  from the release/promotion flow entirely) were checked and already current — no stale-asset
  issue like iOS had, since Play screenshots aren't attached per-version.
- **`mdevice.id=133` city bug confirmed but not fixed** — `vicdlr@gmail.com`'s account still has
  `city='Cebu ph'` in production (breaks New Booking's Industry/Organisation/Unit filtering). The
  UPDATE itself was blocked by the auto-mode classifier (production data mutation); user has the
  exact SQL (`UPDATE mdevice SET city = 'Metro Manila' WHERE id = 133;`) to run via Database
  Workbench. **Not yet confirmed run** — re-verify once done.
- **Resolved (2026-09-01): Android 64 (48.0.16) approved and live on Open Testing** ("Available to
  unlimited testers," released Sep 1 11:10 AM — auto-published, no manual publish step needed this
  time). Ships the email-trim fix (`ec433f0`).
- **iOS: Mac handoff sent for `1.0.7+11`** (pull, bump, build/archive/upload, add to External
  Testers) — ships the same email-trim fix, shared Dart code. **Not yet confirmed acted on.**
- **⚠️ Email-trim fix (`ec433f0`) still not confirmed live on an actual device/emulator tap-through.**
  Logic verified directly (regex test) and `flutter analyze` clean, but the emulator session
  couldn't render past a black screen to actually tap through Sign Up — same known Sign-In
  rendering quirk as before, this time compounded by the emulator having no network access at all.
  **Do a real click-through (enter an email with a leading space, confirm it now submits) once a
  working device/emulator is available.**
- **iOS External Testers: 4 of 7 testers never accepted their invite** (`charitodlr@icloud.com`,
  `wmajsa2@icloud.com`, `joeapp6942@gmail.com`, `joeydlr@gmail.com`) — reinvited 2026-08-31, not
  yet confirmed whether any accepted. `haliverp@gmail.com` accepted but has zero sessions (never
  opened the app) — no action taken, a reinvite doesn't fix that.
- **"More" tab: tile tap-through not yet confirmed on a real account**, and the provider-account
  heading variant ("Register another Service Provider") is still only confirmed via an earlier
  local dev-DB test, not live on a real device.
- **ccadmin "Register Another Service" link — not yet visually confirmed live** on
  `ccregister.smartqsys.com`'s Settings page (added `SQ_CareConnect@bd56765`).
- **My Active Queues → "View Status" not verified end-to-end with a real account.** Only tested
  with a fake-JWT fixture (confirmed UI/wiring, couldn't authenticate) — the real path (active
  booking → View Status → live `QueueStatusPanel` with real queue data) hasn't been clicked
  through.
- **Data bug, still not fixed**: real account `vicdlr@gmail.com` (id=133) has `city="Cebu ph"` in
  `mdevice`, should be `"Metro Manila"` — silently breaks New Booking's Industry/Organisation/Unit
  filtering (`home_provider.dart` filters by exact city match; "Cebu ph" has no Healthcare
  industry). Needs `UPDATE mdevice SET city='Metro Manila' WHERE id=133` once confirmed.
- **Sign In screen renders solid black on the `API36_EdgeToEdge` emulator with Impeller enabled**
  (Sign Up renders fine) — workaround exists (`flutter run --no-enable-impeller`), not
  root-caused.
- **Closed Testing - Alpha still stuck on old build 52 (48.0.4)** — flagged repeatedly across many
  sessions as deliberately untouched; still sitting there as of the 2026-08-31 tester audit.
- **Service Provider Mode SSO bridge — committed but never pushed, status unknown.** Client
  `3b653eb` (`sq_appt_app_2`'s `fix/android-15-compliance`, "Mint an SSO token before opening
  ccadmin from Service Provider Mode") and backend `f50edcc` (`node_app_server`'s `main`, "Add
  /careconnect/service-provider-link for mobile SSO into ccadmin"). Backend endpoint doesn't exist
  in production until pushed to both `main` and `peer-notification`. No decision from the user
  since — check `git log origin/fix/android-15-compliance..HEAD` before assuming this is still
  true.
- **Android notification channel fix unmerged**: `sq_appt_app_2` branch
  `fix/notification-channel-and-tap-handling` (commit `4edf223`) fixes pushes being silently muted
  (app never pre-creates the `booking_updates` channel). Not yet merged into
  `fix/android-15-compliance` — check for sort-order overlap with `my_booking.dart`'s
  sort-by-`id`-descending (same branch also touched My Bookings sort order) before merging.
- **Edge-to-edge visual audit still not resumed** (blocked since 2026-08-12 on an emulator
  keyboard quirk, itself never root-caused). 10 of 15 `Scaffold` screens have no `SafeArea`:
  `add_booking.dart`, `bottom_nav_bar.dart`, `contact_us.dart`, `get_ticket.dart`,
  `home_dashboard.dart`, `my_booking.dart`, `notification.dart`, `request_new_booking.dart`,
  `service_provider_mode.dart`, `WebView.dart`.
- **Remaining manual verification, never walked through on-device**: My Bookings' status-aware
  cards' "View Queue" button from My Bookings itself; Service Provider Mode's quick-link cards
  (View Queues/Now Serving/Queue History) opening CareConnect without its own nav chrome; Settings'
  bottom-sheet pickers (Location/Region, Notifications, Language) and dark mode/font size
  regression.
- **Whether the `com.pairip.licensecheck` wrapper baked into the shipped Android APK is
  intentional** (anti-piracy, added deliberately by the original contractor's build pipeline) is
  unconfirmed — absent from `sq_appt_app_2`'s source entirely. Only came up because it's part of
  why CPH1909's ColorOS install loop self-kills; not urgent, worth asking the user if it resurfaces.
- **Cleanup, low urgency**: `chore/archive-stale-keystores` branch in `sq_appt_app_2` (gitignored
  files only); throwaway diagnostic scripts in `node_app_server/` (`_test_push_vicdlr.js` and
  ~9 others, all untracked); `node_app_server`'s `/service-options` query does `LIMIT 1` with no
  `ORDER BY` (non-deterministic if a unit ever has multiple `servoption` rows — not observed as an
  actual problem yet).

## Standing gotchas (not tasks — context for future sessions)

- **`node_app_server`'s Render service deploys from branch `peer-notification`, not `main`** —
  `main`/`feature/redesign-2026` are kept in sync manually. Every backend change needs pushing to
  both, or Render won't pick it up.
- **Two similarly-named but functionally distinct secrets** across `node_app_server`/
  `SQ_CareConnect` — don't conflate: `NAS_SERVICE_KEY`/`CARECONNECT_SERVICE_KEY` (header
  `x-service-key`, used by `lib/notify.ts`) vs. `NAS_CC_SERVICE_KEY` (both sides, header
  `x-nas-service-key`, used by queue-access/manage-bookings-link bridges).
- **`mdevice.email`, `.date_registered`, `.auth_token` are fixed-length Postgres `CHAR` columns** —
  values come back space-padded; `auth_token` must be `.trim()`'d before `jwt.verify()`.
- **CPH1909 (physical Oppo test device) has two known, unfixable-from-app-side hardware/OS
  limitations** — treat as permanent constraints of this one unit, not bugs to keep chasing:
  WebView cold-loads take ~1 min (RELRO/`address space not reserved`, Android/Linux-only, no iOS
  equivalent); ColorOS silently redirects all Play Store install paths for this app to Oppo
  Market's stale build + an embedded anti-piracy check that self-kills on a non-Play-licensed
  install (2026-08-31, full trace in `DEVLOG.md`).
