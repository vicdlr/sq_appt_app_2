# iOS Testing Handoff — SmartQ Mobile Redesign

> Written 2026-08-08 on Windows after finishing a full mockup-driven redesign round and a live
> Android-emulator testing pass. Everything below is committed and pushed — this file is just the
> map for picking the work back up on macOS in VS Code to test the iOS side. For full detail, read
> `DEVLOG.md`'s 2026-08-08 entry and `pending_work.md`'s "Open" section in this same repo.

## 1. Repos and branches to check out

| Repo | GitHub | Branch | What's on it |
|---|---|---|---|
| Mobile app | `vicdlr/sq_appt_app_2` | `feature/redesign-2026` | Full redesign: SignIn/SignUp, Home dashboard, Drawer, Settings, Contact Us, Get Ticket, booking flow, badge security fix |
| Backend | `vicdlr/node_app_server` | `feature/redesign-2026` | Badge token endpoint, queue-access mint route, `handled_by`/`is_service_provider` columns, `/service-options` fix |
| CareConnect | `vicdlr/SQ_CareConnect` | `master` | Already fully merged — nothing to check out separately, `master` has it all |
| Docs (this repo) | `vicdlr/sq_appt_app_2` (separate clone) | `mobile-redesign` | `DEVLOG.md`, `pending_work.md`, the 7 mockup JPEGs used as the design spec |

On macOS:
```bash
git clone https://github.com/vicdlr/sq_appt_app_2.git
cd sq_appt_app_2 && git checkout feature/redesign-2026
```
(same pattern for `node_app_server`; `SQ_CareConnect` just needs `master`, already default)

## 2. What's already done — no need to re-verify unless something looks off

- Badge QR redesigned as a server-minted encrypted `customerId`-only token (no more raw
  `auth_token`/`fcmToken` in the QR).
- CareConnect queue-access bridge (booking-scoped WebView link-out) and Service Provider Mode —
  both built and working, CareConnect's side already merged to `master`.
- Full UI redesign against all 7 mockups: SignIn/SignUp, Home dashboard, Drawer, Settings,
  Contact Us, Get Ticket, My Bookings, booking flow.
- Booking flow collapsed to 3 steps (Industry → Organisation → Service Provider), with
  single-provider organisations auto-skipping straight to the date/time or Data Capture page.
- Live-tested on Android emulator this session: full booking cycle (NKTI → chair 1 →
  appointment), step-indicator reset after a successful booking, single- vs multi-provider
  auto-skip behavior — all confirmed working.

## 3. iOS-specific notes

- **Signing is already resolved** (per the 2026-08-07 DEVLOG entry) — Apple Distribution
  certificate + App Store distribution provisioning profile for `com.smartqsys.sqapptapp` exist
  on the `FN232J5K2B` team and are valid until 2027-08-07. Should just work in Xcode without
  re-doing any of that.
- **No force-update workaround needed for iOS.** The server hardcodes
  `minimum_version_ios: "1.0.3"`; the app's `MARKETING_VERSION` is already `2.0.1`
  (`ios/Runner.xcodeproj/project.pbxproj`), well above the gate. This is *unlike* Android, where
  `android/app/build.gradle` currently has a **temporary** version bump
  (`versionCode 22` / `versionName "21.1.0"`, real values `21`/`"21.0.1"`) to dodge its own
  force-update check — that's an Android-only hack, isolated in its own commit
  (`b05cbfe`), and irrelevant to iOS. Don't port it over.
- Standard Flutter iOS setup applies (`cd ios && pod install`, open `Runner.xcworkspace` or just
  `flutter run -d <ios-device-or-simulator-id>`). Nothing Mac-specific was verified end-to-end
  this session beyond the certs/profile above — if `pod install` or build settings need
  adjustment, that's new ground.

## 4. Things that need a decision or action before/while testing

- **`node_app_server`'s `/service-options` fix is not deployed.** The app talks straight to
  production (`https://node-app-server.onrender.com`, deployed from `main`), and this fix lives
  on `feature/redesign-2026` (commit `edf5b25`). Until it's merged to `main` and deployed, any
  Data-Capture-type booking (on iOS or Android) will 404 with "No service options found" instead
  of showing its instructions/photo-capture hints. Worth deciding whether to deploy this now.
- There is **no staging backend** — both platforms hit the live production API and database
  during testing. Bookings created while testing are real rows in the real database.
- See `pending_work.md` for the full remaining manual-verification checklist (My Bookings status
  cards, badge screen with the new token, Service Provider Mode WebView links, Settings picker
  bottom sheets, SignIn/SignUp final pass) — none of that is iOS-specific, it just hasn't been
  walked through on any platform yet beyond what's listed as tested in DEVLOG.

## 5. Quick orientation for whoever (or whichever Claude session) picks this up

Read `DEVLOG.md`'s 2026-08-08 entry first — it has the full narrative of what was built and why,
including the two real bugs found and fixed during live testing this session (the
`/service-options` department/groupname bug, and a false alarm on booking-flow state reset that
turned out to be stale hot-reload state, not a code bug). `pending_work.md` is the current
punch list.
