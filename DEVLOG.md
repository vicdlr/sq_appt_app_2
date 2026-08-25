# sq_appt_app — Development Log

> **Bumping Android's or iOS's version?** Read `IOS_HANDOFF.md`'s "Standing convention:
> build-parity check" section first and log the actual git-ancestry result in your entry below —
> not just the version number. The two platforms' version numbers have no automatic relationship
> to each other.

---

### 2026-08-25 (Windows session) — New Booking Service Provider Unit ID search, committed and pushed

User asked to add a Unit ID search field to New Booking's Service Provider step, anticipating the
unit list growing long enough that scrolling/reading it becomes impractical.

1. **First attempt: fixed "SP-" prefix + digits-only entry**, on the assumption all Unit IDs
   follow CareConnect's `SP-####` scheme (`SQ_CareConnect/lib/service-provider-no.ts`). User asked
   to test with "CH1909" before accepting it.
2. **Live device test exposed a real bug.** Set up the `API36_EdgeToEdge` emulator with a
   fake-login `SharedPreferences` push (`adb shell run-as ... shared_prefs/
   FlutterSharedPreferences.xml`, using this repo's `_fake_prefs.xml` fixture — the real test
   account, `vicdlr@gmail.com`, is still logged out with no password available). Found and fixed a
   bug in the fixture itself along the way: its `city` was `"Manila"`, but `home_provider.dart`
   filters Industries/Units by an *exact* match against `SharedPref.getUserData().city`, and the
   real `/get-cities` list only has `"Metro Manila"` — silently produced an empty Industry list.
   Typing "CH1909" against NKTI's real units confirmed the digits-only field silently mangled it
   into "SP-1909" and could never match — because most units across non-CareConnect
   industries/companies are legacy free text (`In-coming`, `chair 1`, `Regular Patient`, `Dra.
   Cecilia Montalban`, etc.) that pre-date CareConnect's Service Provider registration/approval
   system.
3. **Corrected design, per the user: those legacy units aren't real bookable providers**, so the
   fixed "SP-" prefix + digits-only field is actually correct for the field's real purpose
   (finding an *approved, registered* provider by number) — legacy units stay reachable by
   scrolling the plain list below, just not through this search field.
   `sq_appt_app_2/lib/view/home/request_new_booking.dart`'s `_ProviderStep` now has this field,
   filtering the list live as digits are typed (matches on the unit's own digits containing what's
   typed, so a partial number narrows down instead of requiring the exact zero-padded value).
4. **Re-confirmed live against a real multi-item list** (DLSU Taft, Education industry, which by
   this point had grown to 10+ real `SP-####` units, `SP-0006`..`SP-0028`, including inconsistent
   `SP_0007`/`SP_0009` underscore-vs-hyphen formatting in the raw data — the digit-extraction regex
   handles both the same way): typing `8` correctly narrowed to the 2 real matches (`SP-0008`,
   `SP-0028`); typing the full `0008` narrowed to exactly one; a non-existent number correctly
   showed "No matching Unit ID". `flutter analyze` clean.
5. **Also hit and worked around, unrelated to the above**: the Sign In screen renders solid black
   on this emulator with Impeller enabled (Sign Up renders fine) — worked around with
   `flutter run --no-enable-impeller`. Not root-caused; worth knowing if it recurs.
6. **Cleaned up after testing**: emulator's `FlutterSharedPreferences.xml` reset back to empty
   (logged-out) so it doesn't mislead a future session into thinking there's a real logged-in
   account.
7. **Committed and pushed**: `sq_appt_app_2`'s `fix/android-15-compliance` (`8ed8fbe`, was
   `33e8c8b`) has the actual fix. This docs workspace's `mobile-redesign` (`f9ddbb1`, was
   `888cc6f`) has the session log — that commit also folded in a previously-uncommitted
   2026-08-20 session log (TestFlight Apple ID loop fix, Alpha correction, build 1.0.7(7)
   promotion) that had been sitting in the working tree unresolved since that session.

**Left open, deliberately not touched**: `sq_appt_app_2/android/app/build.gradle` still hardcodes
`versionCode 59` / `versionName "48.0.11"` (this project's real, manually-bumped Android release
number — NOT the stale old "bypass hack" `pending_work.md` used to describe with real values
`21`/`"21.0.1"`, which predates dozens of real releases since). `pubspec.yaml`'s `version: 1.0.7+7`
is iOS's separate TestFlight number and must not be conflated with Android's. **Before actually
publishing this fix to Android Open Testing**: bump `versionCode`/`versionName` to the next real
number (currently 59 → 60) — deliberately deferred, not done this session.

---

### 2026-08-20 (Windows session, later still) — Closed Testing Alpha correction; TestFlight Apple ID loop fixed via External Testing migration; build 1.0.7(7) promoted; public join links created for both platforms

**1. Correction to prior session notes: Closed Testing - Alpha's build 52 is not stale, it's live.**
Earlier handoff docs (this file, `pending_work.md`) repeatedly described Alpha's build 52/48.0.4
as "long-stale," "deliberately untouched." Direct verification in Play Console showed it's actually
**live and active** -- "Available to selected testers," serving a real 16-person "Testers" email
list, last released just 2 days prior. Flagged the correction to the user rather than silently
proceeding. User chose to push the current build (59/48.0.11) to Alpha too, rather than retire the
track. **Upload was left in progress** (the browser's file picker reused a stale cached selection
showing an already-used version code -- the same class of bug hit repeatedly this project, e.g. the
58/58.0.10 Internal Testing upload) -- **not confirmed complete**, needs a follow-up check next
session.

**2. Root-caused and fixed: TestFlight testers stuck in an endless Apple ID setup loop.** User
reported testers invited via App Store Connect's Users and Access ("Internal Testers" flow) kept
looping back to an Apple ID account-setup screen instead of ever reaching TestFlight. Root cause:
Internal Testing in TestFlight is literally the same thing as Users and Access team membership --
joining requires the tester's Apple ID to join the actual Apple Developer team, which forces a full
Apple ID account-setup/2FA flow. External Testing has no such requirement -- it's a plain per-app
tester invite, no team membership involved.

**Fix:** moved the 5 affected people (all Customer Support-role team members: wmajsa2@icloud.com /
Josefina Alejandro, joeydlr@gmail.com / Joey de la Rosa, charitodlr@icloud.com / Charito de La Rosa,
haliverp@gmail.com / Harley aliver Pangandaman, joeapp6942@gmail.com / Jeorge Santos) to the
"External Testers" TestFlight group via individual email invites, then deleted all 5 from Users and
Access entirely (each deletion confirmed by name in the "Are you sure" dialog before clicking
through). **Deliberately left untouched**: `vic@smartqsys.com` (Account Holder/Admin) and every
other Users and Access entry that wasn't one of these 5 exact, already-accepted accounts -- several
similarly-named-but-different pending "Resend Invitation" entries exist for at least two of these
people (e.g. `charitodlr@gmail.com` vs. the target `charitodlr@icloud.com`; three other separate
"Jeorge Santos" invite emails vs. the target `joeapp6942@gmail.com`) and were correctly left alone.

**Gotcha hit repeatedly during this cleanup**: both the Users-and-Access delete action and the
TestFlight tester-add action showed misleading immediate UI state right after clicking through -- a
deleted user sometimes still appeared in the list with "No Apps" instead of actually being gone, and
would show a broken "There was an issue retrieving details" profile if re-opened, requiring a
second Delete click to actually finish the removal; a "tester added" success toast didn't always
mean the tester was actually saved to the group (see item 3 below). **Always verify with a hard
page reload/navigation, not the in-page toast or list state right after the action** -- App Store
Connect's UI has repeatedly shown stale/optimistic state that doesn't match the real backend result.

