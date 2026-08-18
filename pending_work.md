# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Open / needs attention (as of 2026-08-18, Mac session update)

- **Correction to earlier entries in this file and to `IOS_HANDOFF.md`: TestFlight builds already
  existed before this session, and more were added.** App Store Connect's app-level page already
  showed "SQ Appt App" at **iOS 1.0.4, Ready for Distribution**, with TestFlight builds **1.0.4
  (1)**, **1.0.5 (1)**, **1.0.6 (1)** already `Complete` and **1.0.7 (1)**/**1.0.7 (2)** already
  `Ready to Submit` — none of this was ever logged here. Every "No TestFlight build has ever
  existed for this app" line elsewhere (this file's older entries, `IOS_HANDOFF.md` §4) is stale.
  **This Mac session added builds 1.0.7 (3), (4), and (5)** — full narrative in `DEVLOG.md`'s
  2026-08-18 "(Mac session)" entry. Short version: (3) shipped from a stale branch missing the
  2026-08-17 Windows fixes (logout, City-picker, Manage Bookings routing) — don't point testers at
  it specifically. (4) has all those fixes plus a new narrower app icon, confirmed uploaded. (5)
  adds the force-update kill-switch (`41cd593`) on top of (4) — **upload not yet confirmed as of
  this writing**, Transporter was open mid-delivery.

- **`fix/android-15-compliance` has 5 local commits on this Mac not yet pushed to `origin`**: the
  icon change, a cleanup commit for an accidentally-committed stray file, and three version-bump
  commits (`+3`/`+4`/`+5` in sequence — the first two are "dead" build numbers already consumed by
  uploads, kept as real commits rather than amended). **Push these before assuming `origin` matches
  what's actually been built and uploaded.**

- **This Mac's Flutter SDK is now 3.47.0** (upgraded in place from a stale 3.24.3 via `flutter
  upgrade --force`, needed to unblock `pub get` — same `device_info_plus ^11.5.0` Dart-version
  problem the Windows session hit on its own machine, fixed differently here since this session
  never touched Android). **Untested**: whether 3.47.0 breaks this project's Android Gradle build
  the way it did on Windows (AGP9/built-in-Kotlin auto-migration) — nobody has rebuilt Android on
  this Mac since the upgrade. Check before assuming parity.

- **Confirmed dead end, documented so it isn't re-attempted: this app cannot run in any iOS
  Simulator on this Mac right now**, full root-cause in `DEVLOG.md`'s 2026-08-18 "(Mac session)"
  entry §7. Short version: x86_64 simulators crash at launch (missing `libswiftWebKit.dylib`, only
  ships in iOS 26+ simulator runtimes, which are arm64-only on this Mac); arm64 simulators fail to
  link (`GoogleMLKit`'s `MLImage.framework`, pulled in via `mobile_scanner`, has an `arm64` slice
  but it's tagged for device, not simulator — a real binary limitation, not a config bug). Real
  devices and `flutter build ipa` are unaffected. Don't spend more time trying to fix this without
  either upgrading `mobile_scanner` past 6.0.11 (currently pinned for Android 16KB compliance) or
  accepting device-only testing.

- **iOS/TestFlight is otherwise in good shape** — Android shipped 54 (48.0.6) to Open Testing.
  `pod install` verified working for the first time this session (previously flagged "unverified"
  in every handoff doc). `IOS_HANDOFF.md` has the full checklist; its §3 doesn't yet reflect the
  2026-08-18 Windows changes (View Status fix, verbose booking-status UI) or anything from this
  Mac session — worth a rewrite pass, not just an addendum, given how much of it is now stale.

- **Shipped and verified end-to-end: force-update kill-switch, replacing dead version-comparison
  code.** User asked whether the app force-updates on launch — it had a mechanism (`dio.dart`'s
  `_checkForUpdate`) but both backend constants it compared against (`checkMinimumVersionAndroid.js`
  `"21.0.3"`, `checkMinimumVersionIos.js` `"1.0.3"`) were hardcoded and never touched since written,
  always below every real shipped version (`48 > 21`, iOS's real `MARKETING_VERSION 2.0.1 > 1.0.3`)
  — dead code, likely never fired for a real user. Redesigned per user direction as a plain boolean
  kill-switch (`checkForceUpdateAndroid.js`/`checkForceUpdateIos.js`, driven by new
  `FORCE_UPDATE_ANDROID`/`FORCE_UPDATE_IOS` env vars, documented in `node_app_server/.env.example`,
  **off/unset in production right now**) instead of a version comparison — this backend has no way
  to tell which Play Store/App Store track issued an install, so comparing versions risks
  force-blocking users on a track that hasn't caught up (confirmed real: Production was still on
  version 47 while Open Testing had just shipped 54). Client (`dio.dart`) caches the flags from
  every response but only shows the blocking dialog via `DioConfig.maybeBlockForForceUpdate(context)`
  at two deliberate re-entry points the user named — New Booking's tap handler and
  `_openManageBookings()` — rather than a "shown once per session" flag that could go stale for a
  long-lived app process. **Verified live on the Oppo**: flag on → undismissable "Update Required"
  dialog blocks New Booking; flag off → normal navigation. Caught a real mistake mid-test: the
  first deploy attempt didn't fire because the backend changes had only been edited locally, never
  committed/pushed — Render just rebuilt the old code against the new (unread) env var. Fixed by
  actually committing (`921154c` on `node_app_server`) and pushing to **both** `main` and
  `peer-notification`. **For iOS**: `FORCE_UPDATE_IOS` exists and is wired the same way client-side,
  but has no gate points added on the iOS-only surface yet (New Booking/Manage Bookings are shared
  Dart code, so they're already covered) — don't set it true until there's an actual TestFlight/App
  Store release to point users at, same reasoning as Android.

- **Root-caused and fixed: My Active Queues' "View Status" button doing nothing (toast: "Couldn't
  open the queue right now").** Confirmed via Render's live logs + a direct DB check, not
  guesswork: booking 281 was CareConnect-rejected at creation (422, outside clinic hours) — that
  rejection path never persists a `Booking` row on CareConnect's side at all
  (`SQ_CareConnect/app/api/webhook/booking/route.ts:184-232`), so there was nothing for a later
  queue-access-token mint to find (404). Separately, NAS's `/cancel-booking` (`app.js:2175`)
  regressed the booking's status back to `"Request to Cancel"` with no guard against touching an
  already-terminal booking — a distinct, **still-unfixed** backend gap, flagged but out of scope
  for this fix. The actual client bug: `home_dashboard.dart`'s `_activeQueueBooking()` only
  excluded the literal string `"cancelled"`, missing `"request to cancel"` — fixed to use the same
  substring classification `my_booking.dart` already uses. Verified live on the Oppo: the dead
  card is gone. Committed as part of `70006b6`.

- **Shipped: My Bookings verbose status detail, visually confirmed and committed.**
  `my_booking.dart` now shows CareConnect's confirmed `appt_time` ("Appointment: <date>") and
  `remarks` (decline reason in red / confirmation detail otherwise) on each card — data was
  already flowing end-to-end, this was a pure UI change. Part of `70006b6`.

- **This machine's global Flutter SDK is now pinned to 3.29.3** (`C:\flutter_windows_3.24.3-stable\
  flutter`, git-checked-out via tag, channel shows `[user-branch]`/detached HEAD — not a bug, just
  how a manual tag checkout looks). Chosen deliberately over `flutter upgrade`'s default latest
  stable (3.47.0), which broke the Android Gradle build (AGP9/built-in-Kotlin auto-migration
  conflicting with this project's pinned Kotlin 2.2.20/AGP 8.11.1). 3.29.3 is the oldest stable
  shipping Dart ≥3.7 (needed for `device_info_plus ^11.5.0`), predating those changes. **Worth
  remembering**: any future `flutter upgrade` on this machine risks re-breaking the Android build
  the same way — check Gradle compatibility before jumping versions again. Also bumped
  `fluttertoast` to `^9.0.0` (Dart-version cascade from the same upgrade) and pinned
  `minSdkVersion 23` in `android/app/build.gradle` (`firebase_messaging` 16.5.0 requires it; the
  Mac's `a8cddb5` bump to that version was never followed by an Android rebuild to catch this).
  All committed in `70006b6`.

- ~~**Android version 54 (48.0.6) submitted to Open Testing 2026-08-18 — awaiting Google's
  review.**~~ **LIVE as of 2026-08-18 3:12 PM** — cleared review fast this session, confirmed via
  Play Console: "Active", "Available to unlimited testers", rolled out to 177 countries/regions.
  Supersedes the previous 53 (48.0.5) submission entirely (54 is a strict superset). Still
  deliberately untouched: the separate pending Mac release (`52`/`48.0.4`) sitting "Ready to
  publish" in Closed Testing - Alpha.

- **Android version 55 (48.0.7) submitted to Open Testing 2026-08-18 — awaiting Google's review.**
  Ships the force-update kill-switch (`e544a3b`/`41cd593` on `fix/android-15-compliance`) on top of
  54. Same "1 change sent for review" flow as before; nothing else in Publishing overview was
  touched.

- **Data bug found 2026-08-17, still not fixed**: real account `vicdlr@gmail.com` (id=133) has
  `city="Cebu ph"` in `mdevice`, confirmed should be `"Metro Manila"`. This silently breaks New
  Booking's Industry/Organisation/Unit filtering (`home_provider.dart` filters all three by
  `SharedPref.getUserData().city`) — `Cebu ph` only has Finance/Government industries in the
  `industry` table, no Healthcare. **Needs**: run `UPDATE mdevice SET city='Metro Manila' WHERE
  id=133` once confirmed.

- **Fixed 2026-08-17, not committed, not visually confirmed**: ccuser's My Bookings page now fetches
  and displays `serviceType`/`capturedImageUrl`/`capturedText` for Data Capture bookings
  (`/api/bookings/mine` + `BookingCard`'s "Captured Document" section, in `SQ_CareConnect`).
  `tsc`/`eslint` clean. **Needs**: a real Data Capture booking in the local dev DB to screenshot
  against before committing.

- **Android version 53 (48.0.5) submitted to Open Testing 2026-08-17 — still awaiting Google's
  review outcome** (typically up to 7 days). Deliberately left untouched: a separate pending Mac
  release (`52`/`48.0.4`) sitting "Ready to publish" in Closed Testing - Alpha.

## Older, carried over (not touched recently)

- **Android release keystore for Mac handoff — identified 2026-08-16, not yet confirmed
  received/working.** Correct files (confirmed via user, not guessed):
  `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2\android\key.properties` and
  `...\android\app\keystore.jks`. Transferred via Zoho WorkDrive. Mac-side placement:
  `key.properties` → `android/key.properties`, `keystore.jks` → `android/app/keystore.jks`
  (relative to the `sq_appt_app_2` checkout root). **Still needed**: confirm both files arrived and
  a signed release build actually succeeds with them on the Mac. Once confirmed,
  `WINDOWS_KEYSTORE_TRANSFER.md` can be deleted from this repo.

- **Still open, unresolved since 2026-08-12: edge-to-edge visual audit on `sq_appt_app_2`, blocked
  on a keyboard quirk.** Static audit already done (no device needed): `MainActivity.kt` is a bare
  `FlutterActivity`, nothing opts out of edge-to-edge, Flutter auto-enables it for API 35+.
  **10 of 15 `Scaffold` screens have no `SafeArea`**, likely trouble spots once verified visually:
  `add_booking.dart`, `bottom_nav_bar.dart`, `contact_us.dart`, `get_ticket.dart`,
  `home_dashboard.dart`, `my_booking.dart`, `notification.dart`, `request_new_booking.dart`,
  `service_provider_mode.dart`, `WebView.dart`. (`SignIn.dart`/`SignUp.dart` already use
  `SafeArea`.) Live visual pass never resumed after getting sidetracked by an emulator IME issue:
  on the `API36_EdgeToEdge` emulator, text fields showed only a narrow floating assist strip
  instead of the full keyboard — looked like a Gboard-on-fresh-AVD quirk, not an app bug (same
  symptom on both password and non-password fields). Root cause never confirmed; two untested
  theories (Gboard first-run onboarding intercepting focus; something `pixel_6`-AVD-specific).
  **Next steps**: manually dismiss Gboard's onboarding on the emulator once, confirm a normal
  keyboard appears, then resume the visual pass through the 10 flagged screens.
  - Note: `D:\Claude\sq_appt_app` (this checkout, branch `mobile-redesign`) and
    `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` (branch `fix/android-15-compliance`) are
    two **separate, both-legitimate** working checkouts on different branches — don't collapse
    them into one without checking with the user first.

- **Android push notifications — root-caused, fix exists, just needs merging.** Pushes get
  silently muted because the app never pre-creates the `booking_updates` notification channel
  (falls back to `fcm_fallback_notification_channel`, muted by ColorOS). Fix already written:
  `sq_appt_app_2` branch `fix/notification-channel-and-tap-handling`, commit `4edf223`. **Not yet
  merged into `fix/android-15-compliance`** — check the sort-order overlap noted below first.

- **`my_booking.dart`'s sort-by-`id`-descending may overlap with the still-unmerged
  `fix/notification-channel-and-tap-handling` branch**, which also touched My Bookings sort order —
  check for conflict/redundancy before merging that branch.

- **Cleanup: throwaway diagnostic scripts left in `node_app_server/`** — `_test_push_vicdlr.js`,
  `_check_platform.js`, `_get_auth_token.js`, `_inspect_key.js`, `_inspect_key2.js`,
  `_test_android_paths.js`, `_test_minimal_payload.js`, `_test_peer_only.js`,
  `_test_send_endpoints.js`, `_test_send_notification.js`. All untracked, safe to delete once no
  longer needed as reference.

- **Gotcha for any future direct DB work**: `mdevice.email`, `.date_registered`, and
  `.auth_token` are fixed-length Postgres `CHAR` columns — values come back space-padded.
  `auth_token` must be `.trim()`'d before `jwt.verify()` or it fails with "Invalid Token" even
  when freshly issued and otherwise valid.

- **Root-caused 2026-08-18 (still not fixable from app/backend side): WebView spins on a blank
  page for ~1 minute on this specific test device, every time, on View Status/Manage Bookings/
  View All.** Confirmed via `adb logcat` filtered to the app's actual PID (`pidof
  com.smartqsys.sq_notification` — the unfiltered buffer is dominated by other apps' noise, don't
  grep it blind): `E/WebViewLibraryLoader: can't load with relro file; address space not reserved`
  + `Failed to make and chown /acct/uid_99006: Permission denied`. This device can't share
  WebView's pre-relocated native-library memory region across renderer processes, so every new
  WebView cold-loads and relocates its libraries from scratch — slow enough on this hardware to
  produce the observed delay. Confirmed NOT a backend issue: API mint calls stayed fast (896ms–
  1.4s) throughout every reproduction. Survived a logout/login *and* a full device power cycle, so
  it's not memory pressure either. **Checked two on-device remediations, both dead ends**:
  Developer Options → WebView implementation has no alternative to switch to (Android System
  WebView is disabled/unselectable, Chrome is the only real option and already active); checking
  Chrome for a Play Store update hit a purchase-verification setup screen, correctly left for the
  user rather than automated through. **Treat as a known limitation of this specific physical test
  device** — `onRenderProcessGone` + the "Retry" button in `WebViewPage` (`get_ticket.dart`) is
  the existing in-app mitigation, working as designed, just slow to recover on this hardware.
  **Confirmed iOS-side is structurally unaffected** — RELRO/`webview_zygote` is an Android/Linux
  OS mechanism with no iOS equivalent; `WebViewPage` is shared Dart code but backed by WKWebView on
  iOS, a completely different process model. No iOS action needed for this specific bug, though
  worth confirming `onRenderProcessGone`'s iOS analog (WKWebView content-process termination)
  actually drives the same retry UI when iOS testing resumes.

- ~~**Intermittent multi-second-to-~20s+ latency on `node_app_server`/`ccuser.smartqsys.com`, not
  root-caused.**~~ **RESOLVED 2026-08-18** — root cause was `sq-careconnect` sitting on Render's
  **Free** instance type (spins down after inactivity, 50s+ cold-start), discovered while
  investigating a user report that View Status/View All/Manage Bookings all "kept looping trying
  to connect." NAS's own calls to CareConnect (`callCareConnectWebhook`, `/bookings/:id/
  queue-access`, `/careconnect/manage-bookings-link`) all use an 8s `AbortController` timeout —
  always shorter than a cold start, so every CareConnect-routed feature failed identically
  whenever it had gone to sleep. User upgraded `sq-careconnect` to Starter (matching
  `node_app_server`); verified via direct `curl` immediately afterward: ~7.8s → consistently <1s
  across 3 requests. Not a mobile-code bug at all, as the user correctly suspected. **Confirmed
  fully effective, not just a transient post-upgrade state**: the backend fix held under repeated
  re-testing (API mint calls stayed at 896ms–1.4s across multiple attempts); the ~1-minute delay
  the user kept seeing afterward turned out to be a completely separate, device-side WebView issue
  — see the RELRO item above.

- **`node_app_server`'s Render service deploys from branch `peer-notification`, not `main`** —
  remember this for every future deploy. `main`/`feature/redesign-2026` are kept in sync manually.
  Worth reconfiguring Render's branch setting to `main` at some point (not done — risky to change
  without the user explicitly deciding to).

- **Two similarly-named but functionally distinct secrets across `node_app_server`/
  `SQ_CareConnect` — don't conflate:** `NAS_SERVICE_KEY`/`CARECONNECT_SERVICE_KEY` (header
  `x-service-key`, used by `lib/notify.ts`) vs. `NAS_CC_SERVICE_KEY` (both sides, header
  `x-nas-service-key`, used by queue-access/manage-bookings-link bridges). Both confirmed set on
  Render for both services and in CareConnect's local `.env`.

- **`node_app_server`'s `/service-options` query still does `LIMIT 1` with no `ORDER BY`** — if a
  unit ever has multiple `servoption` rows differing only by department, which one wins is
  non-deterministic. Not observed as an actual problem; worth an `ORDER BY` or data cleanup if it
  comes up.

- **Remaining manual verification, not yet walked through on-device** (carried over from
  2026-08-08):
  - My Bookings' status-aware cards (Declined/Confirmed/Pending/Completed) — the "View Queue"
    button's CareConnect WebView link-out should now work (same bridge just hardened) but hasn't
    specifically been tapped and confirmed from My Bookings itself.
  - Service Provider Mode's quick-link cards (View Queues / Now Serving / Queue History) opening
    the right CareConnect page without CareConnect's own nav chrome showing.
  - Settings' bottom-sheet pickers (Location/Region, Notifications, Language) and dark mode/font
    size regression check.

- **iOS testing (general, beyond push)** — see `IOS_HANDOFF.md` in this repo. First step is
  confirming `pod install` succeeds after the deployment-target bump (done as of 2026-08-17 per
  the Mac's commits — worth a final read-through to confirm both the token-refresh callback *and*
  the defensive on-launch re-send path landed, not just one).

- **`chore/archive-stale-keystores`** (older unmerged branch in `sq_appt_app_2`) — low urgency,
  gitignored files only, can merge/clean up whenever.
