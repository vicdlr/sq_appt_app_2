# sq_appt_app — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly. See
> `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Open / needs attention (as of 2026-08-15)

> Full narrative in `DEVLOG.md`'s 2026-08-15 entry (confirmed Closed Testing `50 (48.0.2)` is
> live/published, root-caused why testers weren't notified, built+used the `notify-testers`
> emailer), 2026-08-13 entry (wrong-checkout mistake, API 36 toolchain bump, 16KB page-size fix,
> Closed Testing submission, iOS handoff refresh), 2026-08-12 "(cont.)" entry (disk-space fix,
> emulator setup, iOS push server-side fix, account-deletion page), 2026-08-11 entry (notifications
> deep-dive), and 2026-08-10 entry (first physical-device pass). The API 36 bump, 16KB page-size
> fix, Play Console Data Safety form, Closed Testing submission + publish, the tester-notification
> gap, `notification.dart`/`home_provider.dart` fixes, and the Android version-bump-hack revert are
> all **done** — see DEVLOG, not repeated here. What's left below is the still-open edge-to-edge
> audit (blocked on a keyboard quirk) and genuinely-still-open items carried over from earlier
> sessions.

- **iOS: `pod install` needs to actually run on macOS.** The `ios/Podfile` +
  `IPHONEOS_DEPLOYMENT_TARGET` bump to 15.5 (for `mobile_scanner` 6.0.11's iOS podspec
  requirement) was made blind from Windows, commit `93620f8` — no Xcode/CocoaPods available here
  to verify it actually resolves. First real step of any iOS session: `pod install`, confirm it
  succeeds and regenerates `Podfile.lock` cleanly.
- **Still open, unresolved as of 2026-08-12, not touched since: edge-to-edge visual audit on
  `sq_appt_app_2`, blocked on a keyboard quirk.** Static code audit first (no
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

- **Android push notifications — root-caused, fix exists, just needs merging.** Pushes arrive but
  get silently muted by the OS because the app never pre-creates the `booking_updates` notification
  channel (confirmed via `adb`/logcat: falls back to `fcm_fallback_notification_channel`, which
  ColorOS mutes). The fix is already written: `sq_appt_app_2` branch
  `fix/notification-channel-and-tap-handling`, commit `4edf223` ("Pre-create booking_updates
  notification channel; sort My Bookings descending") — **not yet merged into
  `fix/android-15-compliance`.** Check the sort-order overlap noted below before merging.

- **Cleanup: throwaway diagnostic scripts left in `node_app_server/`** —
  `_test_push_vicdlr.js`, `_check_platform.js`, `_get_auth_token.js`, `_inspect_key.js`,
  `_inspect_key2.js`, `_test_android_paths.js`, `_test_minimal_payload.js`, `_test_peer_only.js`,
  `_test_send_endpoints.js`, `_test_send_notification.js`. All untracked, safe to delete once the
  iOS investigation resumes and they're no longer needed as reference.

- **Gotcha for any future direct DB work**: `mdevice.email`, `.date_registered`, and
  `.auth_token` are fixed-length Postgres `CHAR` columns — values come back space-padded.
  `auth_token` in particular must be `.trim()`'d before `jwt.verify()` or it fails with "Invalid
  Token" even when freshly issued and otherwise valid.

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

- **iOS testing (general, beyond push)** — see `IOS_HANDOFF.md` in this same repo (rewritten
  2026-08-13, points at `fix/android-15-compliance`). Not started yet; first step is confirming
  `pod install` succeeds after the deployment-target bump (see the NEW item above).

- **`chore/archive-stale-keystores`** (older unmerged branch in `sq_appt_app_2`) — low urgency,
  gitignored files only, can merge/clean up whenever.
