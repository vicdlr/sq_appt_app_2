# iOS Testing Handoff — SmartQ Mobile Redesign

> Rewritten 2026-08-17 after a Windows session that landed real fixes on top of the Mac's own
> 2026-08-17 iOS work (FCM token wiring, `firebase_messaging` upgrade, iOS 26 UIScene pattern,
> simulator-arch fix, App Store Connect encryption exemption — all already committed). This file
> supersedes the 2026-08-13 version, whose §3/§4 "still open" items (FCM token-refresh wiring,
> `pod install` unverified) are now largely resolved by the Mac's own work — see §2. For full
> narrative detail on the Windows-side work, read `DEVLOG.md`'s 2026-08-15/16/17 entries and
> `pending_work.md`'s open-items list, both in this same repo.

## 1. Repos and branches to check out

| Repo | GitHub | Branch | What's on it |
|---|---|---|---|
| Mobile app | `vicdlr/sq_appt_app_2` | **`fix/android-15-compliance`** (at `70006b6` as of 2026-08-18) | Full redesign, Android API-36/16KB compliance, notification-channel fixes, the Mac's 2026-08-17 iOS work, and the Windows fixes from 2026-08-17/18 (see §3/§3b). **`versionCode`/`versionName` in `android/app/build.gradle` are now `54`/`"48.0.6"` for an Android Open Testing submission — Android-only numbering, no bearing on iOS's `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION`, don't try to keep them in sync.** `pubspec.yaml`'s `version:` is still `1.0.7+1` — bump the build number before archiving for TestFlight so it doesn't collide with anything already in App Store Connect. |
| Backend | `vicdlr/node_app_server` | `main` (also mirrored to `peer-notification`, which is what Render actually deploys from — **always push both**, they've drifted before) | Commit `12aaf7d` as of 2026-08-17: forwards a `source` param through `/careconnect/manage-bookings-link` (see CareConnect row), plus a real connection-pool-leak fix across ~30 routes that was causing intermittent production 500s on `/login` etc. — already deployed, nothing to do here. |
| CareConnect | `vicdlr/SQ_CareConnect` | `master` | Commit `754823b` as of 2026-08-17: Manage Bookings now redirects to ccuser home when the patient has zero bookings (Appointments/My Queues unaffected — see §3). Also a `capturedImageUrl` display fix for Data Capture bookings on ccuser's "My Bookings" page (uncommitted as of this writing, may or may not have landed by the time you read this — check `git log`). Already merged/deployed on Render, nothing to check out for iOS building purposes. |
| Docs (this repo) | `vicdlr/sq_appt_app_2` (**same GitHub repo as the mobile app** — a separate clone on its own branch, not a different project) | `mobile-redesign` | `DEVLOG.md`, `pending_work.md`, this file. **This branch has never had the actual app code on it** — don't build from it. |

On macOS:
```bash
git clone https://github.com/vicdlr/sq_appt_app_2.git
cd sq_appt_app_2 && git checkout fix/android-15-compliance
git pull
```

**Flutter SDK:** use a recent stable (3.44.x or newer — this branch's `pubspec.yaml` requires
Dart >=3.7.0 via `device_info_plus ^11.5.0`). `flutter --version` first; if `pub get` fails with a
version-solving error, that's why.

## 2. What's already done — no need to re-verify unless something looks off

- **iOS build pipeline itself** (done by the Mac session, 2026-08-17): `firebase_messaging`
  upgraded to 16.5.0 (resolved a `GoogleDataTransport` conflict with `mobile_scanner`), simulator
  arch mismatch fixed for builds with Swift Package Manager disabled, Flutter's
  implicit-engine/UIScene pattern adopted for iOS 26, and a standard-encryption-only exemption
  declared to skip App Store Connect's export-compliance prompt.
- **iOS push notifications: client-side FCM token-refresh wiring is done** (Mac, commit
  `6464179`) — the 2026-08-13 handoff's "most important iOS-side task left" is resolved. Worth a
  real end-to-end check (token rotates → `/update-fcm-token` actually fires) but the code path
  exists now, it's not just a debug `print`.
- **`pod install`**: the 2026-08-13 Podfile/`IPHONEOS_DEPLOYMENT_TARGET` bump to 15.5 (for
  `mobile_scanner` 6.0.11) was made blind from Windows and flagged as unverified — given the Mac
  session has since built successfully enough to do simulator-arch and UIScene work, this has
  presumably already been confirmed working. If picking this up fresh, still worth a sanity
  `pod install` run first before assuming.
- Full UI redesign, badge QR security fix, CareConnect queue-access bridge, 3-step booking flow,
  WebView renderer-crash handling — all from the 2026-08-13 handoff, unchanged and not re-touched
  since.

## 3. What changed on the Windows side today (2026-08-17) — needs iOS-side verification

None of this is iOS-specific code, but none of it has been tested on iOS at all yet (Windows has
no iOS testing capability):

- **Logout was routing to New Registration instead of Sign In** (both `home_dashboard.dart`'s
  menu logout and `settings.dart`'s Logout tile) — fixed, commit `aeb9a13`. Quick manual check:
  log out, confirm you land on Sign In.
- **Sign Up's City picker had a dead tap-zone** (`DropdownButton2` hardcoded to 200px inside a
  field that visually spans much wider) — fixed, commit `7b7ab30`. Quick check: tap anywhere
  across the City field, confirm the dropdown opens.
- **Home's "My Active Queues" card and Manage Bookings routing** — reworked today, also commit
  `7b7ab30`:
  - "View Status" now mints a focused `queue-access-token` for that specific booking (lands on
    `/bookings?focus=<id>` in CareConnect), instead of the generic Manage Bookings link.
  - Manage Bookings (the Home card) now sends a `source: 'manage_bookings'` param through to
    CareConnect; if the patient has zero bookings, CareConnect redirects to ccuser home instead
    of an empty `/bookings` list. Appointments (quick action) and My Active Queues' "View all"
    deliberately keep the old always-`/bookings` behavior — they pass a different `source` (or
    none), by design, per explicit product direction. If testing this, the distinction matters:
    don't "fix" Appointments to also redirect home, that's intentional.
- **Data Capture bookings' image**: ccuser's own "My Bookings" page didn't show the captured
  image at all (ccadmin already did) — fixed CareConnect-side, not app-side, nothing to test in
  the app itself beyond opening a Data Capture booking's detail view and confirming the image
  shows.

None of the above has been run through an actual iOS build/simulator — first real verification of
all of it happens whenever this branch next gets built on the Mac.

## 3b. What changed on the Windows side 2026-08-18 (after this file was first written)

Branch is now at `70006b6` (was `7b7ab30` above). Also not iOS-specific code, also untested on
iOS:

- **My Bookings cards now show CareConnect's confirmed appointment time and outcome remarks**
  (`my_booking.dart`) — decline reason in red for rejected/cancelled bookings, confirmation detail
  otherwise. Pure UI addition, data was already in the API response.
- **Fixed a dead "View Status" button on Home's "My Active Queues" card** for bookings CareConnect
  rejected at creation time (`home_dashboard.dart`'s `_activeQueueBooking()` filter) — cosmetic/
  correctness fix, no new dependency.
- **`pubspec.yaml`: `fluttertoast` downgraded `^10.0.0` → `^9.0.0`** (Dart-version cascade from a
  Windows-side Flutter SDK pin, unrelated to iOS) — **run `pod install` again after `git pull`**,
  since a changed Flutter dependency can touch the Podfile.lock even for an iOS-only-irrelevant
  package swap. `android/app/build.gradle`'s `minSdkVersion 23` pin is Android-only, no iOS
  equivalent needed.
- Android shipped as version **54 (48.0.6)**, `versionCode` 54 — Android-only numbering, see the
  repo table above for why this doesn't map to iOS's build number.

## 4. Still open

- **Signing**: not re-verified by the Windows session (no Xcode access). Per the 2026-08-07
  DEVLOG entry: Apple Distribution certificate + App Store distribution provisioning profile for
  `com.smartqsys.sqapptapp` on team `FN232J5K2B`, valid until 2027-08-07. Should still be valid,
  confirm in Xcode rather than assuming.
- **No TestFlight build has ever existed for this app.** Android just went to Open Testing
  (submitted 2026-08-17, in Google's review as of this writing) — the natural iOS equivalent is a
  first TestFlight build, not a direct App Store production release. `testers-ios.json` (used by
  `node_app_server/notify-testers/`) is still an empty placeholder for exactly this reason.
- **No staging backend** — both platforms hit the live production API and database during
  testing. Bookings created while testing are real rows in the real database.
- Remaining manual-verification checklist (My Bookings status cards, badge screen, Service
  Provider Mode WebView links, Settings picker bottom sheets) — see `pending_work.md`'s
  "Remaining manual verification" item, not iOS-specific, hasn't been walked through on either
  platform yet beyond what DEVLOG lists as tested.

## 5. Quick orientation for whoever (or whichever Claude session) picks this up

Read `pending_work.md` first — it's the live, most-current record. Once on the Mac: `git pull` to
pick up `70006b6`, confirm `pod install` still succeeds (re-run it regardless, `pubspec.yaml`
changed — see §3b), build to a simulator/device and smoke-test §3/§3b's items (all untested on
iOS), then work toward a first TestFlight upload if the build's clean. Version 54/48.0.6's release
notes (from the Android Open Testing submission — "Improved booking status details... Fixed an
issue where a stale booking could show an inactive View Status button on Home... Minor stability
and compatibility updates.") are a reasonable starting point for TestFlight's own release notes,
adjusted for anything iOS-specific.
