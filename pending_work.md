# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## 2026-08-13

- Built and installed the app on the connected Oppo CPH1909 straight from this checkout
  (`mobile-redesign`) without checking `.claude/projects/sq_appt_app.md` first — same mistake as
  2026-08-09. User correctly flagged the installed app as "the old app." Confirmed via
  `git log mobile-redesign..origin/feature/redesign-2026` that this branch is missing ~20 redesign
  commits (Home dashboard, SignIn/SignUp, bottom nav, My Appointments, Data Capture, Badge,
  Settings, etc.) that only exist on `origin/feature/redesign-2026` (tracked in the
  `sq_appt_app_2` checkout, see project notes). Updated `KNOWLEDGE_BASE.md` and the project notes
  file with this recurrence.
- **Fixed and confirmed**: built+installed the real app from
  `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` on branch `fix/android-15-compliance`
  (currently checked out there — it's a superset of `feature/redesign-2026`'s tip `9ff4ceb` plus
  two more commits: `b443ae8` notification overflow/month-filter fixes, `fc9a877` release-version
  fix). Built as-is with its uncommitted API-36 compliance WIP (`android/*.gradle`,
  `SignUp.dart`) since that's the real current state of the branch. Installed successfully on the
  Oppo CPH1909, replacing the wrong build.
  - **New gotcha hit + resolved**: this checkout's `pubspec.yaml` now requires Dart >=3.7.0
    (`device_info_plus ^11.5.0`), which the machine's default `flutter` on PATH
    (`C:\flutter_windows_3.24.3-stable`, Dart 3.5.3) can't satisfy — build fails with a version
    -solving error. Must use the second SDK install, `C:\flutter_stable_2026` (Flutter
    3.44.9/Dart 3.12.2, already referenced in the API-36 edge-to-edge notes above), for any
    build/run of `sq_appt_app_2`. Worth adding to `DEV_GOTCHAS.md` if this trips up another
    session.

