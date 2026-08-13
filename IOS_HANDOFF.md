# iOS Testing Handoff — SmartQ Mobile Redesign

> Rewritten 2026-08-13 after a Windows session that did an Android-only push (API 36 targetSdk
> compliance, 16KB memory page-size fix, notification bug fixes) to get the app into Google Play
> Closed Testing. **None of that Android work has been verified on iOS yet** — some of it
> (see §3) has direct iOS-side consequences that need fixing before `pod install`/build will even
> succeed. This file supersedes the 2026-08-08 version; that one pointed at a now-superseded
> branch. For full narrative detail, read `DEVLOG.md`'s 2026-08-08 and 2026-08-12/13 entries and
> `pending_work.md`'s open-items list, both in this same repo.

## 1. Repos and branches to check out

| Repo | GitHub | Branch | What's on it |
|---|---|---|---|
| Mobile app | `vicdlr/sq_appt_app_2` | **`fix/android-15-compliance`** (not `feature/redesign-2026` — that branch is now behind) | Full redesign (SignIn/SignUp, Home dashboard, Drawer, Settings, Contact Us, Get Ticket, booking flow, badge security fix) **plus** notification bug fixes, Android API-36 toolchain bump, and a `mobile_scanner` 3.5.6→6.0.11 upgrade that affects iOS too (see §3) |
| Backend | `vicdlr/node_app_server` | `main` | Badge token endpoint, queue-access mint route, `/service-options` fix, FCM token-refresh sync + dead-token auto-clear, account-deletion page. **`main` and `peer-notification` are both at commit `10c4089`, both live/deployed on Render** — confirmed in sync as of 2026-08-13. |
| CareConnect | `vicdlr/SQ_CareConnect` | `master` | Already fully merged — nothing to check out separately |
| Docs (this repo) | `vicdlr/sq_appt_app_2` (**same GitHub repo as the mobile app** — a separate clone on its own branch, not a different project) | `mobile-redesign` | `DEVLOG.md`, `pending_work.md`, this file, the 7 mockup JPEGs used as the design spec. **This branch has never had the actual app code on it** — don't build from it. |

On macOS:
```bash
git clone https://github.com/vicdlr/sq_appt_app_2.git
cd sq_appt_app_2 && git checkout fix/android-15-compliance
git pull
```
(same pattern for `node_app_server`, just `main`; `SQ_CareConnect` just needs `master`, already default)

**Flutter SDK:** use a recent stable (3.44.x or newer — this branch's `pubspec.yaml` now requires
Dart >=3.7.0 via `device_info_plus ^11.5.0`). `flutter --version` first; if `pub get` fails with a
version-solving error, that's why. On the Windows machine this project needed a second, newer
Flutter install (`C:\flutter_stable_2026`) separate from the system-default one — check
`flutter --version` on the Mac before assuming the default install is new enough.

## 2. What's already done — no need to re-verify unless something looks off

- Badge QR redesigned as a server-minted encrypted `customerId`-only token (no more raw
  `auth_token`/`fcmToken` in the QR).
- CareConnect queue-access bridge (booking-scoped WebView link-out) and Service Provider Mode —
  both built and working, CareConnect's side already merged to `master`.
- Full UI redesign against all 7 mockups: SignIn/SignUp, Home dashboard, Drawer, Settings,
  Contact Us, Get Ticket, My Bookings, booking flow.
- Booking flow collapsed to 3 steps (Industry → Organisation → Service Provider), with
  single-provider organisations auto-skipping straight to the date/time or Data Capture page.
- WebView renderer-process crashes now handled with a "Retry" button instead of spinning forever
  (`get_ticket.dart`'s `WebViewPage`) — found on a real device, not simulated.
- My Appointments now sorts newest-first; the empty-notifications screen's `RenderFlex` overflow
  bug is fixed; a silent current-month-only filter that was hiding older notifications is removed.
- `node_app_server`'s `/service-options` fix and the FCM token-refresh/dead-token-clear work are
  **now deployed to production** (see table above) — the 2026-08-08 handoff's "not deployed yet"
  caveat no longer applies.

## 3. iOS-specific things that changed this session — act on these

- **`mobile_scanner` was upgraded 3.5.6 → 6.0.11** (Android-driven: Google Play now requires 16KB
  memory page-size support in native libraries, which needed a newer CameraX). Its iOS podspec
  pins **`s.platform = :ios, '15.5.0'`**, which was higher than this repo's `ios/Podfile`
  (`13.0`) and the Xcode project's `IPHONEOS_DEPLOYMENT_TARGET` (a mix of `12.0`/`15.0` across
  build configs) — would have broken `pod install`. **Already fixed** (commit `93620f8`,
  2026-08-13): `Podfile` and all `IPHONEOS_DEPLOYMENT_TARGET` entries bumped to `15.5`. This was
  done blind from Windows (no Xcode/CocoaPods available there) — **run `pod install` fresh on the
  Mac to regenerate `Podfile.lock`, and if it still fails, the version bump itself is the first
  thing to double-check.**