**3. Discovered and fixed: the prior session's "External Testers has 5 Testers" confirmation never
actually persisted.** While promoting build 1.0.7(7) (item 4), the group's own page showed only
**1 tester** (joeapp6942@gmail.com), not 5. Confirmed via App Store Connect's "Add Existing
Testers" dialog (lists every tester already known to TestFlight, group membership aside) that the
other 4 people didn't exist as TestFlight testers at all -- not a group-membership issue, they were
simply never created in the first place. Re-invited all 4 via email, **one at a time** (the
multi-row "Add New Testers" form is known-flaky with more than one row filled -- confirmed again
this session: typed First/Last Name in row 1 didn't stick even solo, only Email reliably saved),
and verified the final state with a fresh page reload each time rather than trusting the in-dialog
confirmation. Group now genuinely holds 5 testers, confirmed via reload.

**4. Promoted TestFlight build 1.0.7 (7) to External Testing.** Previously only assigned to the
`SmartqDev` internal group. Added the "External Testers" group to the build via the build's own
Group management, submitted the required "What to Test" notes ("Bug fixes and improvements,
including a fix for the Forgot Password flow on the Sign In screen"), and it went straight to
**`Testing` status** (no Beta App Review wait) -- likely inherited approval from 1.0.7(6)'s already
-cleared review cycle. Confirmed via the group's Builds tab: both 1.0.7(6) and 1.0.7(7) show
`Testing`.

**5. Created public join links for both platforms, at user's request, for handing to prospective
testers who aren't on the fixed email list.**
- **TestFlight (External Testers group)**: `https://testflight.apple.com/join/HupcF3wa` -- "Open
  to Anyone," no tester cap. Requires TestFlight installed; opens straight into the join flow.
- **Android Open Testing**: `https://play.google.com/apps/testing/com.smartqsys.sq_notification`
  -- pre-existing web opt-in link for the already-live Open Testing track (build 57/48.0.9,
  "Unlimited" testers already configured), just surfaced/confirmed via Play Console rather than
  newly created. Confirmed this is separate from the invite-only Closed Testing - Alpha link
  (item 1) and wouldn't work for general/prospective testers.

---

### 2026-08-20 (Windows session) — Root-caused and fixed: "Forgot Password" showed "A token is required for authentication"

**Context:** User reported the Sign In page's "Forgot Password?" link was broken, mentioning
something about needing a token.

**Root cause, confirmed live via direct `curl`, not guesswork:** `SignIn.dart`'s `_launchURL()`
opened `https://node-app-server.onrender.com/forgetPasswordPage` directly in the device's browser.
That path doesn't match any real route on the server -- the actual reset-landing page is
`/forget-password-page` (hyphenated), and it requires `email`+`token` query params supplied by a
real reset-request flow, neither of which the bare browser-launch ever provided. Hitting the wrong,
param-less path fell through to the server's fallback auth middleware, which returned exactly what
the user saw: `403 "A token is required for authentication"`. Confirmed the correctly-shaped
requests work fine (`GET /forget-password-page?email=...&token=...` → `400 "Invalid or expired
password reset link"` for a bogus token, as expected; `POST /forgot-password` with a bogus email →
`400 "Email is incorrect, Enter Correct email"`, also as expected) -- the entire server-side reset
flow (`POST /forgot-password` generates+emails a real token link → `GET /forget-password-page`
renders a reset form → `POST /setForgetPassword` completes it) was already fully built and working;
the mobile app simply never called the first step.

**Fix:** `sq_appt_app_2/lib/view/auth/SignIn.dart` (commit `0438736` on `fix/android-15-compliance`,
pushed) -- replaced the dead browser-launch with an in-app `AlertDialog` that collects the email
(pre-filled from the Sign In form if already valid) and calls `POST /forgot-password`, surfacing
its real success/error message via the same `Result.handleError`/`Fluttertoast` conventions already
used elsewhere on this screen. Added `ConfigUrl.forgotPasswordUrl`. `flutter analyze` clean, no new
warnings. **Not tested end-to-end on a device this session** (no device/emulator available) -- the
server-side curl checks above confirm the API contract is right, but the actual in-app dialog
flow/email delivery hasn't been click-tested.

**For the Mac session:** flagged in `pending_work.md` -- pull `fix/android-15-compliance` before
the next TestFlight build. Android's current submission (56/48.0.8) doesn't have this fix either.

---

### 2026-08-20 (Windows session, later) — Data Capture image compression; a real build-breaking pubspec bug found and fixed; Android 57 shipped to Open Testing; Closed vs. Internal testing clarified

**1. Confirmed the CareConnect OCR-failure investigation wasn't a mobile-app problem, then made a
real improvement anyway.** User asked to verify the ~2/3 `capturedText: null` rate found in
`SQ_CareConnect` wasn't caused by the mobile app uploading bad images. Checked 6 real failing
images directly against their Cloudinary URLs -- all loaded fine, correct content-type, real byte
content (2-7MB each). Not corruption. But `form_page.dart`'s `ImagePicker().pickImage()` had no
compression params at all, uploading full native camera resolution -- a real contributing risk
factor for the backend's fetch-then-send-to-Gemini step timing out on larger files. Added
`maxWidth: 1920, imageQuality: 80` (commit `24c8657`) -- still plenty legible for a document
photo, cuts typical file size substantially, and speeds up upload for users on weak connections
too.

**2. Found and fixed a real, unrelated build-breaking bug while cutting the next Android
release.** `flutter build appbundle --release` failed immediately: "Could not find the
firebase_core FlutterFire plugin, have you added it as a dependency in your pubspec?"
`firebase_core` was commented out in `pubspec.yaml` despite `firebase_messaging` needing it --
Dart-level resolution masked this (already pulled in transitively via `pubspec.lock`, locked at
`4.13.0`), but FlutterFire's Android Gradle plugin requires it as a **direct** pubspec dependency
to register the native Gradle project at all. Fixed by declaring it directly at the already-locked
version (`firebase_core: ^4.13.0`) -- no other resolution changed (`pubspec.lock` diff was one
line). Along the way also hit a real pub-cache corruption issue (`firebase_core-4.13.0` and ~15
other packages had empty/incomplete cache directories, likely an old interrupted download) that
looked like the same bug but wasn't -- `flutter pub cache repair`, run twice, cleared it. Both
issues are now resolved; commit `4a88781` (bundled with the version bump below).

**3. Android version 57 (48.0.9) submitted to Open Testing** -- ships the Forgot Password fix
(`0438736`) and the image compression above (`24c8657`) on top of 56. Submitted only the new "57"
change; the pre-existing "56 (48.0.8) -- Start full rollout" entry (Google-approved, never
manually published) was again left untouched, same as every prior release this session.

**4. User asked about submitting to Closed Testing "for quicker release."** Checked the actual
Play Console state before assuming: two Closed Testing tracks already exist (`BetaTest`, dormant
since Mar 2025; `Alpha`, still holding the long-stale build 52/48.0.4 that's been flagged
repeatedly throughout this project's history as deliberately untouched -- confirmed **still**
sitting there, unresolved). Clarified for the user: Closed Testing doesn't actually get faster
Google review than Open Testing once an app has publishing history -- both go through the same
lightweight testing-track review. The real "instant, zero review" option is Internal Testing.
User chose Internal Testing once this was clarified.

**5. Android 58 (48.0.10) shipped to Internal Testing — live immediately, no review.** Needed a
new version code -- Play Console requires uniqueness across *every* track, not just within one,
and 57 was already claimed by Open Testing. Bumped and rebuilt (same commit as the firebase_core
fix, `4a88781`). Upload hit a minor snag first (browser's file picker reused a stale cached
selection, still showing version code 57, rejected) -- re-uploaded fresh and it took. Confirmed
"Available to internal testers" the moment Save and publish was clicked (10:56 AM) -- Internal
Testing genuinely has no review step, unlike Open/Closed. Same fixes as 57 (Forgot Password, Data
Capture image compression) plus the firebase_core build fix, now reachable by whoever's already
on the existing internal tester list.

---

### 2026-08-19 (Windows session, later) — Retired stale tracked Flutter app code from this docs-only branch

**Context:** While moving `sq_appt_app_2`/`node_app_server` from `C:\Users\vic\AndroidStudioProjects\`
to `D:\Claude\` (unrelated task), discovered this checkout (`mobile-redesign`) still had 162
git-tracked files under `android/`/`ios/`/`lib/`/`linux/`/`macos/`/`test/`/`web/`/`windows/`/
`pubspec.*` — genuine old pre-redesign app code (e.g. `lib/main.dart`, `lib/view/home/home_page.dart`,
singular `lib/view/home/notification.dart`), plus committed build artifacts that never should have
been tracked (`android/app/build/ios/Pods.build/.../dgph` paths). This contradicts
`IOS_HANDOFF.md`'s documented convention that `mobile-redesign` "never had app code, don't build
from it" — the code was real, just stale, predating that convention or the branch's re-purposing
as docs-only.

**Fix:** `git rm -r` on all app-code paths (230 files, 12,907 deletions), confirmed with the user
first since it's a real commit affecting shared history both Windows and Mac pull from — not just
local cleanup. Cross-checked with Mac Claude beforehand (it confirmed its own actual docs-editing
workflow uses a completely separate, unsynced worktree elsewhere, not this checkout or its
Syncthing mirror, so this removal doesn't touch anything Mac was actively relying on). Also cleared
the local untracked Flutter build cruft (`build/`, `.dart_tool/`, `.flutter-plugins*`) that was
sitting alongside the tracked files.

**Committed** `5ba2185`, merged one concurrent Mac commit (`64f4a6d`, docs-only, no overlap) via
`git pull`, pushed as `fed8051` to `origin/mobile-redesign`. This branch now holds only
`DEVLOG.md`/`pending_work.md`/briefing docs/mockups, matching its documented intent. Real app code
lives exclusively in `D:\Claude\sq_appt_app_2` (Windows) and Mac's own separate checkout.

---

### 2026-08-19 (Mac session) — TestFlight build 1.0.7 (6): picked up the delete-account fix, closing the Windows session's "⚠️ pull before next build" flag

**Context:** Windows session's same-day entry (below) flagged that `fix/android-15-compliance` had
moved to `55c9fa6` (delete-account confirmation fix) on top of what this Mac had last built
(`f97cf7e`, 1.0.7+5) and warned any build cut from a stale local branch would ship the old
fire-and-forget delete behavior — the same mistake that shipped build 1.0.7(3) without the
2026-08-17 Windows fixes. This session is that pull.

**1. `git fetch && git rebase origin/fix/android-15-compliance`** picked up `55c9fa6` cleanly, no
conflicts. No dependency changes in that commit (one Dart file, `settings.dart`), so no `pod
install` needed.

**2. Confirmed build 1.0.7 (5) had actually finished uploading** (asked directly rather than
assuming) before bumping — **build number is now 1.0.7+6**, per this session's established
one-build-number-per-upload discipline (see 2026-08-18 entry below for why: build 3 shipped from
stale code, and reusing a build number that's already `Ready to Submit`/`Processing` in App Store
Connect gets rejected as a duplicate).

**3. Built and uploaded via Transporter.** `flutter build ipa --release` succeeded clean —
`Version Number: 1.0.7`, `Build Number: 6`, IPA at `build/ios/ipa` (35.4MB). Contains everything
through build 5 (all 2026-08-17/18 Windows fixes, the narrower app icon) plus `55c9fa6`'s
delete-account confirmation fix. **User confirmed upload completed**, later verified in App Store
Connect: build 6 shows `Complete`.

**4. Retired every other TestFlight build — only build 6 is live for testers now.** User asked to
"retire all the rest." Expired via each build's "Expire Build" button in App Store Connect
(confirmation dialog each time, "This build will no longer be available to testers"): all of
Version 1.0.7's builds 1 through 5, plus Version 1.0.6 (1) and Version 1.0.5 (1) — those three
version groups had been sitting `Ready to Submit`/assigned to the `SmartqDev` internal group since
before this session. Versions 1.0.4, 1.0.3, and 1.0.1's builds were already `Expired` from
whatever session originally shipped them (see this file's 2026-08-18 entry §1 for how those
pre-existing builds were discovered). **Verified via the `SmartqDev` group's own Builds tab**
(not just the main builds list) that it now shows exactly one build, `1.0.7 (6)`, status
`Testing` — confirms testers actually see build 6 as their only option, not just that other builds
say "Expired" on the admin side.

**5. Added "What to Test" release notes to build 6** (previously blank) — summarized the
cumulative changes since this is the only build testers can install: Logout-routing fix, City
picker fix, Manage Bookings/My Active Queues routing accuracy, My Bookings appointment-time/
decline-reason detail, the stale View Status fix, the delete-account confirmation fix, and the new
app icon. Asked testers to specifically exercise sign in/out, new booking, My Bookings, My Active
Queues, and Settings > Delete Account.

**6. Submitted build 1.0.7 (6) for external testing — first Beta App Review submission for this
app.** User asked whether to promote to external testing or go straight to a production App Store
submission; recommended external testing first (mirrors the Android precedent of Closed → Open
Testing before any production release, and this Mac has no way to Simulator-test iOS at all — see
§7 below — so real external testers are the only pre-release verification available). Created a
new External Testing group (**"External Testers"**, 0 testers as of this writing — user will add
people afterward via the group's Testers tab or its public TestFlight link), added build 6 to it,
carried over the same "What to Test" notes from internal testing, and submitted. **Status:
`Waiting for Review`** (Apple's Beta App Review — typically 24-48 hours, lighter than full App
Store review). Not yet approved as of this writing.

**Still true from 2026-08-18, unchanged**: this app cannot run in any iOS Simulator on this Mac
(arm64-simulator dead end, see that entry's §7) — device/TestFlight builds are the only way to
verify anything on iOS here.

---

### 2026-08-19 (Windows session) — Registration broken for all new users, root-caused and fixed; account deletion redesigned as soft-delete so re-registration works; Android 56 (48.0.8) submitted to Open Testing

**1. Registration was broken for every new user, not just the one reported.** User reported
`joeydlr@gmail.com` got a "Failed to register" dialog signing up. Checked Render's live logs for
`node_app_server` and found the real error: `null value in column "id" of relation "mdevice"
violates not-null constraint` (Postgres `23502`). Root cause: `mdevice.id` had no default and no
owned sequence at all (`pg_get_serial_sequence` returned null, no triggers) — the last row to get
an `id` was `134` on 2026-08-13; every `/register`/`/pre-register` insert since then hit this same
NOT NULL violation, since neither route supplies `id` explicitly. Confirmed via direct DB query
that `joeydlr@gmail.com` had zero rows (ruling out the "email already exists" path) — this was a
live, systemic outage, not a per-user issue. **Fixed** by recreating the sequence and wiring it
back as the column default (`CREATE SEQUENCE mdevice_id_seq OWNED BY mdevice.id`, `setval` to the
current max, `ALTER TABLE ... SET DEFAULT nextval(...)`) — run directly against production by the
user via Database Workbench (statements had to be executed one at a time; Postgres's extended
query protocol rejects multiple commands in one prepared statement). Verified fixed: column default
is `nextval('mdevice_id_seq'::regclass)`, sequence `last_value=134, is_called=true`.

**2. Follow-up product bug, also fixed: deleted accounts couldn't re-register.** User noted that
since account deletion doesn't seem to free up the email, a previously-deleted user re-registering
just gets blocked as a duplicate. Investigated `DELETE /users/:userId` — it *was* a real hard
`DELETE FROM mdevice`, so in principle deletion should already free the email... except
`sq_appt_app_2`'s `deleteAccount()` (`settings.dart`) fired the request **without awaiting or
checking the result** — the caller cleared local session and navigated to Signup regardless of
whether the server call actually succeeded, so a failed delete (network blip, race, anything)
silently left the row behind while the user believed the account was gone.

Rather than just fixing the client bug and leaving hard-delete in place, redesigned this as an
explicit soft-delete (flagged as a security-relevant decision, confirmed with the user before
implementing): `DELETE /users/:userId` now sets `isdelete=true` + clears `auth_token` instead of
removing the row; `/register` blocks an existing email only when `isdelete=false`, and **reactivates**
a soft-deleted row in place (new password/device/verification token, same `guid`/`customerid` so
old bookings still resolve) instead of either blocking it or inserting a duplicate; `/login` now
rejects soft-deleted accounts (wasn't checked before — needed once the row persists after
"deletion" instead of disappearing). This specifically avoids a takeover hole: nobody can hijack a
still-active account by "re-registering" someone else's email, since only rows already marked
deleted are reactivatable. Paired client fix: `deleteAccount()` in **both** `sq_appt_app_2`
(`fix/android-15-compliance`) and this docs-workspace copy (`mobile-redesign`) now returns whether
the server confirmed deletion (`200`), and local logout/navigation only happens on that
confirmation — otherwise the existing error dialog shows and the user stays on Settings.

**Commits:**
- `node_app_server`: `8bf38d2` ("Soft-delete accounts and allow re-registration of deleted emails")
  — pushed to **both** `main` and `peer-notification` (Render's actual deploy branch). Should
  already be live via Render auto-deploy.
- `sq_appt_app_2` `fix/android-15-compliance`: `55c9fa6` ("Fix delete-account not confirming
  success before clearing local session") — rebased cleanly onto the Mac session's iOS build-number
  commits (`f97cf7e` etc.), nothing lost, pushed.
- This repo (`mobile-redesign`): `dc340f4`, same fix mirrored for consistency — rebased onto the
  Mac session's `a6a68ed` devlog commit, pushed.

**Resolved same-day: the Mac session picked up `55c9fa6` and shipped TestFlight build 1.0.7(6)**
— see that session's entry above, logged earlier on this page since it landed chronologically after
this one but appears first. No outstanding action for iOS from this fix.

**3. Built and submitted Android version 56 (48.0.8) to Open Testing.** Before building, found
`sq_appt_app_2`'s working tree already had uncommitted, in-progress work unrelated to this fix — a
"Service Provider Mode" SSO token-bridge feature (`configurl.dart`, `service_provider_mode.dart`),
paired with an also-uncommitted new endpoint in the local `node_app_server` checkout
(`/careconnect/service-provider-link`). Not authored this session, not deployed, not tested —
stashed it before building so the release wouldn't ship a half-finished feature, then restored it
afterward untouched. Bumped `android/app/build.gradle` 55→56 (48.0.7→48.0.8, `969ff3a`), built
`flutter build appbundle --release` on the pinned 3.29.3 SDK (38.6MB `.aab`), uploaded and submitted
via Play Console. **Account gotcha worth remembering**: `vicdlr@gmail.com`'s only associated
developer account (`devteam@smartqsys`) is closed/inactive since 2021 — the real publishing account
(`Vic10809`, app `com.smartqsys.sq_notification`) is under a *different* Google identity,
`vicsq10809@gmail.com`. Submitted only the new "56" change; left the pre-existing "55 (48.0.7) —
Start full rollout" entry sitting in Publishing overview's "Changes ready to publish" (Google-approved,
never manually published) completely untouched, since that wasn't part of this task.

**4. Discovered mid-handoff: checkouts have moved, and the stashed Service Provider Mode work is
now committed elsewhere.** User reported opening `D:\Claude\sq_appt_app_2` in Android Studio —
a location not in any project notes. Investigated: `C:\Users\vic\AndroidStudioProjects\node_app_server`
no longer exists (moved, not copied, to `D:\Claude\node_app_server`); `D:\Claude\sq_appt_app_2`
is a separate live checkout of the same repo as the `AndroidStudioProjects` one, on the same
`fix/android-15-compliance` branch. Both new checkouts have the Service Provider Mode SSO feature
(item 3's aside) **finished and committed** — `3b653eb` (client) and `f50edcc` (backend,
`/careconnect/service-provider-link`) — but **neither is pushed**, so the feature doesn't work in
production yet if tested from here. Flagged for the user rather than pushed unilaterally (a
backend push to `peer-notification` deploys immediately); no decision yet as of this hand-off —
see `pending_work.md`'s ⚠️ entries. Whether this is a deliberate full migration to `D:\Claude\`
(matching `CLAUDE.md`'s convention) or still in progress is also unconfirmed — `KNOWLEDGE_BASE.md`'s
`projects/sq_appt_app.md` still documents the old two-checkout split and needs a rewrite once
that's settled.

---

### 2026-08-18 (Mac session) — First real TestFlight uploads; corrected a "no TestFlight build ever existed" claim; narrower app icon; arm64-simulator dead end documented

**Context:** Picked up `IOS_HANDOFF.md`'s instruction to get `fix/android-15-compliance` building on
the Mac and work toward a first TestFlight submission. Two framing corrections came out of this
session that are worth reading before trusting anything upstream about iOS TestFlight status.

**1. Correction: this was not actually a from-zero "first-ever TestFlight build."** App Store
Connect's Apps page already showed "SQ Appt App" at the app level as **iOS 1.0.4, Ready for
Distribution**, and its TestFlight page already listed builds **1.0.4 (1)**, **1.0.5 (1)**, **1.0.6
(1)** as `Complete`, plus **1.0.7 (1)** and **1.0.7 (2)** already sitting `Ready to Submit` — all
from some earlier session never reflected in this DEVLOG or `pending_work.md`. An internal tester
group (`SmartqDev`) is already configured. So real iOS build/TestFlight work predates this session
by several versions; treat `IOS_HANDOFF.md`'s "No TestFlight build has ever existed for this app"
line (§4, written 2026-08-17) as **stale/wrong** — corrected in `pending_work.md`.

**2. Mac's Flutter SDK was stale and blocked `pub get` outright** — 3.24.3/Dart 3.5.3, same
`device_info_plus ^11.5.0` (needs Dart ≥3.7.0) problem the Windows session hit and fixed by pinning
*their own* machine to 3.29.3. On the Mac, `flutter upgrade --force` to latest stable (**3.47.0**,
Dart 3.13.0) was used instead — no Android Gradle rebuild was attempted this session (iOS-only
work), so unlike Windows, whether 3.47 would break this project's Android build on the Mac is
**untested and unknown**. Worth checking before assuming parity if Android is ever built here.

**3. `pod install` succeeded cleanly** — the 2026-08-13 Podfile/deployment-target bump verified
working for the first time (previously flagged "unverified" in every handoff doc).

**4. First upload — build 1.0.7 (3) — was built from a stale local branch and shipped without the
2026-08-17 Windows fixes.** Root cause: `git status` reported "up to date" from a stale local
knowledge of `origin` (no fetch had actually been run since the session started); `origin` had
moved 4 commits ahead (`aeb9a13` logout-routing fix, two merge commits, `7b7ab30` City-picker +
Manage Bookings/My Active Queues routing rework) between session start and when the build kicked
off. Discovered only after the build was already uploaded and "Processing" in TestFlight.
**Testers who get build 3 specifically will still see the pre-fix logout bug, dead City-picker tap
zone, and old Manage Bookings routing** — none of that is in this build. Superseded by build 4/5
below; not worth pulling from TestFlight retroactively, just don't point testers at it specifically.

**5. Rebased local work onto the correct `origin` head and rebuilt as build 1.0.7 (4).** `git
rebase origin/fix/android-15-compliance` (one local commit, the +3 bump) applied cleanly on top of
`70006b6`. This build genuinely contains all the 2026-08-17/18 Windows fixes. **Confirmed uploaded
via Transporter** (per user, not independently re-verified in App Store Connect — the browser
session logged out both times a check was attempted).

**6. Changed the iOS home-screen icon.** User supplied a new source image
(`~/Downloads/new 180.png`, 1254×1254). Iterated on a "too squarish" complaint by squeezing the
logo ~20% narrower horizontally and padding the freed width with white on both sides (keeps the
icon canvas square per Apple's requirement, reads less block-like at small sizes — the squeeze does
mildly oval the "Q"'s round strokes, user approved after seeing a preview). Regenerated all 11
`AppIcon.appiconset` sizes via `sips`. Visually confirmed by installing on an iPhone 16
(iOS 18.4) simulator and screenshotting the home screen. Committed as two commits (a wildcard
`git add` accidentally swept in an unrelated stray `new 180.png` file sitting in the appiconset
folder already — not something this session created, not referenced by `Contents.json` — removed
in a follow-up commit rather than amending).

**7. Definitively root-caused why this app cannot run in any Simulator on this Mac right now** —
worth preserving even though the outcome was "don't fix it," since it'll recur for anyone else on
Apple Silicon + Xcode 26:
   - x86_64 simulators (iOS 17.4/18.4, the only ones this project's `EXCLUDED_ARCHS[sdk=iphonesimulator*]
     = i386 arm64` Podfile hack permits — see `ios/Podfile`'s `post_install`, itself forced by
     `mobile_scanner` 6.0.11's own podspec excluding arm64 for simulator) crash at launch:
     `Library not loaded: /usr/lib/swift/libswiftWebKit.dylib`, needed by
     `flutter_inappwebview_ios` because it was compiled against Xcode 26.6's SDK — but that library
     only ships in the **iOS 26 simulator runtime**, which on this Mac is **arm64-only** (no x86_64
     slice at all).
   - Tried lifting the arm64 exclusion (patched the pub-cache copy of `mobile_scanner.podspec`,
     `ios/Podfile`, and even hand-edited `ios/Flutter/Generated.xcconfig` to break a
     self-reinforcing stale-detection loop in Flutter's own tooling — `xcode_project.dart`'s
     `_targetsExcludingArm` re-derives the exclusion from live `xcodebuild -showBuildSettings`
     output, which was itself already poisoned by the prior stale `Generated.xcconfig`). Got past
     all of that and reached the **real** wall: `MLImage.framework` (GoogleMLKit, pulled in by
     `mobile_scanner`) does contain an `arm64` slice, but it's tagged for the **device** platform
     variant, not simulator — `Error (Xcode): Building for 'iOS-simulator', but linking in object
     file ... built for 'iOS'`. `lipo -info` doesn't surface this distinction; the linker enforces
     it strictly. This is a genuine binary limitation of the vendored MLKit version, not a config
     mistake — the plugin author's own podspec TODO comment ("add back arm64 ... when switching to
     the Vision API") already flagged this as known/deliberate.
   - **Net: no simulator combination on this Mac can run this app while `mobile_scanner` stays
     pinned at 6.0.11.** Real devices and `flutter build ipa` are unaffected (different code path,
     always arm64-device). All experimental config changes were reverted back to the working
     x86_64-forced state; nothing about this is committed.

**8. Picked up `41cd593`'s force-update kill-switch, rebuilt again as build 1.0.7 (5).** After the
icon/build-4 work, pulled again and found `origin` had moved one more commit
(`41cd593`, force-update kill-switch — see this file's own 2026-08-18 Windows-session entry above
for the backend side). Rebased cleanly, re-ran `pub get`/`pod install` (no actual dependency delta
in that commit, but lockfiles had been reset during the arm64 experiment cleanup), rebuilt. **Build
number had to jump to 5, not stay at 4** — confirmed with the user that build 4 had already been
delivered via Transporter before this pull landed, so 4 was no longer available. Build 5 is the
current head of local work; **upload not yet confirmed as of this writing** (Transporter was
opened, user was mid-delivery).

**Local git state, not yet pushed to `origin/fix/android-15-compliance`**: five commits sit on top
of `41cd593` — the icon change (`6cfe2d6` + a cleanup commit `f90e379` removing the accidentally-
committed stray file), then three version-bump commits in sequence (`+3`, `+4`, `+5` — the `+3`/`+4`
ones are "dead" in the sense that their build number was already consumed and superseded, but kept
as real commits rather than squashed/amended, per this session's git-safety practice of never
amending). **Someone needs to push these** before the next session picks this branch up, or the
push itself is a fine next step whenever build 5's upload is confirmed.

**Files touched this session:** `sq_appt_app_2` (`fix/android-15-compliance`) — 5 local commits,
not yet pushed (see above). `~/.pub-cache/hosted/pub.dev/mobile_scanner-6.0.11/ios/mobile_scanner.podspec`
was temporarily patched then reverted (shared pub-cache file, affects any project on this Mac using
that exact plugin version — reverted cleanly, no lasting change). `/Applications/flutter` upgraded
in place from 3.24.3 to 3.47.0 (not project-local, affects any Flutter project built on this Mac
going forward).

---

### 2026-08-18 — My Bookings verbose status detail; Flutter SDK upgrade saga to unblock physical-device testing

**Context:** Picked up the previous session's still-open "My Active Queues → View Status still lands
on the mobile booking table instead of CareConnect's ccuser bookings" report, plus a new ask: make
My Bookings' status cards more informative (final appointment info when confirmed, reason when
cancelled). That second ask turned into a real toolchain-repair detour once actual device testing
was attempted.

**1. Confirmed CareConnect's booking routing is already industry-agnostic — no change needed.**
User asked whether "CareConnect handles all industry bookings" had actually been implemented.
Read `node_app_server/app.js`'s `routeBookingToHandler`/`callCareConnectWebhook` (~line 1653/1812):
every booking, any industry, is POSTed to CareConnect's webhook first; CareConnect itself decides
per-unit whether it handles it (404/`handled:false` → falls back to SAM). Confirmed this matches
what was discussed — routing is not industry-gated on NAS's side, by design.

**2. Added verbose status detail to `sq_appt_app_2`'s My Bookings cards (`my_booking.dart`).**
The data was already flowing end-to-end and already parsed into `BookingModel` — this was a pure
UI change. `applyCareConnectOutcome` (`app.js:1776`) already writes `appt_time` (CareConnect's
confirmed final appointment time) and `remarks` (`"Booking rejected: <reason>"` for
declined/cancelled, `"<statusLabel>. Booking #<dailyBookingNo>."` otherwise) on every outcome;
`/bookings/user/:userId` does `SELECT *`, and `BookingModel.fromJson` already parsed both fields —
`my_booking.dart` simply never rendered them. Now shows `appt_time` (when set) as an explicit
"Appointment: <date>" line ahead of the originally-requested slot, and `remarks` as a subtitle
(red for declined/cancelled, grey otherwise). `flutter analyze` clean on the file. **Not yet
committed, not yet visually confirmed on device** (see #6).

**3. Diagnosed a real, pre-existing stale-toolchain problem while prepping to test on device.**
`flutter analyze`/`pub get` in this shell failed outright: local Flutter was 3.24.3/Dart 3.5.3, but
the 2026-08-13 API 36 compliance push (`06a02196`) had pinned `device_info_plus: ^11.5.0`, which
needs Dart ≥3.7.0. This machine's Flutter had never been bumped alongside that dependency change —
likely broken in this shell since 2026-08-13.

**4. `flutter upgrade` to latest stable (3.47.0/Dart 3.13.0) fixed that but broke the Android Gradle
build.** Flutter 3.47 auto-migrates projects toward AGP 9's new DSL and built-in-Kotlin management
(silently added `android.builtInKotlin=false`/`android.newDsl=false` to `gradle.properties`), which
fought with `sq_appt_app_2`'s explicitly-pinned Kotlin 2.2.20/AGP 8.11.1 setup — Gradle reported the
project's Kotlin version as 2.0.0 despite both `android/build.gradle` and `android/settings.gradle`
correctly declaring 2.2.20. User decided to pin to an older stable rather than adapt the Gradle
config to 3.47.

**5. Pinned Flutter to 3.29.3** (oldest stable shipping Dart ≥3.7, predating the AGP9/built-in-Kotlin
changes) via a direct `git checkout 3.29.3` inside the Flutter SDK's own repo
(`C:\flutter_windows_3.24.3-stable\flutter` — despite the stale directory name, this is a git
checkout kept on the stable channel; the `flutter version` subcommand isn't available in this tool
build, so switched manually). Had to first discard the SDK repo's own auto-regenerated
`pubspec.lock` (tooling-internal, not user content) to allow the checkout.

**6. That surfaced a second cascading constraint**: `fluttertoast: ^10.0.0` needs Dart ≥3.12.0,
higher than 3.29.3's Dart 3.7.2. Fixed via pub's own suggested resolution — downgraded the pin to
`^9.0.0` in `sq_appt_app_2/pubspec.yaml`. Verified low-risk first: every call site in the app is the
plain `Fluttertoast.showToast(msg: ...)` API, stable across fluttertoast's major versions.
`pub get` then resolved cleanly (43 dependencies changed), `flutter analyze` came back clean at 178
pre-existing style issues / 0 errors (matches the ~180-issue baseline from the 2026-08-15 Mac
merge).

**7. Device build then hit a third, unrelated pre-existing gap**: `firebase_messaging` 16.5.0
(bumped by the Mac's `a8cddb5`, 2026-08-14) requires `minSdkVersion 23` in its manifest, but
`android/app/build.gradle`'s `defaultConfig` was still deferring to Flutter's own default
(`flutter.minSdkVersion`, effectively 21) — never caught because the Mac session never rebuilt
Android after that bump. Fixed by pinning `minSdkVersion 23` explicitly, per Flutter's own
suggested fix.

**8. App built and launched successfully on the physical Oppo CPH1909** (`flutter run -d CPH1909
--debug`). **Visual confirmation of #2 blocked**: a device-level Emergency Alert (a real NDRRMC
Orange Rainfall Warning, unrelated to the app) is covering the screen and won't dismiss via `adb
input tap` on its OK button (OPPO/ColorOS appears to filter synthetic touches on this particular
system overlay); the screen also auto-locks every few seconds, needing a fresh `KEYCODE_WAKEUP`
before each capture. Session paused waiting on the user to manually dismiss the alert on-device.

**9. Re-examined the "View Status still routes to the mobile booking table" report from the
previous session**, but the investigation was interrupted before reaching a conclusion. Read the
current `_ActiveQueueCard._viewStatus()` in `home_dashboard.dart` — the logic looks correct (mints
a focused `queue-access-token`, opens CareConnect's WebView on success), matching what the
2026-08-17 session already committed (`754823b`/`12aaf7d`/`7b7ab30`) and flagged as **not yet
device-confirmed**. Never got to check whether the device that reproduced the bug was actually
running a build containing that fix. **Still open** — see `pending_work.md`.

**10. User dismissed the Emergency Alert; relaunched and root-caused the View Status bug for
real.** Re-ran `flutter run -d CPH1909` (after an `adb` "device offline" hiccup that needed a
physical USB replug to clear). User reported the concrete symptom directly: "View Status" showed a
toast, "Couldn't open the queue right now." `pretty_dio_logger`'s console output (already wired into
the app) showed NAS's `/bookings/281/queue-access` returning a 502. With the user's permission,
opened Render's dashboard in Chrome (already authenticated) and searched `node_app_server`'s live
logs for "queue-access" — found the real server-side error NAS itself only logs, never returns to
the client: `Failed to mint CareConnect queue-access token for booking 281 404 { message: 'Booking
not found' }`. Traced the actual chain via a one-off read-only `pg` query against NAS's production
DB (booking 281: `status='Request to Cancel'`, `status_code=9`, `handled_by='CARECONNECT'`,
`remarks='Booking rejected: Requested time is outside the doctor's clinic hours'`) plus a read of
CareConnect's webhook route:
  - Booking 281 was originally rejected by CareConnect at creation time (422, outside clinic
    hours) — CareConnect's webhook route returns that error *before* ever calling
    `prisma.booking.create` (`SQ_CareConnect/app/api/webhook/booking/route.ts:184-232`), so nothing
    was ever persisted on CareConnect's side for it. NAS still correctly recorded
    `handled_by='CARECONNECT'` + the rejection reason — that part is correct bookkeeping.
  - Something later called NAS's `/cancel-booking` (`app.js:2175`) on this same already-rejected
    booking. That route unconditionally does `UPDATE booking SET status_code=9, status='Request to
    Cancel'` with no guard against re-touching an already-terminal booking — it overwrote `status`
    from `'Cancelled'` back to `'Request to Cancel'` without touching `remarks`. **Flagged to the
    user as a separate, un-fixed backend gap** — not touched this session, since the client-side
    fix below already resolves the visible symptom.
  - `home_dashboard.dart`'s `_activeQueueBooking()` filter only excluded the literal strings
    `"cancelled"`/`"completed"` — `"request to cancel"` doesn't match either, so this dead booking
    kept qualifying for the "My Active Queues" card and its now-permanently-broken "View Status"
    button. `my_booking.dart`'s own list already used a broader substring check that would have
    caught it; the two files disagreed.
  - **Fix**: rewrote `_activeQueueBooking()` to use the same substring classification (`cancel` /
    `declin` / `reject` / `complet` / `served`) as `my_booking.dart`'s `_statusKind`, so any
    terminal-status booking is excluded regardless of exact wording. `flutter analyze` clean (4
    pre-existing style infos, nothing new). Hot-restarted on the Oppo and confirmed visually: the
    "My Active Queues" card for booking 281 is gone; Home now shows only the generic "Manage Your
    Bookings" card, matching "View all"'s (already-working) behavior.

**11. Committed and shipped everything from today.** Bumped `versionCode`/`versionName` to
`54`/`"48.0.6"` in `android/app/build.gradle`. Committed all of today's real changes — the
`my_booking.dart` verbose status detail, the `_activeQueueBooking()` fix, the `minSdkVersion 23`
pin, and the `fluttertoast` downgrade — as `70006b6` on `fix/android-15-compliance`. Built a signed
release AAB (`flutter build appbundle --release`, real upload keystore, 35.7MB, only a routine
"no debug symbols uploaded" advisory). Device-support count actually *improved* vs. the prior
release (13,340 vs. 12,306 total, +1,034 newly supported, 0 lost) since minSdk dropped 24→23.
Submitted `54 (48.0.6)` to Open Testing via Play Console (account `vicsq10809@gmail.com` — the
extension kept defaulting new tabs to the wrong Google identity, `vic@smartqsys.com`, which cannot
touch this app; had to have the user manually switch accounts in a browser tab already
authenticated correctly, since account sign-in isn't something to automate). Left two unrelated
pending items on Play Console's Publishing overview completely untouched, as intended: v53's
already-approved-but-unpublished Open Testing rollout, and the separate v52 (48.0.4) Closed
Testing - Alpha release the user previously decided to leave alone. Pushed `70006b6` to
`origin/fix/android-15-compliance` at the user's request.

**12. User then reported View Status/View All/Manage Bookings all "kept looping trying to
connect," correctly suspecting it wasn't mobile code.** Checked `sq-careconnect`'s Render service
directly: a banner read "Your free instance will spin down with inactivity, which can delay
requests by 50 seconds or more" — confirmed via Settings, Instance Type was **Free**, unlike
`node_app_server`'s already-upgraded Starter plan. Root cause: every one of those three features
routes through NAS calling CareConnect server-to-server with an 8-second `AbortController` timeout
(`callCareConnectWebhook`, `/bookings/:bookingId/queue-access`, `/careconnect/manage-bookings-link`
all share this constant) — always shorter than a 50s+ cold start, so whenever CareConnect had spun
down, all three failed identically and retrying just re-raced the same timeout. This also almost
certainly explains the older, previously-unresolved "intermittent latency on `node_app_server`/
`ccuser.smartqsys.com`" item carried in `pending_work.md` since before this session — never
traced to the Render plan setting until now. **User upgraded `sq-careconnect` to Starter** (a
billing decision left entirely to them). Verified the fix directly: `curl` against CareConnect's
base URL went from ~7.8s to consistently <1s across 3 consecutive requests post-upgrade.

**13. User reported the CareConnect upgrade didn't fully fix it — WebView still spins on a blank
white page for ~1 minute before displaying, on every attempt, surviving a logout/login *and* a
full device power cycle.** That ruled out both the (already-fixed) backend cold-start theory and a
transient memory-pressure theory. Root-caused for real this time by clearing `adb logcat`, having
the user reproduce it live, then filtering the dump to the app's actual PID (`pidof
com.smartqsys.sq_notification`) instead of the unfiltered buffer (which had been dominated by noise
from other apps, including a red-herring pass that misread normal Chrome sandboxed-process
recycling as evidence of a crash loop). The real signal:
```
E/WebViewLibraryLoader: can't load with relro file; address space not reserved
E/system/bin/webview_zygote32: Failed to make and chown /acct/uid_99006: Permission denied
```
This is a known Android bug class: normally the OS pre-loads WebView's native libraries into a
shared RELRO (relocation-read-only) memory region once, and every new renderer process just maps
it — fast. On this device that shared region can't be reserved (paired with a permission failure
on an `/acct` cgroup accounting path), so **every single WebView renderer process cold-loads and
relocates its native libraries from scratch** instead of reusing the cache — slow enough on this
device's modest, older MediaTek/ColorOS hardware to produce almost exactly the observed ~1-minute
delay, consistently, on every attempt. Confirmed this is genuinely device/firmware-level, not
app or backend code: the API mint calls stayed fast (896ms, 982ms, 1376ms across three separate
attempts) the entire time.

**14. Checked two possible on-device remediations — both dead ends.** Developer Options → "Set
WebView implementation" showed only two entries: Android System WebView 70.0.3538.110 ("Disabled
for user Owner", unselectable) and Chrome 138.0.7204.180 (already selected, the only real option)
— nothing to toggle between. Attempting to check Chrome for a pending Play Store update hit a
purchase-verification (biometric/password) setup screen — correctly left for the user to handle,
not something to automate through. Concluded this is best treated as a known limitation of this
specific physical test device rather than something further reachable from this session.

**15. Compared against the iOS implementation to see if this needs an iOS-side fix too — it
doesn't, by construction.** `WebViewPage` (`get_ticket.dart`) is a single shared Dart widget using
`flutter_inappwebview`'s `InAppWebView`, same code path on both platforms; on iOS it's backed by
Apple's WKWebView, not Android's Chrome-based WebView. RELRO/shared-library relocation and the
`webview_zygote`/`/acct` cgroup mechanism that failed here are Linux/Android-specific OS
constructs with no iOS equivalent — WKWebView's process model can't hit this failure mode at all.
**No iOS-side action needed for this specific bug.** Worth a real check whenever iOS testing
resumes: `onRenderProcessGone` (the Android callback this widget's retry UI depends on) needs its
iOS analog (WKWebView's content-process-termination event) verified to actually fire the same
retry path — `flutter_inappwebview` supports both, but this session had no way to confirm it from
Windows.

**16. User asked whether the app has a force-update-on-launch feature — it did, but was dead
code.** Traced `lib/api/dio.dart`'s `_checkForUpdate`: a Dio interceptor firing on every API
response, comparing the installed version against `minimum_version_android`/`minimum_version_ios`
fields NAS's global auth middleware (`auth.js`) attached to every authenticated response, sourced
from two tiny helper files. Both were hardcoded static strings — `"21.0.3"` (Android) and `"1.0.3"`
(iOS) — that had apparently never been touched since written. Since version comparison checks the
major number first, `48 > 21` (and iOS's real `MARKETING_VERSION = 2.0.1` > `1.0.3`, confirmed by
reading `ios/Runner.xcodeproj/project.pbxproj`) short-circuited to "no update needed" every time —
this gate has likely never fired for a real user on either platform.

**17. Redesigned it as a manual boolean kill-switch instead of a version comparison, per user
direction, then wired it into two deliberate re-entry points instead of firing on every API call.**
Key insight from the user: this backend has no way to know which Play Store/App Store *track*
issued a given install, so any version-comparison approach risks force-blocking users on a track
that hasn't caught up yet — confirmed this was a real risk by checking Play Console directly
(Production was still on version 47 while Open Testing had just shipped 54, an 11-month gap).
Replaced `checkMinimumVersionAndroid.js`/`checkMinimumVersionIos.js` with
`checkForceUpdateAndroid.js`/`checkForceUpdateIos.js`, plain booleans off by default, driven by new
`FORCE_UPDATE_ANDROID`/`FORCE_UPDATE_IOS` env vars — documented in `.env.example`, never set to
`true` in production. Second refinement, also from the user: don't rely on a "shown once per app
session" flag, since a long-lived app process that never restarts could go days without
re-checking. Client-side (`dio.dart`) now just caches the two flags from every response (cheap, no
dialog fires from there) and exposes `DioConfig.maybeBlockForForceUpdate(context)`, called
explicitly at exactly two points the user named: the New Booking quick action's tap handler, and
`_openManageBookings()` (the one shared function behind the Manage Bookings card, "View all", and
Appointments) right after each fresh response — so even a session that never restarts gets gated
at the moments that actually matter.

**18. Shipped and verified end-to-end on the physical Oppo, catching a real mistake along the
way.** First deploy attempt: flipped `FORCE_UPDATE_ANDROID=true` on Render, redeployed, tested on
device — no dialog fired. Root cause: the backend code changes had only been edited locally, never
committed or pushed, so Render's redeploy just rebuilt the same old `minimum_version_*` logic
against the new (unread) env var. Committed properly this time (`921154c` on `node_app_server`,
pushed to **both** `main` and `peer-notification` — Render deploys from the latter, this project's
own recurring gotcha) and redeployed for real. Confirmed on-device: `FORCE_UPDATE_ANDROID=true` →
tapping New Booking shows an undismissable "Update Required" dialog; flag removed and redeployed
→ New Booking navigates normally again, zero behavior change. Left the env var unset (off) in
production after testing.

**Session ends here with a clean, fully-shipped Android side, one real infrastructure bug fixed,
one real device-limitation root-caused, and a dead feature revived and verified working.** Nothing
outstanding from today is uncommitted or unpushed, across all three repos touched
(`sq_appt_app_2`, `node_app_server`, and this docs repo). The natural next step is the iOS
equivalent — see `pending_work.md` and `IOS_HANDOFF.md` for what the Mac-side session needs to
pick up to get a TestFlight build out, including wiring `FORCE_UPDATE_IOS` the same deliberate way
once there's an actual TestFlight release to point users at.

---

### 2026-08-17 — Production incident hotfix, Settings logout fix, My Active Queues/CareConnect routing, Android v53 submitted to Open Testing

**Context:** A dense session covering a real production outage hit mid-testing, a routing/UX fix
with a genuine cross-repo CareConnect feature behind it, and a version submission — plus Mac-side
work landing concurrently on the same branch.

**1. RESOLVED a real production incident: `node_app_server` connection-pool exhaustion.** Surfaced
while testing the logout fix on a physical Oppo device — real login attempts started failing with
500s ("Failed to login", "Failed to fetch cities", "Failed to mint badge token") both from the app
and via direct `curl`. Diagnosed by running NAS locally against the live DB: login logic itself was
fast and correct, isolating the bug to the live Render process's connection pool. Render logs
confirmed `pg-pool` "timeout exceeded" across every DB route — the whole pool (`max: 10`) was
exhausted. Root cause: 30 of 34 `pool.connect()` call sites in `app.js` released the client only on
the success path, never in `catch` — any thrown error permanently stranded a connection. Fixed all
30 with `try/finally` (commit `61e857b`), pushed to both `main` and `peer-notification` (Render
deploys from the latter). Verified locally by firing 15 consecutive error-triggering requests
(more than pool max) with no exhaustion. Confirmed live: login latency dropped from ~26.6s
timeouts to 0.79s. Bundled in the same commit: the previously-uncommitted
`reconcileOrphanedBookings()` sweep, which Render logs showed was already running in production
regardless of local uncommitted status.

**2. Fixed Settings' Logout routing to New Registration instead of Sign In.** Same bug in two
places (`home_dashboard.dart`'s app-bar menu, `settings.dart`'s Logout tile) — both called
`SignupPage()` after clearing prefs instead of `LoginPage()`. Fixed both; Delete Account's
same-looking redirect to `SignupPage()` was correctly left alone (different case — account no
longer exists). Committed `aeb9a13`.

**3. Mac-side work landed on the same branch mid-session — merged cleanly, no conflicts.** Real
substantive commits (`93620f8..9b04c47` plus one more): FCM token-refresh wiring to
`POST /update-fcm-token` (closes the long-open iOS push item), `firebase_messaging` → 16.5.0,
simulator arch-mismatch fix, iOS 26 implicit-engine/UIScene adoption, an auth-token
stringify-to-"null" fix, a Settings text-overflow crash fix, standard-encryption-only export
compliance declaration, Settings row ellipsis capping, Home-screen header/badge-card fixes for
small iPhones, routing Appointments through CareConnect's Manage Bookings, and dropping dead-end
account handling now that CareConnect auto-provisions accounts. Also confirms `pod install` was
actually run and succeeded on the Mac (real `Podfile.lock` changes). Pushed `4253247`.
`flutter analyze`: 0 errors, 180 pre-existing style infos/warnings.

**4. Built a real CareConnect cross-repo feature: per-booking "View Status" + Manage Bookings
empty-state redirect.** Found while verifying a specific requirement (Manage Bookings should land
on ccuser home when the patient has zero bookings, unlike Appointments/My Queues) that Manage
Bookings and Appointments shared one indistinguishable code path. Final state: `_ActiveQueueCard`'s
"View Status" now mints a focused `queue-access-token` → lands on that specific booking (`/bookings
?focus=<id>`); a new `MobileSessionToken.source` field (CareConnect migration
`20260817072816_add_source_to_mobile_session_token`) lets CareConnect tell `'manage_bookings'` +
zero bookings apart from other cases, redirecting to ccuser home only for that combination. Pushed
across `SQ_CareConnect` (`754823b`), `node_app_server` (`12aaf7d`, both `main`/`peer-notification`),
`sq_appt_app_2` (`7b7ab30`). Same commit carries a City-dropdown fix
(`isExpanded: true`). **Not yet visually confirmed on a physical device** — no active
CareConnect-routed booking existed in the test account at the time.

**5. Data bug found: `vicdlr@gmail.com` (id=133) has `city="Cebu ph"` in `mdevice`, should be
"Metro Manila".** Root-caused a real "Healthcare doesn't show up in New Booking" complaint —
`home_provider.dart` filters Industry/Organisation/Unit by the user's city, and Cebu ph only has
Finance/Government in the `industry` table. **Not yet fixed** — the DB correction was identified
but never run.

**6. Fixed ccuser's My Bookings page never showing the captured image for Data Capture bookings**
(the data was already flowing correctly through Cloudinary/webhook end-to-end — ccuser's own
`/bookings` page just never fetched/displayed it, unlike ccadmin's two already-working views).
Added `serviceType`/`capturedImageUrl`/`capturedText` to `/api/bookings/mine` and a matching
"Captured Document" section to `BookingCard`. `tsc`/`eslint` clean. **Not committed, not visually
confirmed** — no real Data Capture booking existed locally to check against.

**7. Submitted Android version 53 (48.0.5) to Open Testing — pending Google review as of session
end.** Bumped `versionCode`/`versionName`, built a signed release AAB with all of the session's
mobile fixes, uploaded via Play Console, and resumed the Open Testing track (found paused).
Bundled with resuming the track into one review cycle. A real device-support drop was flagged
during review (2,081 fewer devices vs. the track's stale prior release) — expected, not a
regression; that track just hadn't been through the Android 15/16 compliance push yet. Deliberately
left untouched: a separate pending Mac release (`52`/`48.0.4`) sitting "Ready to publish" in Closed
Testing - Alpha.

**8. Confirmed this session's Windows Chrome browser identity via memory** (`b9a80ca0-...`,
"Browser 2") — no re-verification needed going forward.

**Session ended here.** Carried into the next session: the My Active Queues visual/device
confirmation, the Cebu ph DB fix, the Data Capture image fix commit, and Android v53's review
outcome — see `pending_work.md`.

---

### 2026-08-16 — Located and identified the correct Android release keystore for Mac handoff

**Context:** `WINDOWS_KEYSTORE_TRANSFER.md` (in this repo) documented an unfinished task — the Mac
checkout of `sq_appt_app_2` (branch `fix/android-15-compliance`) needs to produce a signed release
build but has no keystore locally; the real signing files exist somewhere on this Windows machine.

**1. Confirmed the files and resolved the `storeFile` path.** User pointed to
`C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`. Found `android\key.properties`; its
`storeFile= keystore.jks` resolves relative to the **`android/app/`** module directory (Gradle's
`file()` call inside `build.gradle`'s `signingConfigs` block is relative to the module dir, not the
`android/` root), matching `android\app\keystore.jks` — not the two files sitting in
`android\app\archived_unused_keystores\` (`releasekey.jks`, `.keystore`), which are clearly marked
unused.

**2. Broader search surfaced a real ambiguity — flagged rather than guessed.** A search across
`AndroidStudioProjects` turned up two more `key.properties` files: `sq_notification_app` (a
different app, ruled out) and `sq_app_release`. `sq_app_release`'s keystore (`.keystore`, dated
March 2024) is a genuinely different file by hash and size from `sq_appt_app_2`'s `keystore.jks`
(dated May 2025) — not a duplicate. Per the transfer doc's explicit instruction, asked the user
rather than picking one silently (wrong upload key = Play Store rejects the release). **User
confirmed `sq_appt_app_2`'s `keystore.jks` (May 2025) is the correct, currently-used one.**

**3. Transfer method changed from external drive to Zoho WorkDrive — drive-staging steps in
`WINDOWS_KEYSTORE_TRANSFER.md` were not executed.** No external drive was ever plugged in (checked
`Get-Volume`, only fixed drives `C`/`D`/`E` present). User opted to upload the two files directly
via Zoho WorkDrive instead. Gave Mac-side placement paths: `key.properties` → `android/key.properties`,
`keystore.jks` → `android/app/keystore.jks` (both relative to the `sq_appt_app_2` checkout root on
the Mac).

**Session ended here.** Still open: confirm the two files actually land on the Mac side and that a
signed release build succeeds using them — see `pending_work.md`.

---

### 2026-08-15 — Closed Testing release confirmed live; built a standalone tester-notification emailer

**Context:** Follow-up to 2026-08-13's Closed Testing submission. Confirmed the release actually
went live, then built real tooling in response to a real gap the user hit trying to tell testers
about it.

**1. Confirmed `50 (48.0.2)` cleared Google Play review and is published.** Checked Play
Console's Publishing overview directly: moved from "Changes in review" to "Changes ready to
publish," clicked and confirmed "Publish changes" (the "This can't be undone" dialog), and
verified "Last published on August 14, 2026" afterward. Also confirmed on Policy status: the
stale "Data safety section removed" flag from earlier sessions is gone. The two remaining Policy
status warnings (16KB page size, target API 35+) are tied to the still-outdated **live
production** version (47), not this closed-testing release — expected, not a regression.

**2. User asked why closed testers hadn't been notified about the new release — root-caused to a
real Play Console gap, not a bug.** Checked the Closed Testing - Alpha track's Testers tab
directly: 16 real testers are correctly configured via an email list, release is genuinely
"Available to selected testers." The actual answer: **Google Play Console has no feature to
notify closed-testing testers about a new release at all** — unlike TestFlight, which does this
automatically. Testers only find out via the Play Store app's own update-checking (auto-update,
or manually checking "Manage apps & device"), so there's no way around messaging them directly.

**3. Built `node_app_server/notify-testers/`, a reusable standalone emailer for this.** Sends via
the same Zeptomail SMTP account (`notifications@smartqsys.com`) that `app.js`'s
`Sendemail`/`SendResetEmail`/`sendTemplatedEmail` already use — pulled the credentials into
`node_app_server/.env` (gitignored) instead of adding a fourth hardcoded copy. One script handles
both platforms: `node notify-testers/send.js --platform android|ios --version X --notes "a|b|c"`,
with `--dry-run` to preview and `--only <emails>` to resend to specific addresses. Retrieved the
real 16 tester emails from Play Console's Testers tab (`testers-android.json`); `testers-ios.json`
is an empty placeholder since no TestFlight build exists yet. Committed and pushed (`d1b02b8`).
Standalone for now — the user's stated plan is to fold it into `SQ_APP_Manager` once that grows a
UI for this; the tool's own README documents current limitations (hand-maintained tester lists,
no send history, one-at-a-time sending).

**4. Used it for real, and the retry logic it gained wasn't theoretical.** First send to all 16
testers hit a transient DNS timeout (`queryA ETIMEOUT smtp.Zeptomail.com`) on 12 of 16 — added
retry-with-backoff (3 attempts) to the script on the spot, then resent to just the 12 failures via
the new `--only` flag. One of the 12 needed the retry logic for real, succeeding on attempt 3, the
other 11 sent clean. **All 16 testers confirmed sent the `48.0.2` announcement.**

**Session ended here**, switching to `SQ_APP_Manager`. Still open going into next time: the
edge-to-edge visual audit (blocked on an unresolved emulator keyboard quirk since 2026-08-12),
verifying `pod install` on macOS after the iOS deployment-target bump, and the iOS FCM
token-refresh client wiring — see `pending_work.md` for the full carried-forward list.

---

### 2026-08-13 — Finished the API 36/16KB compliance push, submitted `sq_appt_app_2` to Google Play Closed Testing, and refreshed the iOS handoff

**Context:** Continuation of 2026-08-12's suspended API 36 compliance push, but picked up cold in a
new session — which immediately repeated the 2026-08-09 mistake of building/installing from the
docs-only `D:\Claude\sq_appt_app` checkout instead of the real `sq_appt_app_2` code. Corrected
after the user flagged it, then carried the compliance push all the way through to an actual
Google Play submission, plus a pass on iOS handoff prep.

**1. Repeated, then fixed, the docs-workspace-vs-real-checkout mistake.** Built and installed the
app on the Oppo `CPH1909` straight from `mobile-redesign` without checking
`.claude/projects/sq_appt_app.md` first — despite that file already documenting this exact
mistake from 2026-08-09. User correctly identified the installed app as "the old app." Confirmed
via `git log mobile-redesign..origin/feature/redesign-2026` that `mobile-redesign` is missing
~20 redesign commits. Rebuilt from the real checkout (`C:\Users\vic\AndroidStudioProjects\
sq_appt_app_2`, branch `fix/android-15-compliance` — a superset of `feature/redesign-2026`'s tip
plus `b443ae8` notification fixes and `fc9a877`'s version-code fix) and confirmed correct.
Strengthened both `KNOWLEDGE_BASE.md` and the project notes file to flag the recurrence.

**2. Committed the API 36 toolchain bump and finished the compliance push.** `06a0219`: Gradle
7.5→8.14.2, AGP 7.4.2→8.11.1, Kotlin 1.8.22→2.0.21 (later 2.2.20, see #3), Java 8→17,
compileSdk/targetSdk 34→36, `device_info`→`device_info_plus` migration — all tested via a
successful on-device build/install before committing. `versionCode` bumped 48→49 (`48.0.1`)
separately, since 48 was already consumed by a stale, never-submitted draft release sitting in
Play Console's Closed Testing - Alpha track.

**3. Found and fixed a real 16KB memory page-size compliance gap.** Play Console flagged the
build against Google's 16KB memory page-size requirement (enforced since Nov 1 2025, found via
Policy status, not caught by any local tooling). Extracted the `arm64-v8a` `.so` files from the
built AAB and checked LOAD segment alignment directly with the Android NDK's `llvm-readelf` —
`libbarhopper_v3.so` and `libimage_processing_util_jni.so` (Google ML Kit/CameraX, bundled via the
`mobile_scanner` plugin used for the Get Ticket QR scanner) were 4KB-aligned, not 16KB. Root cause:
`mobile_scanner` was pinned to `3.5.6`, three major versions behind; `6.0.11` is the version that
updated CameraX for 16KB support. Upgrading to `6.0.11` cascaded into: a Kotlin Gradle plugin bump
to `2.2.20` (the version `mobile_scanner` 6.0.11 itself pins) — which also required killing stale
Gradle 7.5/Kotlin 1.8.22 daemon processes left running from before this session's toolchain
upgrades, since `flutter clean` alone didn't invalidate them; and a `TorchState` API break in
`get_ticket.dart` (`controller.torchState` → `controller.value.torchState` via `ValueNotifier`,
plus new `.auto`/`.unavailable` enum cases the exhaustive `switch` needed to handle). Re-verified
16KB alignment via `llvm-readelf` after the fix (all LOAD segments now 0x4000/16KB or larger) and
confirmed the scanner still works on the physical Oppo before committing (`1d019eb`, `versionCode`
49→50/`48.0.2`).

**4. Submitted `50 (48.0.2)` to Google Play Closed Testing - Alpha, and hit a real Play Console UX
trap along the way.** Data Safety form turned out to already be fully and correctly declared
(Device or other IDs, name/email/phone/photos all "Completed") — the "Data safety section
removed" policy flag against production (version 47) was stale, from before an earlier session's
fix, and not something this session needed to touch. Clicking "Submit N changes for review" the
first time only ran Play Console's asynchronous pre-review "quick checks" — Publishing overview
silently reverted to "not yet submitted" once those finished, with the same Submit button still
sitting there unclicked. Caught this on a deliberate follow-up check rather than assuming success;
the second click produced the real "Send N changes for review?" confirmation dialog, and
Publishing overview then correctly showed "Changes in review." **Google's review was still
pending as of session end — not yet confirmed whether it clears, or whether the stale Data Safety
flag actually resolves once it does.**

**5. Rewrote `IOS_HANDOFF.md` and fixed one iOS build-breaker in advance.** The 2026-08-08 version
pointed at `feature/redesign-2026`, now behind `fix/android-15-compliance`. New version documents
that `node_app_server`'s `main` and `peer-notification` are confirmed in sync and deployed
(closing out the old "not deployed yet" caveat on `/service-options`), and that the iOS-side FCM
token-refresh wiring genuinely still isn't done — read `notification.dart` directly and confirmed
`onTokenRefresh`'s listener only logs, never calls `POST /update-fcm-token`. Also proactively fixed
`mobile_scanner` 6.0.11's iOS fallout: its podspec requires `platform :ios, '15.5.0'`, but
`ios/Podfile` was still at `13.0` and the Xcode project's `IPHONEOS_DEPLOYMENT_TARGET` was a mix of
`12.0`/`15.0` — bumped both to `15.5` (`93620f8`), done blind from Windows since no
Xcode/CocoaPods is available here; needs a fresh `pod install` on macOS to actually verify.

**6. Pushed both repos to origin.** `sq_appt_app_2`'s `fix/android-15-compliance` (new branch on
the remote, all of #1–#5's commits) and this docs checkout's `mobile-redesign` (`IOS_HANDOFF.md` +
`pending_work.md` only — left `DEVLOG.md`'s then-uncommitted state, some auto-regenerated plugin
registrant files, and several untracked screenshots alone rather than sweep them into an unrelated
commit).

**Session ended here.** Next steps: confirm the Play Console review outcome; pick up iOS testing
per the refreshed handoff doc (`pod install` first, then the FCM token-refresh wiring); resume the
still-unfinished edge-to-edge visual audit from 2026-08-12 whenever a device/emulator session is
available again.

---

### 2026-08-12 — Started Android 15 / API 35 compliance push on `sq_appt_app_2`; blocked mid-session by `C:` drive filling up

**Context:** Separate `Node_tests` session (not this repo's usual working directory) started prepping `sq_appt_app_2` (checked out independently at `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`, branch `fix/android-15-compliance` — distinct from this `D:\Claude\sq_appt_app` checkout's `mobile-redesign` branch) for Google Play's requirement that new apps/updates target **API level 36 (Android 16)** by **2026-08-31** (confirmed via Play Console docs — existing apps not being updated only need 35 as a floor, but updates need 36). Task sequence: install current Flutter stable + Android SDK Platform 35/36, trial-build against the old `targetSdkVersion` 34 first, then bump to 36, fix edge-to-edge rendering, verify 16KB page-size compliance, device regression pass.

**1. Installed a fresh Flutter stable SDK to `C:\flutter_stable_2026` and Android SDK Platform 35 — both completed successfully.**

**2. Trial build against API 34 repeatedly failed — root cause turned out to be disk space, not the SDK bump.** After several build attempts (`build_trial.log` through `build_trial10.log`), `flutter build apk --debug` failed with Gradle's `java.io.IOException: There is not enough space on the disk` (during `l8DexDesugarLibDebug`/`compileDebugKotlin`), then a Dart VM `Out of memory` crash on retry. `df -h` confirmed `C:` at 327MB free out of 475GB. **Gotcha: the background task runner's completion summary claimed "exit code 0" for this run — the actual log clearly shows `BUILD FAILED`. Don't trust the summary line; always check the log.**

**3. Disk survey found several easy wins plus one structural issue:**
- `C:\flutter_windows_3.24.3-stable.zip` (985M) — old installer archive, safe to delete.
- `C:\fluttera_old` (3.2G) and `C:\flutter` (2.7G) — likely superseded by the new `C:\flutter_stable_2026` (confirmed as the active SDK via the build log's `flutter.bat` path), but not yet verified unused before the session got redirected.
- `C:\Users\vic\.gradle\caches` (12G) — will keep regrowing and refilling `C:` even after a one-time cleanup unless `GRADLE_USER_HOME` is relocated.
- `D:` has 708G free. User's explicit direction: move large dev files (Flutter SDK, Gradle cache, and/or the project checkout itself) to `D:` rather than keep working on an almost-full `C:`.

**4. Also noted while investigating**: `D:\Claude\sq_appt_app` (this checkout) and `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` are two separate, both-legitimate checkouts on different branches (`mobile-redesign` vs. `fix/android-15-compliance`) — not duplicates.

**Session interrupted here** before the disk cleanup / `D:` relocation was carried out. Full detail and next steps in `pending_work.md`'s "BLOCKING: `C:` drive nearly full" item.

---

### 2026-08-12 (cont.) — Resolved the disk-space block and bumped `sq_appt_app_2` to API 36; hit an unresolved emulator keyboard quirk mid edge-to-edge audit; iOS push root-caused and fixed server-side; added the Play Console account-deletion page

**Context:** Continuation of the same day's `Node_tests` session, resuming the Android 15/16 compliance push after the disk-space block above, then a separate detour into finishing the iOS push investigation from 2026-08-11 and a fresh Play Console compliance ask (account-deletion page).

**1. Disk-space block resolved durably, not just cleaned up once.** Root cause both times was `C:` filling up (Gradle/emulator both need multi-GB headroom). Deleted confirmed-unreferenced `C:\flutter` (2.7G) and `C:\fluttera_old` (3.2G) old SDKs (verified unused via PATH, both projects' `local.properties`, `.idea` library XML, and VS Code settings first). Relocated the ~12.9G Gradle cache from `C:\Users\vic\.gradle\caches` to `D:\AndroidDev\gradle_home\caches` via `robocopy /E /MOVE` — **must run robocopy from PowerShell, not Git Bash** (Git Bash's MSYS path-conversion mangles `/E` into a bogus `E:/` path and the copy silently no-ops) — and **stop any running Gradle/Kotlin daemons first** or robocopy can't move locked files. Set `GRADLE_USER_HOME`/`ANDROID_AVD_HOME` persistently via Windows User environment variables (new processes only — an already-running shell doesn't pick them up retroactively). `C:` free space went 327MB → 18G; `D:` has 692G free after the move.

**2. Bumped `sq_appt_app_2/android/app/build.gradle`'s `targetSdkVersion` 35 → 36** (`compileSdkVersion` was already 36) and rebuilt clean — `app-debug.apk` now targets 36. **Still uncommitted.**

**3. Installed an API 36 Google Play emulator (`API36_EdgeToEdge` AVD, pixel_6 profile) under `D:\AndroidDev\avd`** — needed because the only physical device available (Oppo/OnePlus `CPH1909`) runs Android 8.1 (API 27), far too old to exercise edge-to-edge (only enforced on API 35+), and the pre-existing `SmartQ_Test` AVD only had system images through API 34. Installed the API 36 build on both the new emulator and the physical Oppo.

**4. Started the edge-to-edge visual audit; static code audit done, live pass blocked by an emulator keyboard quirk, not yet resolved.** Static audit: `MainActivity.kt` is a bare `FlutterActivity` with no overrides, no `SystemChrome`/`SystemUiOverlayStyle` usage in `lib/`, stock Flutter themes — nothing opts out, and Flutter 3.44.9 auto-enables edge-to-edge for API 35+. 10 of 15 `Scaffold` screens have no `SafeArea` (flagged in `pending_work.md`) and are the likely trouble spots once verified visually. Live pass got sidetracked before reaching any of them: text fields on the fresh AVD showed only a narrow floating assist strip instead of the full QWERTY keyboard, for both password and non-password fields alike (ruling out a field-type-specific app bug). Tried disabling Google Autofill (no change) and clearing Gboard's state via `pm clear` (surfaced a first-run stylus-tutorial sheet that itself blocks the keyboard, but that's a side effect of the clear, not proof of the original cause). **Root cause not confirmed** — two untested theories (Gboard first-run onboarding queue vs. a `pixel_6` AVD input-config quirk). Session suspended with the tutorial sheet still on-screen, undismissed.

**5. iOS push notifications — root-caused and fixed server-side.** Root cause was a stale `mdevice.fcmtoken`, not an APNs/config problem — all five send paths from 2026-08-11's investigation were "succeeding" against a token already stale in the DB. Confirmed by pulling the live token straight off the device and resending — arrived immediately. `node_app_server` commit `92c480d` added `POST /update-fcm-token` (lightweight authenticated endpoint to push a refreshed token) and made `/send-notification` detect `messaging/invalid-registration-token` / `-not-registered` / `invalid-argument` and auto-clear the dead token instead of silently "succeeding." **Flutter-side wiring is still not done** — the app needs to call `/update-fcm-token` from `onTokenRefresh` and defensively on every launch/foreground, since `/login` never touches `fcmtoken`; until that lands the DB token can go stale the same way again.

**6. Added a public account-deletion disclosure page for Google Play's Data Safety declaration.** Play requires a publicly-reachable URL (not an in-app-only flow) describing account-deletion steps and what data is deleted vs. retained. `node_app_server` commit `10c4089` added `public/delete-account.html`, live at `https://node-app-server.onrender.com/delete-account.html`. The existing in-app flow (Settings → Delete Account → `DELETE /users/:userId`) only removes the `mdevice` row — booking/notification rows are retained and disassociated, not deleted — the page documents that distinction accurately rather than overclaiming.

**7. Commits/deploy status confirmed via `git fetch`:** `node_app_server` `main` and `peer-notification` are both at `10c4089` on the remote (`origin/peer-notification` already fast-forwarded — the FCM-refresh fix and the account-deletion page are both live on Render). `sq_appt_app_2`'s `targetSdkVersion` 35→36 bump remains uncommitted, alongside the pre-existing uncommitted `notification.dart`/`home_provider.dart` fixes from 2026-08-11.

---

### 2026-08-11 — Deep-dive on "notifications not arriving" for both patients and service providers; root-caused Android, iOS still open

**Context:** Started as a detour from Play Store Internal Testing setup ("Xflight equivalent for Android") — user reported neither push nor email notifications reliably arriving for either patients or service providers. Investigated live using the physical Oppo/OnePlus `CPH1909` (Android, connected via `adb`/USB) and a real iPhone, both freshly registered (`vicdlr@gmail.com` / Android, `vic@smartqsys.com` / iOS) against production (`node_app_server` on Render, Firebase project `sqnotification`).

**1. Email notifications: confirmed working.** Fresh registration produced both the verification email and, after tapping the link, the Welcome email — `Sendemail`/`sendTemplatedEmail` in `node_app_server/app.js` both fired correctly. Not investigated further; no evidence of a real email problem.

**2. Android push — root-caused: OS-level suppression due to a missing notification channel, not a code/server bug.**
- Wrote a one-off script (`node_app_server/_test_push_vicdlr.js`) using the Admin SDK directly against the real DB (`mdevice` table) to bypass the app entirely — confirmed FCM credentials, project (`sqnotification`), and both test accounts' stored `fcmtoken` values are all valid; every server-side send attempt returned success.
- `adb shell dumpsys notification --noredact` showed the pushes *were* being posted to the device, but two things were wrong: (a) they land on Firebase's `fcm_fallback_notification_channel`, not the app's intended `booking_updates` channel, and (b) `post_frequency` showed `muted=3/3` — every notification from this app is being suppressed by the OS.
- Root cause confirmed via live `flutter run` logcat: `W/FirebaseMessaging: Notification Channel requested (booking_updates) has not been created by the app` + `Missing Default Notification Channel metadata in AndroidManifest`. The Flutter app (`sq_appt_app_2`, `lib/notification/notification.dart`) only ever creates a channel reactively inside the foreground `onMessage` handler — never pre-creates `booking_updates` at startup — so any background/killed-app delivery has nothing valid to post to, and ColorOS mutes the fallback.
- **The fix already exists and is unmerged**: branch `fix/notification-channel-and-tap-handling` in `sq_appt_app_2`, commit `4edf223` ("Pre-create booking_updates notification channel; sort My Bookings descending"). Not yet merged into `feature/redesign-2026`. Ruled out a SIM/connectivity theory along the way — confirmed via `adb shell dumpsys connectivity` that the test device had a fully validated WiFi connection throughout (push notifications don't need a SIM at all).

**3. iOS push — NOT root-caused; needs Mac/Xcode access this environment doesn't have.**
- Spent significant time just finding the right Firebase Console project: `sqnotification` is confirmed correct (both `google-services.json` and `GoogleService-Info.plist` declare it, and every successful Admin SDK send returned a `projects/sqnotification/messages/...` ID). Two decoy projects exist and are **not** relevant — `sqapp-2513c`/`sqapp1`, holding a stale Android app registered under the never-renamed placeholder package `com.example.sq_notification`. Access to `sqnotification` itself wasn't available under `vicsq10809@gmail.com`, `vic@smartqsys.com`, or a third "Work" account — eventually found under `vicdlr@gmail.com` (account index `/u/2`).
- Under `sqnotification` → Cloud Messaging, found **two** Apple apps registered: a stray `com.sq.sqNotification` and the real `SQ Appt App` (`com.smartqsys.sqapptapp`). The real app has both Development and Production APNs Authentication Keys uploaded (Key ID `FCD8LKZ546`, Team ID `FN232J5K2B` — matches the Apple Developer team from `CLAUDE_BRIEFING.md`). **APNs credentials are not the problem.**
- Tried five independent send paths to the same iPhone token: direct Admin SDK send, a minimal payload with no custom `android`/`apns` blocks (replicating the exact pre-`dd39738` payload shape, before `node_app_server` ever added channel/sound customization), `/send-notification` (service-key auth), `/send-to-peer-notification` (user-JWT auth), and Firebase Console's own "Send test message" tool. All reported success server-side; **none confirmed arriving on the device** except one early, never-reconfirmed claim about the Console tool. Notification permission is confirmed granted on the phone; it's a real device, not a simulator.
- **Open**: needs someone with the physical iPhone + a Mac with Xcode to check the device's console log (Window → Devices and Simulators) while a push is sent, to see whether iOS is rejecting it (e.g. `BadDeviceToken`) or the app-side registration itself is stale. Also worth checking whether the app currently installed on that iPhone predates the Aug 7 certificate/provisioning-profile fix noted in `CLAUDE_BRIEFING.md`.

**4. Found and fixed an unrelated real bug along the way**: `sq_appt_app_2/lib/view/home/notification.dart`'s empty-notifications state used a hardcoded `EdgeInsets.symmetric(vertical: 300)` inside a non-scrolling `Column` with no `Expanded` — caused a genuine `RenderFlex overflowed by 27 pixels` on the Oppo's screen height (visible as the debug yellow/black banner; would silently clip in a release build instead). Fixed by wrapping the empty state in `Expanded` + `Center` and dropping the fixed padding. **Uncommitted**, alongside the pre-existing uncommitted `home_provider.dart` month-filter fix noted in the 2026-08-10 entry — both still need a rebuild+commit.

**5. Misc findings/gotchas worth remembering:**
- `mdevice.email`, `.date_registered`, and `.auth_token` are fixed-length `CHAR` columns in Postgres — values come back space-padded. `auth_token` in particular **must be `.trim()`'d** before `jwt.verify()` or it fails with "Invalid Token" even for a freshly-issued, otherwise-valid token. Cost real time before being caught.
- `node_app_server`'s local `.env` is missing `CARECONNECT_SERVICE_KEY` (only set on Render) — `SQ_CareConnect`'s local `.env` has the matching `NAS_SERVICE_KEY` value instead, usable as a substitute for local testing of `/send-notification`.
- Confirmed the `reconcileOrphanedBookings()` change flagged in the 2026-08-10 entry is still sitting uncommitted in this local `node_app_server` checkout, untouched this session — still needs the `handled_by IS NULL` row-count decision before it's safe to commit/deploy.
- Left several throwaway diagnostic scripts in `node_app_server/` (`_test_push_vicdlr.js`, `_check_platform.js`, `_get_auth_token.js`, `_inspect_key*.js`, `_test_*.js`) — untracked, safe to delete, not yet cleaned up.

**Session suspended here** at the user's request, mid-investigation on the iOS push issue.

---

### 2026-08-10 — First physical-device testing pass: found and fixed the ccadmin/ccuser routing bug, a WebView renderer-crash bug, plus a round of UI fixes from live feedback

**Context:** resumed from 2026-08-09's one open item — visual on-device confirmation of the new
"Manage Bookings" WebView, which the emulator couldn't reliably confirm. A USB-connected physical
Android device (Oppo/OnePlus `CPH1909`) became available this session, so testing moved off the
emulator entirely. Worked from `sq_appt_app_2`'s `feature/redesign-2026`, rebuilding via
`flutter run -d <device-id>` after each change (no stdin access to the running process from this
environment, so every fix meant a fresh rebuild+reinstall rather than a hot reload).

**1. Root-caused a real bug in the Manage Bookings bridge — bigger than it first looked.** First
on-device tap showed the mint endpoint returning a `careConnectUrl` on `ccadmin.smartqsys.com`
instead of `ccuser.smartqsys.com`. Traced it to `node_app_server`'s Render env var
`CARECONNECT_BASE_URL` being set to `ccadmin.smartqsys.com`. Since CareConnect's `proxy.ts` bounces
any non-`/admin/clinic` path on `ccadmin` back to the clinic-staff login, and **both**
`queue-access-token/consume` and `session-token/consume` redirect to a relative `/bookings` path
on whatever host they were called on, this silently broke the pre-existing "View Queue" button too,
not just the new Manage Bookings card — a regression nobody had caught because prior verification
only checked that consume set a real `cc_session` cookie and issued a redirect, never that the
redirect's host actually resolved to a reachable page. User corrected the env var on Render
(`https://ccuser.smartqsys.com`); confirmed working on-device afterward.

**2. Wrote `D:\Claude\SQ_CareConnect\MOBILE_SYNC_HANDOFF.md`** so the separate Claude session
working in `SQ_CareConnect` (which had already noticed the `MobileSessionToken`
model/migration/route appearing mid-session, per its own `pending_work.md`) had the full picture
without re-deriving it. That session read it, independently confirmed the same root cause from its
side of the code, and logged/committed the finding in its own `pending_work.md` (`3c76b32`) —
real cross-session coordination via a shared handoff doc, not just a one-way note.

**3. Confirmed CareConnect's embedded-WebView nav-hiding is intentional, not a bug.** Initial
on-device report was "ccuser doesn't show its own bottom nav inside Manage Bookings." Traced to
`patient-bottom-nav.tsx`'s `if (embedded) return null` (driven by `?embedded=1`, persisted in
`sessionStorage` per `lib/use-embedded.ts`) — deliberate design from a prior CareConnect session so
the WebView reads as part of the native app rather than a second app-within-an-app. User confirmed
that's exactly the intent ("should behave like part of the mobile app"); no CareConnect-side change
needed.

**4. Found and fixed a real WebView renderer-crash bug.** After the ccuser fix, Manage Bookings
still hung on a spinner past 60s. Device logs showed a genuine Android system-WebView renderer
crash (`aw_browser_terminator.cc: Renderer process crash detected`), preceded by repeated
`NoClassDefFoundError: Landroid/app/UiModeManager$ContrastChangeListener` during WebView init —
this device's system WebView build hitting a real compatibility issue, not a network/backend
problem. `onReceivedError` never fires for a renderer crash, so the (also newly-added, see #6)
loading spinner just spun forever with no recovery path. Added `onRenderProcessGone` handling
(`useOnRenderProcessGone: true`) with a "Retry" button. Underlying device-side cause not fixed —
worth checking that the phone's Android System WebView is fully updated via Play Store.

**5. Investigated intermittent multi-second-to-20+-second latency** on both `node_app_server` and
`ccuser.smartqsys.com` — same routes measured anywhere from <1s to ~21s across repeated curl tests,
with no clean pattern by route complexity (even the plain root page was sometimes slow). Ruled out
Render free-tier cold-start (`node_app_server` is confirmed on the Starter plan, which doesn't
sleep). Most likely explanation is rolling-restart churn from this session's own env-var change and
the several pushes across repos, each of which triggers a Render redeploy — not confirmed via
Render's own dashboard/logs (no access from here). **Not root-caused; worth a real look at Render's
metrics/deploy history if it recurs outside of an active work session.**

**6. UI fixes from live on-device feedback, all in `sq_appt_app_2`**, four commits
(`c477f20`, `d5004eb`, `27eceae`, `9ff4ceb`), pushed to `feature/redesign-2026`:
- Get Ticket QR scan screen: AppBar title was truncating on this device's screen width (now
  shrinks via `FittedBox`); the "Align the QR code within the frame" hint had no explicit
  size/constraints and rendered oversized; its manual-entry action renamed "Enter code manually" →
  "Enter Link manually" (it takes a URL, not a code).
- Contact Us: `mailto:` now stamps the signed-in account's email into the body — `mailto:` can't
  control which of the device's own accounts actually composes the message, so support had no way
  to identify the sender otherwise.
- `WebViewPage` (shared by Get Ticket and Manage Bookings): was showing a blank white screen while
  its page loaded (sometimes for several real seconds, see #5) — added a loading-spinner overlay;
  also had a hardcoded "Ticket Details" title even when opened from Manage Bookings — added a
  `title` parameter, Manage Bookings now passes "Manage Bookings".
- My Appointments now sorts by booking `id` descending (most recent first) instead of raw API
  order — `booking_date` is null for some booking types (e.g. Data Capture), so `id` is the
  reliable recency signal. Note: an old still-unmerged branch in the other checkout
  (`fix/notification-channel-and-tap-handling`, see `pending_work.md`) also touched My Bookings
  sort order — worth checking for conflict/redundancy before merging that branch.
- Bottom nav: "Services" → "Book" (icon kept), then separately "My Queues" → "Notifications"
  (bell icon) — both the bottom-nav tab and Home's matching quick-action card now open the
  existing `NotificationsScreen` instead of the CareConnect-filtered booking list. Removed
  `MyBooking`'s now-dead `filterActiveQueuesOnly` param and its two conditional branches since no
  caller passed `true` anymore. Notifications screen header retitled "Notification" →
  "Notifications". (Notification list was already sorting descending by `sentTime` in
  `home_provider.dart` — no change needed there.)

**7. Found and fixed why bookings produced no in-app notification.** Two separate, independent
bugs, both real:
- `home_provider.dart`'s `getNotificationList` silently filtered the fetched list down to the
  current calendar month only (`sentTime?.month == currentMonth && ...year == currentYear`), with
  no UI indication that's what was happening — anything from an earlier month just vanished,
  which is what made it look like notifications had been lost entirely. Removed the filter.
- `node_app_server`'s `/create-booking` sent its "Booking Received" push via a raw
  `admin.messaging().send()` call that never wrote a row to the `notifications` table — every
  other notification-sending route in that file (`/send-notification`, `/send-to-peer-notification`,
  the CareConnect-driven one) does this after sending; `/create-booking` alone skipped it, so a
  fresh booking could still buzz the phone but would never show up in-app. Fixed to match the
  established pattern. Committed (`0495a7a`), pushed to both `main` and `peer-notification`
  (Render's actual deploy branch), confirmed redeployed.

**8. Root-caused a stuck-at-"Pending" booking despite the clinic's `confirmMode` being `AUTO`.**
Confirmed via ccadmin that CareConnect itself had correctly auto-confirmed *and* auto-checked-in
the booking (`confirmMode=AUTO` + the policy's `noCheckin` both engaged) — so the bug was purely on
NAS's side. `node_app_server`'s `/create-booking` fires `routeBookingToHandler` without awaiting it
(deliberately, so the mobile app doesn't wait on CareConnect's round trip), which means a Render
restart landing mid-flight — and this session triggered several, between the `CARECONNECT_BASE_URL`
fix and the item-7 push above — can silently kill that call before it ever writes
`handled_by`/`status` back onto NAS's own `booking` row, with no error logged anywhere. Wrote a
`reconcileOrphanedBookings()` sweep (re-runs `routeBookingToHandler` for any booking with
`handled_by IS NULL`, at startup and every 10 minutes after) to harden against this — **implemented
but deliberately not committed/deployed yet**: `booking` has no `created_at` column, so the
reconciliation query can't scope itself to "recently orphaned" and would instead reprocess *every*
historically-orphaned row (unknown count, not checked) the moment it first runs, which could
re-send confirmation pushes for old bookings or error on stale unit references. Left as an
uncommitted local change in `node_app_server/app.js` pending a decision on scoping it safely (or
confirming via Database Workbench that the old-row count is actually zero/small). User opted to
just retest with a fresh booking instead, now that no further `node_app_server` deploys are
pending — not yet confirmed as of this writing.

**9. Test-device notes:** the physical Android device (`CPH1909`) has no SIM installed — confirmed
this doesn't block testing (WiFi is enough for both API calls and FCM push, neither needs
cellular). iOS testing remains blocked on connecting to a Mac, unchanged from `IOS_HANDOFF.md`.

**10. Commits**: `sq_appt_app_2` (`feature/redesign-2026`) — `c477f20`, `d5004eb`, `27eceae`,
`9ff4ceb` (UI fixes, item 6) — all pushed. `node_app_server` (`main` + `peer-notification`) —
`0495a7a` (notification persistence, item 7) — pushed and deployed. **Uncommitted as of this
writing:** `sq_appt_app_2/lib/provider/home_provider.dart` (item 7's month-filter removal) and
`node_app_server/app.js` (item 8's reconciliation sweep). No `SQ_CareConnect` code changes this
session (`CARECONNECT_BASE_URL` was a Render dashboard env var change, not a commit).

---

### 2026-08-09 — Root-caused why redesign never went live; badge QR fixed; Badge/Data-Capture/Date-Time pages redesigned; new "Manage Bookings" feature built across 3 repos

**Context:** continuation of 2026-08-08's suspended session, restarting from "emulator needs a
restart" (the literal first ask this session). What followed was a much longer investigation than
expected: the redesign work everyone believed was "committed and pushed" turned out to not
actually be live anywhere, for two compounding reasons neither previous session had caught.

**1. Found this repo (`D:\Claude\sq_appt_app`) is docs-only — the real Flutter code lives at
`C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`.** Built and ran the app from here first,
spent real effort confused why the UI looked like the pre-redesign version, before realizing this
checkout's `mobile-redesign` branch only ever received doc/briefing commits. Documented this
permanently: new `D:\Claude\.claude\projects\sq_appt_app.md`, updated `KNOWLEDGE_BASE.md`'s
project table, and added a general "docs workspace ≠ code checkout" entry to `DEV_GOTCHAS.md` so
this doesn't repeat on another project. Switched to the real checkout
(`sq_appt_app_2`, `feature/redesign-2026`) for everything below.

**2. Root-caused why the badge QR (and Data-Capture instructions) still didn't work after
yesterday's "everything is committed and pushed."** Two real, separate causes, both on
`node_app_server`:
- **Render's `node_app_server` service auto-deploys from branch `peer-notification`, not
  `main`.** All of yesterday's redesign work was pushed to `main`/`feature/redesign-2026`, which
  this service was never watching. `peer-notification` had been stuck at commit `5718f11`
  (Aug 4) the whole time — a "manual deploy" yesterday found nothing new because there genuinely
  was nothing new on the branch it deploys from. Fast-forwarded `peer-notification` to `main` and
  pushed; confirmed live via `about.html`'s `Last-Modified` header changing and its byte size
  matching the restyled version.
- **`BADGE_TOKEN_KEY` was never actually set in Render**, despite `pending_work.md` stating it
  was. Generated a new 256-bit key and added it. Badge QR confirmed rendering live on the Home
  dashboard immediately after.

**3. Found and fixed a real naming-mismatch bug blocking the CareConnect queue-access bridge.**
CareConnect's `lib/nas-service-auth.ts` reads `process.env.NAS_CC_SERVICE_KEY` to verify incoming
`x-nas-service-key` requests from NAS, but Render's `sq-careconnect` service had this var named
`NAS_SERVICE_KEY` (missing `_CC`) — so `verifyNasServiceSecret` always failed with "not
configured," silently breaking the whole bridge. Renamed it on Render (kept the same value) and
copied that value into `node_app_server`'s `NAS_CC_SERVICE_KEY` (also missing before today).

**Real regression from this fix, caught and corrected:** `NAS_SERVICE_KEY` (the name I renamed
away) turned out to *also* be needed under its original name for a completely different,
already-working path — `lib/notify.ts`'s outgoing calls to NAS's `/send-notification` and
`/admin/mdevice/:id/service-provider-flag` (a separate key pair: `x-service-key` header, matched
against NAS's `CARECONNECT_SERVICE_KEY`, unrelated to the `x-nas-service-key` pair above). Renaming
instead of adding likely broke that path silently (best-effort/soft-fail, so nothing crashed, but
push notifications and the service-provider-flag unlock would have quietly stopped working). User
re-added `NAS_SERVICE_KEY` on Render with its original value to restore both paths. **Two
similarly-named but functionally distinct secrets (`NAS_SERVICE_KEY` vs. `NAS_CC_SERVICE_KEY`) —
worth remembering as an easy trap.** Also added `NAS_CC_SERVICE_KEY` to CareConnect's *local*
`.env` (was missing there too, under either name) so local testing works.

**4. Removed non-functional Google/Apple sign-in buttons** from SignIn/SignUp — both only ever
showed "coming soon" toasts, not wired to real OAuth.

**5. Fixed a real navigation bug: "More" tab → black screen.** `SettingsScreen` is reached two
ways — pushed as a standalone route (Badge page's gear icon) and embedded directly as
`bottom_nav_bar.dart`'s "More" tab body (index-swapped, not pushed). Its AppBar's close button
unconditionally called `Navigator.pop()`, which on the "More" tab path popped the bottom-nav
screen itself off the stack. Removed the explicit `leading`, letting Flutter's
`automaticallyImplyLeading` show a back button only when there's actually something to pop back
to.

**6. Redesigned three more screens against their reference mockups**, all verified live on-device:
- Full-screen Badge view (`home_page.dart`) — branded header, scanner-style corner brackets
  around the QR, Secure & Private card, footer. Corrected the mockup's copy (it was actually the
  Get Ticket scan-flow text, mismatched for a screen that displays the user's own badge). Also
  added a real back arrow — there was none at all before.
- Data Capture step (`form_page.dart`) and Date/Time Entry step (`add_booking.dart`) of the
  booking flow — both were plain unstyled forms, rebuilt to match "Enhanced Data Capture page.png"
  / "Date and Time Entry Page.png". Verified against real seeded data (NKTI → In-coming for Data
  Capture; NKTI → chair 1 and SLMC Pharmacy for Date/Time Entry).

**7. Built a new "Manage Bookings" feature, replacing "Register a Service" on Home.** User
decision: remove the native "Register a Service" card entirely (app-store-compliance
motivated — the app itself no longer surfaces business/clinic-onboarding content; the public
`ccregister.smartqsys.com` form still exists, just isn't linked from the app). Replaced with
"Manage Bookings," a general-purpose sibling of the existing `PatientQueueAccessToken`
queue-access bridge (keyed by device instead of one booking):
- `node_app_server`: new `POST /careconnect/manage-bookings-link` (JWT-protected, mirrors
  `/bookings/:bookingId/queue-access`'s mint pattern).
- `SQ_CareConnect`: new `MobileSessionToken` Prisma model + `POST /api/mobile/session-token`
  (mint, looks up `User` by `externalMdeviceId`) + `GET .../consume` (burns the token, creates a
  real `cc_session`, redirects to `/bookings?embedded=1`).
- `sq_appt_app_2`: Home card calls the mint endpoint and opens the result in the existing
  `WebViewPage`.

  Verified fully end-to-end via curl against production: mint → consume sets a real, working
  `cc_session` cookie and redirects correctly; replaying a consumed token correctly falls through
  to `/login?error=invalid_token` instead of granting access again. **On-device WebView visual
  confirmation not completed** — this emulator's WebView was Chrome 83 (~2020), which threw real
  JS syntax errors on CareConnect's modern Next.js bundle (`"Uncaught SyntaxError: Unexpected
  token '='"`); updated it to Chrome 139 via Play Store, after which the page still rendered blank
  with no JS errors this time, and the emulator itself became flaky (Chrome onboarding looping,
  unresponsive taps) — likely strained by the large system-component update, same pattern as the
  ANR that opened this session. User will verify visually on a physical device instead.

**8. All work committed and pushed:**
- `sq_appt_app_2` (`feature/redesign-2026`): four commits — `56a1fce` (remove Google/Apple
  buttons), `6337c43` (Badge redesign + Settings nav fix), `8071868` (Data Capture/Date-Time
  redesign), `beb8143` (Manage Bookings feature).
- `node_app_server` (`main`, fast-forwarded into `peer-notification` too since that's what Render
  actually deploys): `18619eb` (manage-bookings-link route), plus the `main`→`peer-notification`
  fast-forward itself (`f7a19ed`, yesterday's merge, finally actually deployed).
- `SQ_CareConnect` (`master`): `7f150a0` (mobile-SSO bridge).

---

### 2026-08-08 — Full mockup-driven redesign built across all three repos; badge security fixed; live device-testing round found and fixed real bugs

**Context:** continuation of 2026-08-07's suspended session. The five enhancement items from that
session (plus the user's own 7 approved UI mockups in `D:\Claude\sq_appt_app\*.JPEG`) turned into
a much larger effort spanning `sq_appt_app_2`, `node_app_server`, and `SQ_CareConnect`, all on a
new `feature/redesign-2026` branch in each repo. Two architectural decisions came out of scoping
this: (1) the QR "SmartQ Badge" needed a real security fix, not just a restyle — it was leaking the
raw session `auth_token` and `fcmToken` in plaintext; (2) queue monitoring/handling should not be
rebuilt natively in Flutter — it links out to CareConnect via WebView instead, one implementation
reused by any channel.

**1. Badge security fix — shipped.** `node_app_server`: new `badgeToken.js` (AES-256-GCM,
`BADGE_TOKEN_KEY` env var), `GET /badge-token` returns an opaque token containing only
`customerId`, no expiry (it's a long-lived gate-pass identity, not a session token). Flutter caches
it via `SharedPref` so the badge still renders offline. Committed on `node_app_server`'s
`feature/redesign-2026` (`acb604e`).

**2. CareConnect queue-access bridge — shipped, merged to `master`.** New `PatientQueueAccessToken`
Prisma model + mint/consume routes (same pattern as CareConnect's existing `ImpersonationToken`),
gated by a new `x-nas-service-key` header (`NAS_CC_SERVICE_KEY`). `node_app_server` gained
`booking.handled_by` tracking and `POST /bookings/:bookingId/queue-access` as the actual trigger
point, so Flutter never talks to CareConnect directly. CareConnect's own redesign (ccadmin
Terminal, ccuser queue panel restyle against reference mockups, embedded-mode nav/padding hiding
via a `sessionStorage` flag survives Next.js client-side nav) is done and **already merged to
`master`** — confirmed via `git log` (`c9b912f`, `89dc77b`).

**3. Service Provider Mode — shipped.** `mdevice.is_service_provider` column + service-key-gated
flip route, set automatically when a clinic application is approved
(`setMobileServiceProviderFlag`). Flutter surfaces it for free via the existing `GET /profile`
payload; every Service-Provider-Mode UI element is fully hidden (not disabled) when the flag is
false.

**4. Flutter redesign against all 7 mockups — mostly built, partially committed.** SignIn/SignUp,
Home dashboard, Drawer, Get Ticket, Contact Us are committed on `sq_appt_app_2`'s
`feature/redesign-2026` (see `git log`: `5d01219`, `136b7fb`, `2c51b1a`, `ac3aa6b`, `82ad41f`, and
earlier). **The most recent round of work is implemented but not yet committed** (dirty working
tree) — this includes:
- Bottom nav cut from 5 tabs to 4 (Home / My Queues / Services / More) — "My Badge" removed
  per user request since it's already reachable from Home.
- Drawer reorganized — Settings/Logout moved out into the Home AppBar's profile `PopupMenuButton`.
- Settings screen fully rewritten to match `Settings.JPEG` (sectioned cards, bottom-sheet pickers
  replacing `CustomDropDown`).
- Home dashboard: Quick Actions grid, SmartQ Badge preview card, Service-Provider panel /
  Register-a-Service card (copy iterated live to "Register your Service/Clinic to CareConnect™ and
  manage your own queue with SmartQ", proper `WidgetSpan` superscript for the trademark).
- Booking flow (`request_new_booking.dart`) collapsed from 5 dropdown steps
  (Industry→Company→Department→Group→Unit) to 3 (Industry→Organisation→Service Provider), with a
  horizontal-slider industry picker, searchable organisation list, and a connector-line step
  indicator. Provider selection no longer needs a tick + Continue button — tapping a provider
  immediately proceeds.
- `home_provider.dart`: `setCompaniesList` made `async`; when an organisation resolves to exactly
  one provider, the app now auto-selects it and skips the "Service Provider" step entirely,
  jumping straight to the date/time (Appointment) or Data Capture page — most orgs in the real
  data are 1:1 with a provider, so this removes a mostly-pointless tap.

**5. Live device-testing round (fresh Android emulator, cold `flutter run` restart) — found and
fixed two real bugs:**
- **Data Capture form silently missing instructions/photo hints.** Root cause: the simplified
  3-step flow dropped the old Department/Group selection, but `node_app_server`'s
  `POST /service-options` required `department`/`groupname` keys to be *present* in the request
  body (400 `Missing required parameter: department` otherwise) and then filtered on
  `department = ''` when empty — an exact-match filter, not "don't care." Real seeded
  `servoption` rows have non-blank department values, so even after sending the keys the query
  still 404'd (`No service options found for the given filters.`). Fixed on both sides: Flutter
  now always sends `department`/`groupname` as empty strings; `app.js`'s `/service-options`
  handler now skips the filter entirely when they're empty instead of forcing a blank match.
  **Fixed in code (`node_app_server` `app.js`, uncommitted) but not deployed** — the emulator/app
  talks straight to production (`https://node-app-server.onrender.com`, deployed from `main`), and
  this fix lives on `feature/redesign-2026`, so Data Capture instructions are still broken live
  until this ships. Flagged to user; deploy decision pending (see `pending_work.md`).
- **"Steps stay green after a booking" — investigated, turned out not to be a real bug.** Ran a
  full real Appointment booking end-to-end (NKTI → chair 1 → Aug 21 9–10 AM → submitted
  successfully) on a freshly-restarted app process and confirmed the step indicator correctly
  resets to step 1 afterward. The behavior the user saw earlier was stale in-memory
  `HomeProvider` state surviving across hot reloads on a `flutter run` process that had been
  running since much earlier in the session — a full cold restart resolved it. No code change was
  needed for this one.
- Also verified live: organisations with multiple providers (NKTI, 3 providers) correctly still
  show the Service Provider step; single-provider orgs (SLMC Pharmacy) correctly auto-skip it.

**6. Known temporary hack still in place — must revert before any real build.**
`android/app/build.gradle` has `versionCode 22` / `versionName "21.1.0"` hardcoded (real values are
`21` / `"21.0.1"`) to bypass the server's hardcoded `minimum_version_android: "21.0.3"` force-update
check during testing. **Not reverted yet** — reverting now would re-block on-device testing.

**Files touched, by repo:**
- `node_app_server` (`feature/redesign-2026`): committed through `63a3118`
  (badge token, queue-access mint route, `handled_by`/`is_service_provider` columns, Data Capture
  webhook fields, Privacy/Terms/About restyle). `app.js`'s `/service-options` department/groupname
  filter fix is **uncommitted**.
- `SQ_CareConnect` (`master`): fully merged and committed, nothing outstanding from this effort.
- `sq_appt_app_2` (`feature/redesign-2026`): committed through `5d01219`; the bottom-nav/drawer/
  settings/home-dashboard/booking-flow work described in §4–5 above is implemented but
  **uncommitted** (dirty working tree — `android/app/build.gradle`, `lib/provider/home_provider.dart`,
  `lib/provider/theme_provider.dart`, `lib/view/auth/SignIn.dart`, `lib/view/auth/SignUp.dart`,
  `lib/view/home/app_drawer.dart`, `lib/view/home/bottom_nav_bar.dart`,
  `lib/view/home/contact_us.dart`, `lib/view/home/home_dashboard.dart`,
  `lib/view/home/request_new_booking.dart`, `lib/view/home/settings.dart`, `pubspec.yaml`, plus new
  untracked `assets/` and `lib/constant/app_colors.dart`).

**7. Committed, pushed, and iOS handoff doc added (later same day).** All three repos'
uncommitted work from §4–6 above is now committed and pushed:
- `sq_appt_app_2`: two commits on `feature/redesign-2026` (`9f21ee2` for the redesign work,
  `b05cbfe` kept **separate** for the temporary `build.gradle` version bump so it's trivially
  revertable/cherry-pick-out-able later). Pushed as a new remote branch.
- `node_app_server`: `edf5b25` for the `/service-options` fix. Pushed as a new remote branch.
- Docs workspace (`D:\Claude\sq_appt_app`, `mobile-redesign`): committed and pushed the
  `DEVLOG.md`/`pending_work.md` updates, all 7 mockup JPEGs (so they travel to other checkouts),
  and a new `IOS_HANDOFF.md` summarizing repo/branch locations, what's done, and iOS-specific
  notes (signing already resolved per 2026-08-07; `MARKETING_VERSION` 2.0.1 is already well past
  the server's `minimum_version_ios: "1.0.3"`, so — unlike Android — no force-update workaround
  is needed for iOS testing).

**8. Badge QR still not showing anywhere — root-caused to the same deploy gap, then fixed the
Home dashboard's own bug on top of it.** User reported the QR wasn't displaying. Confirmed via
`curl` + `git log origin/main` that `GET /badge-token` genuinely doesn't exist on production
(the auth middleware's blanket 403 for unauthenticated requests made this hard to tell from a
plain 404 at first). Separately, found and fixed a real bug while investigating: the Home
dashboard's badge preview card (`_BadgeFeatureCard` in `home_dashboard.dart`) only ever read
`SharedPref.getBadgeToken()` passively — it never fetched anything itself, relying entirely on
the user having visited the dedicated full-screen Badge view (`home_page.dart`) at least once to
populate that cache. Converted it to a `StatefulWidget` that fetches and caches the token
independently on `initState` (same show-cache-then-refresh pattern as `home_page.dart`), so the
preview will show a live QR on first load once the backend is actually deployed. Verified on
device: code path is correct, still shows the placeholder icon only because the fetch still 403s
against production — purely a deploy-gap issue now, not a code bug. Committed and pushed
(`3885189`).

**9. Deploy approved, but paused after finding a real merge conflict — session suspended here.**
User confirmed both deploy prerequisites: the `sql/2026-08-08_redesign_columns.sql` migration
(`booking.handled_by`, `mdevice.is_service_provider`) has already been run against production,
and `BADGE_TOKEN_KEY` / `NAS_CC_SERVICE_KEY` / `CARECONNECT_BASE_URL` are already set in Render's
environment. This mattered because `applyCareConnectOutcome`/`routeBookingToHandler` write
`handled_by` unconditionally on *every* routed booking (not just new-feature codepaths) — deploying
without the column would have broken booking status updates for every user, not just the new
features.

While preparing the actual merge, found that `node_app_server`'s `main` has **5 commits since the
branches diverged** (`3bf1bc0`) that don't exist on `feature/redesign-2026` — `added customerid in
/create-booking`, `servoption API endpoint created`, `response format changed`, `added Unit...`,
and `test`. Confusingly, `feature/redesign-2026` has commits with the **same messages** already in
its own history (applied independently, different hashes) — the same underlying features were
built twice, once directly on `main` at some point outside this effort and once on the feature
branch. A trial merge (`git merge feature/redesign-2026` into a disposable branch off `main`,
never pushed) confirmed a real conflict, isolated entirely to the `/service-options` route:
`main`'s independent version is still `app.get(...)` reading `req.query` — the *pre*-simplified-flow
shape — while the feature branch has the current `app.post(...)`/`req.body` version the redesigned
Flutter client actually calls. Keeping `main`'s side here would silently break the Data Capture
flow's HTTP method entirely, not just the department filter bug from §5.

Was mid-way through resolving this conflict (feature branch's route/body/filter logic, plus
preserving `main`'s independent addition of global `unhandledRejection`/`uncaughtException`/pool
`error` crash-prevention handlers that sit right after this route and don't otherwise conflict)
when the user asked to suspend. **Cleanly aborted** — `git merge --abort`, deleted the disposable
trial branch, confirmed `git status` clean on `feature/redesign-2026`. Nothing was merged,
committed, or pushed to `main`; production is unchanged and still running its pre-redesign code.

---

### 2026-08-07 — Publish-setup verification (both platforms confirmed), notification/booking fixes started, badge-security redesign scoped

**Context:** first real session in this new VS Code workspace (`D:\Claude\sq_appt_app`, branch
`mobile-redesign`, cloned fresh off `improved`). See `CLAUDE_BRIEFING.md` for the full
locations/history writeup — this entry covers what changed since that briefing was written.

**1. Publish-setup checklist — fully resolved, both platforms.**
- **Android**: confirmed via Play Console (`Vic10809` account, a *different* Google account than
  App Store Connect's `vic@smartqsys.com` — worth remembering) that `keystore.jks`'s SHA-1/SHA-256
  exactly match the registered upload key. The other two keystores (`.keystore`, `releasekey.jks`)
  are confirmed stale.
- **iOS**: initial check found *zero* certificates and no valid distribution profile on the Apple
  Developer account (`FN232J5K2B`) — a hard blocker. User generated a CSR on their Mac same day
  and created a new Apple Distribution certificate + App Store distribution provisioning profile
  for `com.smartqsys.sqapptapp`, both confirmed present and valid until 2027/08/07.
- Also found and documented (not acted on, per user): App Store Connect's app "Name" field is
  literally `SQ Appt App` (user decided to keep it for now), and the contractor (Ashish Mittal)
  still has full-scope App Store Connect access including a login as recent as 2026-07-23 (user
  decided not to revoke).
- Committed (`86ddced`, `3f51e80`) and pushed to `origin/mobile-redesign`.

**2. Stale Android keystores archived.** In the *other* checkout
(`C:\Users\vic\AndroidStudioProjects\sq_appt_app_2`, which stays on branch `improved` as the
known-good fallback — new work branches off it instead of touching it directly, per user
preference): new branch `chore/archive-stale-keystores`, moved `.keystore` and `releasekey.jks`
into `android/app/archived_unused_keystores/`. Nothing to commit there (both files are
gitignored, confirmed `android/.gitignore` already protects `key.properties`/`*.jks`/`*.keystore`
— that part of the original briefing was already stale/covered).

**3. Notification + booking-list fixes — implemented, NOT yet committed.** New branch
`fix/notification-channel-and-tap-handling` in `sq_appt_app_2` (off the same base as the keystore
branch). Addresses two items from `SQ_CareConnect`'s DEVLOG (2026-08-01 entry — push-notification
sound bug) plus one new one:
- **Channel pre-creation** (`main.dart`, `notification/notification.dart`): the
  `booking_updates` Android notification channel is now created at app startup with a fixed ID
  (`NotificationServices.bookingUpdatesChannelId`) matching `node_app_server`'s
  `FCM_ANDROID_CHANNEL_ID`, instead of being derived from the first incoming message's
  `channelId` (which is what broke sound originally — see CareConnect's DEVLOG for the full root
  cause). `showNotification` also now uses the fixed channel id directly rather than trusting the
  message.
- **CC-admin push tap-handling**: confirmed already present (a pre-existing uncommitted edit from
  before this session) — tapping a `service_provider_application` push opens SAM's `/cc-admin`
  page. Left as-is.
- **My Bookings sort order**: `home_provider.dart`'s `getAllBooking` had a *disabled* sort
  (`// bookingList.sort(...)`, commented out because the original used unsafe `!.compareTo` on a
  nullable `bookingDate`). Re-enabled with a null-safe version, descending (most recent first).
- `flutter analyze` clean on all three touched files (only pre-existing, unrelated style
  warnings). Not built/run on a device this session.

**4. Enhancement requests — discussed, mostly not yet implemented.** User raised five items:
1. **"App looks too plain"** — too vague to act on; deferred pending specifics/examples.
2. **Badge label cutoff on small screens** (`home_page.dart:96`, AppBar title "SmartQ Badge") —
   confirmed real (fixed-size `Text`, no shrink/wrap handling). Not yet fixed.
3. **QR badge security — real, serious issue, found and design agreed, not yet implemented.**
   The QR (`home_page.dart:164-165`) currently encodes `customerId + fcmToken + "sqs" +
   auth_token` as raw plaintext, no expiry, no signature. `auth_token` exposure = full session
   hijack risk for anyone who scans/photographs it; `fcmToken` exposure = anyone holding it can
   push arbitrary notifications straight to that device via Firebase, bypassing the backend
   entirely. Checked `SQ_WebKiosk` for an existing consumer/parser of this QR format — found
   none (its only QR usage is outbound feedback/info codes, not scanning customer badges), so no
   compatibility constraint from that side. **Agreed design**: `node_app_server` mints an opaque,
   encrypted (AES-GCM, server-only key) token containing just `customerId`, via a new endpoint
   (e.g. `GET /badge-token`); the app fetches and caches it locally (so the badge still displays
   offline) and displays *that* in the QR instead of raw credentials. No expiry — it's meant as a
   long-lived "gate pass" identity credential, not a session token, since (per the user) it's not
   yet known when/how a client will actually use it. Whoever eventually scans it (WebKiosk or
   otherwise) needs the matching decryption key distributed separately — out of scope until that
   consumer actually exists. **Not started** — needs `node_app_server` + Flutter changes.
4. **Booking request flow simplification** — confirmed current flow is Industry → Organisation →
   Department → Group → Unit (`request_new_booking.dart`), all dropdowns, Department/Group
   required before submit. User wants it cut down to Industry → Organisation → Unit only, as a
   button-based drill-down instead of dropdowns. **Not started.**
5. **My Bookings tap → clinic queue status — not a simple link, needs new backend work.** Found
   CareConnect's actual patient queue page (`SQ_CareConnect/app/bookings/page.tsx` +
   `/api/bookings/[id]/queue`), but it requires a logged-in CareConnect **ccuser web session**
   (cookie auth) and checks `booking.patientUserId === current.user.id`. The mobile app's
   identity lives entirely in `node_app_server` (customerId/auth_token) — a completely separate
   account system from CareConnect's ccuser accounts, so a naive deep-link won't work.
   **Direction floated but not yet confirmed with user**: a new token-based, single-booking
   queue view on the CareConnect side that doesn't require ccuser login (same pattern as the
   existing ticket-scan WebView already used elsewhere in the mobile app). **Not started.**

**Session suspended here** at the user's request, mid-way through the enhancement round, to
create this DEVLOG entry and `pending_work.md` before continuing later. See `pending_work.md` for
the concrete resume checklist.

**Files touched this session:**
- `D:\Claude\sq_appt_app\CLAUDE_BRIEFING.md` — committed, pushed.
- `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` — two new local branches
  (`chore/archive-stale-keystores`, `fix/notification-channel-and-tap-handling`), nothing
  committed on either yet. `improved` itself untouched.
- Read-only research in `SQ_CareConnect` and `SQ_WebKiosk` — no changes.