- **Closed testing submission (2026-08-13): completed the full pipeline, submitted for Google
  review.** `sq_appt_app_2` on `fix/android-15-compliance`:
  1. Committed the SDK-36 toolchain upgrade (Gradle 8.14.2, AGP 8.11.1, Kotlin 2.0.21, Java 17,
     compileSdk/targetSdk 34->36, `device_info`->`device_info_plus`) — `06a0219`.
  2. Bumped `versionCode` 48->49 (`48.0.1`) since 48 was already consumed by a stale, never-
     submitted draft release in the Alpha track — separate commit.
  3. Found the build failed Play Console's **16 KB memory page size** requirement (enforced since
     Nov 1 2025): `libbarhopper_v3.so`/`libimage_processing_util_jni.so` (ML Kit/CameraX, via
     `mobile_scanner`) were 4KB-aligned. Fixed by upgrading `mobile_scanner` 3.5.6->6.0.11 (the
     version that added CameraX 16KB support), which also required bumping the Kotlin Gradle
     plugin to 2.2.20 (`mobile_scanner` 6.0.11's own pin) and fixing a `TorchState` API break in
     `get_ticket.dart` (`controller.torchState` -> `controller.value.torchState`, plus new
     `.auto`/`.unavailable` enum cases) — commit `1d019eb`. Bumped `versionCode` 49->50 (`48.0.2`).
     Verified via `llvm-readelf -l` on the extracted `arm64-v8a` `.so` files that all LOAD segments
     are now 0x4000 (16KB) or 0x10000 (64KB) aligned. Verified the scanner still works on-device
     (Oppo CPH1909) before submitting.
  4. **Data Safety form was already correct** (Device or other IDs, name/email/phone/photos all
     "Completed", no pending edits) — the "Data safety section removed"/"Invalid Data safety form"
     policy flag on production (version 47) was stale, from before an earlier session's fix. Not
     touched this session; expected to self-resolve once this release completes Google's review.
  5. Clicked "Submit 2 changes for review," but that first click only ran Play Console's
     pre-review "quick checks" — it did **not** actually send anything to Google (Publishing
     overview reverted to "Changes not yet submitted for review" once checks finished, with the
     Submit button still sitting there unclicked). Caught this on a follow-up check, clicked
     Submit again, and this time got the actual "Send 2 changes for review?" confirmation dialog
     (with the "reviews typically completed within 7 days" text) — confirmed, and Publishing
     overview now correctly shows **"Changes in review"** / "Your changes are now in review" for
     `50 (48.0.2)` + the Data Safety questionnaire. **Gotcha: the "Submit N changes for review"
     button in Play Console can require two separate clicks — one to run quick checks, a second
     (with its own confirm dialog) to actually submit — don't assume the first click finished the
     job.** Still need to check back (Play Console's Publishing overview / Policy status) to
     confirm it actually clears Google's review and the Data Safety flag resolves.
  - Gotcha (added to `DEV_GOTCHAS.md`): this machine has two Flutter SDKs —
    `C:\flutter_windows_3.24.3-stable` (default on PATH) and `C:\flutter_stable_2026` (Flutter
    3.44.9/Dart 3.12.2, required by `sq_appt_app_2`'s current dependency versions). Always use the
    latter for this project.
  - Gotcha (not yet written up in DEV_GOTCHAS.md): stale Kotlin/Gradle daemons from a much older
    project state (Gradle 7.5, Kotlin 1.8.22) were still running in the background and had to be
    killed (`Stop-Process`) before a Kotlin-plugin-version bump would actually take effect —
    `flutter clean` alone did not fix it.

- **Rewrote `IOS_HANDOFF.md`** (2026-08-13) — the old 2026-08-08 version pointed at
  `feature/redesign-2026`, which is now behind `fix/android-15-compliance` (the branch with all
  the redesign work plus this session's Android-compliance/notification fixes). New version flags
  two concrete iOS-side action items surfaced by this session's Android work: (1) `mobile_scanner`
  6.0.11's iOS podspec needs `platform :ios, '15.5.0'`+ — **fixed same session**, see below; (2)
  confirmed by reading the code that `notification.dart`'s `onTokenRefresh` listener still only
  logs, never calls `POST /update-fcm-token` — the client-side half of the iOS push fix genuinely
  isn't done, still open.
- **Bumped iOS minimum deployment target to 15.5** (`ios/Podfile` + all
  `IPHONEOS_DEPLOYMENT_TARGET` entries in `ios/Runner.xcodeproj/project.pbxproj`, commit
  `93620f8`) to match what `mobile_scanner` 6.0.11's iOS podspec requires. Done blind from
  Windows (no Xcode/CocoaPods here to verify) — **needs a fresh `pod install` on the Mac to
  regenerate `Podfile.lock` and confirm the build actually succeeds.**

## Open / needs attention (as of 2026-08-12)

> Full narrative in `DEVLOG.md`'s 2026-08-12 "(cont.)" entry (disk-space fix, API 36 bump, emulator
> setup, iOS push server-side fix, account-deletion page), 2026-08-11 entry (notifications
> deep-dive), and 2026-08-10 entry (first physical-device pass). Disk space, the SDK 35→36 bump,
> and the API 36 emulator are all **done** — see DEVLOG, not repeated here. What's left below is
> the still-open edge-to-edge audit (blocked on a keyboard quirk) and a handful of uncommitted
> changes.

- **SUSPENDED 2026-08-12 mid-session, Android-15/16 (API 36) compliance push on `sq_appt_app_2`
  (checked out separately at `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`, branch
  `fix/android-15-compliance`, NOT the `D:\Claude\sq_appt_app` checkout tracked by this file).**
  Google Play requires new apps/updates to target **API level 36 (Android 16)** by **2026-08-31**.
  Remaining steps: fix edge-to-edge rendering (in progress, suspended here) → verify 16KB page-size
  compliance + device regression (not started). `android/app/build.gradle`'s `targetSdkVersion`
  bump 35→36 is done but **still uncommitted**.
  - **In progress / suspended here**: edge-to-edge visual audit. Static code audit first (no
    device needed): `MainActivity.kt` is a bare `FlutterActivity` with no overrides, no
    `SystemChrome`/`SystemUiOverlayStyle` usage anywhere in `lib/`, themes are stock Flutter
    defaults — nothing opts out of edge-to-edge, and Flutter 3.44.9 (the installed SDK) auto-enables
    it for API 35+. **10 of 15 screens with a `Scaffold` have no `SafeArea`** and are the likely
    trouble spots once verified visually: `add_booking.dart`, `bottom_nav_bar.dart`,
    `contact_us.dart`, `get_ticket.dart`, `home_dashboard.dart`, `my_booking.dart`,
    `notification.dart`, `request_new_booking.dart`, `service_provider_mode.dart`, `WebView.dart`.
    (`SignIn.dart`/`SignUp.dart` already use `SafeArea` — not on this list, confirmed by
    inspection, not just the grep.) Live visual pass on the new emulator had not yet reached any of
    the 10 flagged screens when the session was suspended — got sidetracked by an emulator IME
    issue (below) first.
  - **Open, unresolved, not an app bug as far as tested**: on the fresh `API36_EdgeToEdge`
    emulator, tapping text fields (login email, signup Full Name, etc.) showed only a narrow
    floating assist strip (mic/backspace/next/emoji/menu icons) instead of the full QWERTY
    keyboard — reported by the user as "only password pops keypad." Investigation via `adb`
    (`dumpsys input_method`) showed `mInputShown=true`/`mImeWindowVis=3` for the email field same
    as password, and after further testing the **same narrow strip appeared for both password and
    non-password fields**, contradicting a field-type-specific code bug — this looks like a
    Gboard-on-fresh-AVD quirk, not something in `CustomTextFormField` or the app. Tried: (1)
    disabling Google Autofill (`settings put secure autofill_service null` — no signed-in Google
    account was making `com.google.android.gms/.autofill.service.AutofillService` a plausible
    culprit) — didn't change the symptom; (2) switching to the AOSP keyboard — **not available**,
    this Google Play system image only ships Gboard
    (`com.google.android.inputmethod.latin`), no separate AOSP `LatinIME` package exists on it;
    (3) `pm clear com.google.android.inputmethod.latin` to reset Gboard's state — this surfaced a
    **first-run "Try out your stylus" handwriting-tutorial bottom sheet** on next field focus,
    which explains why the keyboard looks "missing" post-clear (the tutorial sheet covers it), but
    that tutorial is itself a *side effect of the `pm clear`*, not proof of what was happening
    *before* the clear. **Net: root cause still not confirmed.** Two live theories, untested:
    (a) Gboard's first-run onboarding sequence (stylus tutorial, possibly others queued behind it)
    is intercepting focus on a fresh install/fresh AVD in a way that only fully clears after
    someone manually clicks through all of it once; (b) something specific to the `pixel_6` AVD
    profile's stylus/input config is involved (`hw.keyboard = no` was confirmed in
    `config.ini`, ruling out physical-keyboard-passthrough as the cause). **Session suspended with
    the stylus tutorial sheet still on-screen, undismissed** (two attempted `adb shell input tap`
    dismiss-taps both missed the Cancel button's actual coordinates). **Next steps**: manually
    click through/dismiss Gboard's onboarding on the emulator once (or `adb shell input tap` with
    correct coordinates — screenshot and remeasure), confirm a full keyboard then appears normally
    for both field types, and only then resume the actual edge-to-edge visual pass through the 10
    flagged screens.
  - Note: `D:\Claude\sq_appt_app` (this checkout, branch `mobile-redesign`, 1.6G) and
    `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` (branch `fix/android-15-compliance`, 3.1G,
    uncommitted `android/app/build.gradle` change) are two **separate, both-legitimate** working
    checkouts on different branches — not duplicates, don't collapse them into one without
    checking with the user first.

- **iOS push notifications — server-side fix done and confirmed deployed; Flutter client wiring
  still needed.** Root cause (stale `mdevice.fcmtoken`) and the `node_app_server` fix (`92c480d`:
  `POST /update-fcm-token` + auto-clear of dead tokens) are detailed in `DEVLOG.md`'s 2026-08-12
  "(cont.)" entry. Confirmed via `git fetch` that `origin/peer-notification` is fast-forwarded to
  the same commit as `origin/main` (`10c4089`), so this is live on Render. **Still needed —
  Flutter/client-side wiring (not done yet):** the app must call `/update-fcm-token` (a) from
  Firebase's token-refresh callback (`onTokenRefresh` in `firebase_messaging`) whenever it fires,
  and (b) defensively on every app launch/foreground by fetching the current token and re-sending
  it, since `/login` itself never touches `fcmtoken`. Until this lands, the DB token can still go
  stale again the same way.

- **Play Console Data Safety form still needs the account-deletion URL pasted in.** Code side is
  done (`node_app_server` commit `10c4089`, live at
  `https://node-app-server.onrender.com/delete-account.html` — see DEVLOG). The Play Console
  Data Safety declaration itself still needs to be edited to point at that URL; not a code task,
  needs to be done directly in Play Console.

- **Android push notifications — root-caused, fix exists, just needs merging.** Pushes arrive but
  get silently muted by the OS because the app never pre-creates the `booking_updates` notification
  channel (confirmed via `adb`/logcat: falls back to `fcm_fallback_notification_channel`, which
  ColorOS mutes). The fix is already written: `sq_appt_app_2` branch
  `fix/notification-channel-and-tap-handling`, commit `4edf223` ("Pre-create booking_updates
  notification channel; sort My Bookings descending") — **not yet merged into
  `feature/redesign-2026`.** Check the sort-order overlap noted below before merging.

- **Uncommitted: `sq_appt_app_2/lib/view/home/notification.dart`** — fixed a real `RenderFlex
  overflowed by 27 pixels` bug in the empty-notifications state (hardcoded `vertical: 300` padding
  with no `Expanded`/scroll, broke on the Oppo's shorter screen). Wrapped in `Expanded` + `Center`,
  dropped the fixed padding. Needs a rebuild+commit; not yet re-confirmed on-device since the fix
  landed (the `flutter run` session was stopped mid-session for other testing).

- **Uncommitted: `sq_appt_app_2/lib/provider/home_provider.dart`** — removed
  `getNotificationList`'s silent current-month-only filter (was hiding any notification from an
  earlier month with no indication, looked like "all notifications lost"). Needs a rebuild+commit;
  not yet re-verified on-device that older notifications now actually show up.

- **Cleanup: throwaway diagnostic scripts left in `node_app_server/`** —
  `_test_push_vicdlr.js`, `_check_platform.js`, `_get_auth_token.js`, `_inspect_key.js`,
  `_inspect_key2.js`, `_test_android_paths.js`, `_test_minimal_payload.js`, `_test_peer_only.js`,
  `_test_send_endpoints.js`, `_test_send_notification.js`. All untracked, safe to delete once the
  iOS investigation resumes and they're no longer needed as reference.

- **Gotcha for any future direct DB work**: `mdevice.email`, `.date_registered`, and
  `.auth_token` are fixed-length Postgres `CHAR` columns — values come back space-padded.
  `auth_token` in particular must be `.trim()`'d before `jwt.verify()` or it fails with "Invalid
  Token" even when freshly issued and otherwise valid.

- **Play Store Internal Testing setup — not completed, deferred for the notifications
  investigation.** Original ask this session (Android equivalent of TestFlight); got as far as
  confirming the signing setup (`keystore.jks`, upload key match) from a prior session but never
  built/uploaded an AAB. Resume once the redesign branch is otherwise stable.

- **Uncommitted: `node_app_server/app.js`'s `reconcileOrphanedBookings()` — do not deploy as-is
  without a decision first.** Hardens against a real bug found this session: `/create-booking`'s
  fire-and-forget `routeBookingToHandler` call can be silently killed by a Render restart landing
  mid-flight (this session triggered several), leaving a booking's `status` stuck at `'Pending'`
  forever even when CareConnect already auto-confirmed it — no error logged, no way to tell short
  of manual inspection. The sweep re-routes any booking with `handled_by IS NULL` at startup + every
  10 minutes. Problem: `booking` has no `created_at` column, so it can't scope itself to "recently
  orphaned" — if old rows with `handled_by IS NULL` exist for unrelated historical reasons (count
  unknown, not checked), deploying this would reprocess all of them at once (re-sent confirmation
  pushes, possible errors on stale unit references). **Decide/check via Database Workbench
  (`SELECT COUNT(*) FROM booking WHERE handled_by IS NULL`) before committing+pushing.** User opted
  to retest with a fresh booking in the meantime instead — outcome not yet confirmed as of this
  writing.

- **WebView renderer-process crashes on this specific test device — mitigated in-app, root cause
  not fixed.** Logs showed a genuine Android system-WebView renderer crash
  (`aw_browser_terminator.cc`), preceded by repeated `NoClassDefFoundError:
  Landroid/app/UiModeManager$ContrastChangeListener` during WebView init. Added
  `onRenderProcessGone` handling + a "Retry" button in `WebViewPage` (`get_ticket.dart`) so it no
  longer spins forever, but the underlying device-side WebView compatibility issue is untouched —
  worth checking the phone's **Android System WebView** app is fully updated via Play Store.

- **Intermittent multi-second-to-~20s+ latency on both `node_app_server` and
  `ccuser.smartqsys.com`, not root-caused.** Same routes measured anywhere from <1s to ~21s across
  repeated tests this session, no clean correlation with route complexity. `node_app_server` is
  confirmed on Render's Starter plan (doesn't sleep), so it isn't free-tier cold-start. Best guess
  is rolling-restart churn from this session's own env-var change + multiple pushes (each triggers
  a Render redeploy) — not confirmed via Render's own dashboard/metrics (no access from this
  environment). Worth a real look if it recurs outside an active work session.