- **`device_info` → `device_info_plus` migration** touched the iOS code path directly
  (`lib/view/auth/SignUp.dart`'s `initUniqueIdentifierState()` uses
  `DeviceInfoPlugin().iosInfo` → `identifierForVendor` for iOS device ID collection at signup).
  The API shape is the same, but this is untested on an actual iOS build — confirm signup still
  captures a device ID correctly.
- **Kotlin/Gradle/AGP toolchain bump is Android-only** (`android/*.gradle`,
  `android/gradle/wrapper/*`) — nothing to port to iOS, don't let it distract from real iOS work.
- **Camera permission string is generic, not scanning-specific**:
  `NSCameraUsageDescription` in `ios/Runner/Info.plist` currently reads "To capture profile photo
  please grant camera access" — technically covers the Get Ticket scanner's camera use too (one
  string covers all camera use on iOS), but worth rewording if App Store review flags it as
  misleading. Not currently blocking, just noted.

## 4. Still open — not iOS-specific, but directly relevant to whoever tests push here

- **iOS push notifications: server-side fix is deployed, but the Flutter client still doesn't call
  it.** Confirmed by reading `lib/notification/notification.dart` directly (2026-08-13): the
  `isTokenRefresh()` method listens to `messaging.onTokenRefresh` but its callback **only
  `print`s a debug log — it never calls `POST /update-fcm-token`.** Until this is wired up (both
  on token-refresh and defensively on every app launch/foreground, since `/login` itself never
  touches `fcmtoken`), the DB-side token can still go stale exactly the way the original bug
  report described. This is arguably the single most important iOS-side code task left.
- Signing: **not re-verified this session** (Windows can't check Xcode signing). Per the
  2026-08-07 DEVLOG entry it was resolved — Apple Distribution certificate + App Store
  distribution provisioning profile for `com.smartqsys.sqapptapp` on team `FN232J5K2B`, valid
  until 2027-08-07. Should still be valid, but confirm in Xcode rather than assuming.
- **No force-update workaround needed for iOS**, still true as far as known: server hardcodes
  `minimum_version_ios: "1.0.3"`; app's `MARKETING_VERSION` is `2.0.1`
  (`ios/Runner.xcodeproj/project.pbxproj`), well above the gate. (Not re-verified against the
  server this session — if the server's iOS minimum was ever bumped, re-check.) This is unlike
  Android, which has its own real `versionCode`/`versionName` (`50`/`"48.0.2"` as of this
  session, just submitted to Google Play Closed Testing) — Android's numbering has no bearing on
  iOS's `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION`, don't try to keep them in sync.
- **No staging backend** — both platforms hit the live production API and database during
  testing. Bookings created while testing are real rows in the real database.
- Remaining manual-verification checklist (My Bookings status cards, badge screen with the new
  token, Service Provider Mode WebView links, Settings picker bottom sheets) — see
  `pending_work.md`'s "Remaining manual verification" item. None of it is iOS-specific, it just
  hasn't been walked through on any platform yet beyond what DEVLOG lists as tested.

## 5. Quick orientation for whoever (or whichever Claude session) picks this up

Read `pending_work.md` first — it's the live, most-current record (this Windows session's Android
compliance/closed-testing push is logged there in detail, dated 2026-08-13). Fall back to
`DEVLOG.md`'s dated entries for the fuller narrative and history. Once on the Mac: `pod install`
should now work (§3's Podfile fix already landed, just needs a fresh `pod install` to regenerate
`Podfile.lock`), then wire up the FCM token-refresh call (§4) — that's the most concrete,
well-scoped piece of real iOS work sitting here right now.
