# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Open / needs attention (as of 2026-09-15)

Full narrative for everything below lives in `DEVLOG.md`'s dated entries — this is just the
still-open punch list, trimmed of everything already resolved/superseded/shipped.

- **Android versionCode 72 (48.0.24) submitted to Production 2026-09-15, sent for Google review,
  not yet confirmed live** — promoted from Open Testing (see DEVLOG.md's 2026-09-15 entry for the
  full sequence). Needs a follow-up check once Google's review clears, same pattern as build 64.
  Still not click-tested on a device.
- **iOS handoff drafted and sent to a Mac Claude session** (`IOS_HANDOFF.md`'s new top section:
  bump `pubspec.yaml` to `1.0.8+8`, archive, submit to TestFlight External Testing) — outcome not
  yet confirmed back.
  Carries notification-sound settings, WebView caching re-enable, and the minSdk-24 fix. Check
  Publishing overview for the outcome.
- **Real constraint for any future build of this project**: `C:\flutter_stable_2026` is required
  (the other Flutter SDK on this machine can't resolve `device_info_plus ^11.5.0`'s Dart
  constraint), and that SDK hard-floors `minSdkVersion` at 24 — no way to get a lower minSdk with
  the current dependency set short of downgrading `device_info_plus`. `android/app/build.gradle`
  now uses `flutter.minSdkVersion` directly rather than a stale literal, so it'll track whichever
  floor the SDK in use actually enforces.
- **iOS not touched this round** — `IOS_HANDOFF.md`'s 2026-09-11 section has the instructions
  (bump `pubspec.yaml` to `1.0.8+7`, what's Android-only vs. cross-platform). Needs an actual
  Mac/Xcode session; nothing buildable from Windows.
- **None of today's fixes (notification sound, caching re-enable) have been click-tested on a
  real device** — same standing gap as the 2026-09-10 round below.
- **iOS age rating: calculated 9+ but a manual override still forces 18+.** Still unresolved —
  worth asking the user whether to lower it now that the underlying answers say 9+.
- **Android 66→70's still-open verification items, never confirmed on a real device**: permission
  prompt on a fresh login (not just fresh sign-up), tap-to-open for a `staff_reply` push,
  tap-to-open for patient-facing booking-status pushes (`booking_confirmed`/`booking_checked_in`/
  `booking_processing`/`your_turn`).
- **Not yet decided**: is CPH1909 (physical Oppo test device) still worth using to verify Play
  Store assets at all, given the store-hijacking makes anything it shows unreliable for that
  purpose — or should future "stale on CPH1909" reports just be treated as expected noise?
- **Minor cleanup for next store-listing update, not urgent**: two visually-similar "Request new
  booking" screenshots appear back-to-back in the Play Store's 8-image sequence — confirm whether
  intentional or an accidental duplicate, dedupe if so.
- **iOS External Testers: 4 of 7 testers never accepted their invite** (`charitodlr@icloud.com`,
  `wmajsa2@icloud.com`, `joeapp6942@gmail.com`, `joeydlr@gmail.com`) — reinvited 2026-08-31, not
  yet confirmed whether any accepted. `haliverp@gmail.com` accepted but has zero sessions — no
  action taken, a reinvite doesn't fix that.
- **"More" tab: tile tap-through not yet confirmed on a real account**, and the provider-account
  heading variant ("Register another Service Provider") is still only confirmed via an earlier
  local dev-DB test, not live on a real device.
- **ccadmin "Register Another Service" link — not yet visually confirmed live** on
  `ccregister.smartqsys.com`'s Settings page.
- **My Active Queues → "View Status" not verified end-to-end with a real account.** Only tested
  with a fake-JWT fixture (confirmed UI/wiring, couldn't authenticate) — the real path hasn't been
  clicked through.
- **Sign In screen renders solid black on the `API36_EdgeToEdge` emulator with Impeller enabled**
  (Sign Up renders fine) — workaround exists (`flutter run --no-enable-impeller`), not
  root-caused.
- **Closed Testing - Alpha still stuck on old build 52 (48.0.4)** — flagged repeatedly across many
  sessions as deliberately untouched.
- **Edge-to-edge visual audit still not resumed** (blocked since 2026-08-12 on an emulator
  keyboard quirk, itself never root-caused) — **now also flagged directly by Google Play** on the
  live Production release, not just an internal nice-to-have. 10 of 15 `Scaffold` screens have no
  `SafeArea`: `add_booking.dart`, `bottom_nav_bar.dart`, `contact_us.dart`, `get_ticket.dart`,
  `home_dashboard.dart`, `my_booking.dart`, `notification.dart`, `request_new_booking.dart`,
  `service_provider_mode.dart`, `WebView.dart`.
- **Remaining manual verification, never walked through on-device**: My Bookings' status-aware
  cards' "View Queue" button; Service Provider Mode's quick-link cards (View Queues/Now Serving/
  Queue History) opening CareConnect without its own nav chrome; Settings' bottom-sheet pickers
  (Location/Region, Notifications, Language) and dark mode/font size regression.
- **Whether the `com.pairip.licensecheck` wrapper baked into the shipped Android APK is
  intentional** (anti-piracy, from the original contractor's build pipeline) is unconfirmed —
  absent from `sq_appt_app_2`'s source entirely. Not urgent, worth asking the user if it
  resurfaces.
- **Cleanup, low urgency**: `chore/archive-stale-keystores` branch in `sq_appt_app_2` (gitignored
  files only); throwaway diagnostic scripts in `node_app_server/` (`_test_push_vicdlr.js` and
  ~9 others, all untracked); `node_app_server`'s `/service-options` query does `LIMIT 1` with no
  `ORDER BY` (non-deterministic if a unit ever has multiple `servoption` rows — not observed as an
  actual problem yet, didn't fix blind since the `servoption` schema wasn't confirmed to have a
  stable tie-break column available).
- **Reference for future sessions**: the app's real Play Console listing is under Google account
  `vicsq10809@gmail.com` (developer account "Vic10809"), **not** `devteam@smartqsys`/
  `vicdlr@gmail.com` (a separate, closed-since-2021 account, no self-service delete option
  available for it, left as-is).

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
- **`SQ_CareConnect`'s `SHARED_DATABASE_URL` (`.env`) is the same physical Postgres DB as
  `node_app_server`'s `POSTGRES_URL`** (confirmed via `lib/shared-db.ts`'s own comment) — useful
  when `node_app_server`'s own `.env` doesn't have DB credentials locally but a one-off query
  against `mdevice`/shared tables is needed.
- **CPH1909 (physical Oppo test device) has two known, unfixable-from-app-side hardware/OS
  limitations** — treat as permanent constraints of this one unit, not bugs to keep chasing:
  WebView cold-loads take ~1 min (RELRO/`address space not reserved`, Android/Linux-only, no iOS
  equivalent); ColorOS silently redirects all Play Store install paths for this app to Oppo
  Market's stale build + an embedded anti-piracy check that self-kills on a non-Play-licensed
  install (2026-08-31, full trace in `DEVLOG.md`).