- **`my_booking.dart`'s new sort-by-`id`-descending may overlap with an older, still-unmerged
  branch.** `fix/notification-channel-and-tap-handling` (see the "older branches" item below) also
  touched My Bookings sort order — check for conflict/redundancy before merging that branch now
  that this session's own sort fix is on `feature/redesign-2026`.

- **`node_app_server`'s Render service deploys from branch `peer-notification`, not `main` —
  remember this for every future deploy.** This was the root cause of the whole "redesign never
  went live" investigation this session. `main` and `feature/redesign-2026` are kept in sync with
  it (currently all three point at the same commit), but any future push must include
  `peer-notification` or it silently won't deploy. Worth actually reconfiguring Render's branch
  setting to `main` at some point so this stops being a manual step — not done this session
  (out of scope, and risky to change without the user explicitly deciding to).

- **Two similarly-named but functionally distinct secrets exist across `node_app_server` /
  `SQ_CareConnect` — don't conflate them again:**
  - `NAS_SERVICE_KEY` (CareConnect env, outgoing) / `CARECONNECT_SERVICE_KEY` (NAS env, incoming
    validation) — header `x-service-key`. Used by `lib/notify.ts`'s calls to NAS's
    `/send-notification` and `/admin/mdevice/:id/service-provider-flag`.
  - `NAS_CC_SERVICE_KEY` (both sides) — header `x-nas-service-key`. Used by the queue-access and
    manage-bookings-link bridges (NAS calling CareConnect).
  - Both are now correctly set on Render for `sq-careconnect` (confirmed) and `node_app_server`
    (confirmed). CareConnect's *local* `.env` also has both now (added this session for testing).

- **Revert `sq_appt_app_2`'s `android/app/build.gradle` temporary version bump** (`versionCode
  22`/`versionName "21.1.0"` → real `21`/`"21.0.1"`) before any real release build. Still left in
  place deliberately — reverting would re-trigger the force-update dialog and block on-device
  testing. Committed separately as `b05cbfe` specifically so it's easy to find and revert.

- **`node_app_server`'s `/service-options` query still does `LIMIT 1` with no `ORDER BY`** — if a
  unit ever has multiple `servoption` rows differing only by department (now unfiltered), which
  one wins is non-deterministic. Not observed as an actual problem; worth an `ORDER BY` or data
  cleanup if it comes up. (Carried over from 2026-08-08, not touched this session.)

- **Remaining manual verification, not yet walked through on-device** (carried over from
  2026-08-08):
  - My Bookings' status-aware cards (Declined/Confirmed/Pending/Completed) — not touched this
    session. The "View Queue" button's CareConnect WebView link-out uses the same `WebViewPage`/
    ccuser bridge just fixed and hardened this session (routing, spinner, renderer-crash retry),
    so it should now work, but hasn't specifically been tapped and confirmed from My Bookings
    itself (only exercised via the Manage Bookings card).
  - Service Provider Mode's quick-link cards (View Queues / Now Serving / Queue History) opening
    the right CareConnect page without CareConnect's own nav chrome showing.
  - Settings' bottom-sheet pickers (Location/Region, Notifications, Language) and dark mode/font
    size regression check.

- **iOS testing (general, beyond push)** — see `IOS_HANDOFF.md` in this same repo. Not started yet.

- **`chore/archive-stale-keystores`** (older unmerged branch in `sq_appt_app_2`) — low urgency,
  gitignored files only, can merge/clean up whenever.
