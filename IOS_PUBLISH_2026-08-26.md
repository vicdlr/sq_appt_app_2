# iOS build + TestFlight publish — Queue Status Home redesign (2026-08-26)

Paste this whole file's content to Mac Claude as its task. Everything below is current as of this
writing (commit `1370580`) — don't rely on `IOS_HANDOFF.md` in this same repo, it's stale
(last accurate ~2026-08-18, predates several TestFlight builds and this change).

## What shipped, and where

Mobile app repo `vicdlr/sq_appt_app_2`, branch `fix/android-15-compliance`, currently at commit
`1370580`. The change relevant to iOS is `496c21c` ("Show Queue Status card on Home even with no
active booking today") — pure Dart, `lib/view/home/home_dashboard.dart` only, no new
dependencies, no platform-specific code. The commit after it (`1370580`, an Android
`versionCode`/`versionName` bump in `android/app/build.gradle`) has no iOS relevance, don't worry
about it.

What changed in the app: Home's "My Active Queues" card (now titled "Queue Status") no longer
disappears when there's no active booking today — it shows "No Active Queue Today" with a "Queue
Status" button that opens CareConnect's new `/queue-status` page. This CareConnect-side work is
already deployed (Render), nothing to build/deploy there.

## 1. Pull and verify

```bash
cd <your sq_appt_app_2 checkout>
git fetch
git checkout fix/android-15-compliance
git pull
git log --oneline -1   # should show 1370580 as HEAD (or newer)
flutter pub get
cd ios && pod install && cd ..
```

No new pub dependencies in this change, so `pod install` should be a no-op — run it anyway, it's
the standing convention after any `git pull` on this branch (a past session got bitten skipping
it).

**Known dead end, don't retry it:** this branch cannot run in any iOS Simulator on record (x86_64
sims crash on a missing `libswiftWebKit.dylib`; arm64 sims fail linking `GoogleMLKit`'s
`MLImage.framework`, which only ships a device slice). Real device or `flutter build ipa` only.

## 2. Confirm signing is still valid

Team `FN232J5K2B` (`vic@smartqsys.com`). As of 2026-08-07: Apple Distribution certificate
"Victoriano Dela Rosa" (valid to 2027-08-07) + App Store distribution provisioning profile
"SQ Appt App - App Store" for `com.smartqsys.sqapptapp` (valid to 2027-08-07). Confirm both are
still installed/valid in Xcode (Settings > Accounts, or Keychain Access) rather than assuming —
don't re-generate unless something's actually expired or missing.

## 3. Bump the build number — do not reuse 7

`pubspec.yaml`'s `version:` is currently `1.0.7+7`. **Build 1.0.7 (7) is already live on
TestFlight External Testing** (promoted 2026-08-20) — App Store Connect rejects a duplicate build
number, so this must go to `1.0.7+8`:

```yaml
version: 1.0.7+8
```

Leave `1.0.7` (the marketing version) alone — no user-facing version bump intended, this is a
build-number-only release like the last several.

Commit this alongside nothing else (this repo's convention: one version-bump commit, message like
`Bump iOS build number to 1.0.7+8`), then push to `fix/android-15-compliance`.

## 4. Build

```bash
flutter build ipa --release
```

This has worked clean, unmodified, every time on this branch — output lands at
`build/ios/ipa/*.ipa` (~35MB). If it fails on something export-compliance or signing related,
stop and report back rather than guessing at a fix — flag exactly what Xcode/flutter said.

## 5. Upload via Transporter

Same path every previous build used: open **Transporter.app**, sign in with `vic@smartqsys.com`
if not already, drag the `.ipa` in, deliver. If a "Missing Compliance"/export-compliance prompt
appears: this app already has a standard-encryption-only exemption declared in
`Info.plist`/App Store Connect from a past session — it shouldn't ask again, but if it does,
answer "No" (uses only exempt/standard encryption), don't guess otherwise.

Confirm in App Store Connect afterward that the new build shows up under the app's TestFlight tab
(may take a few minutes to finish processing after upload completes) before considering this done.

## 6. Distribute

The established distribution group is **"External Testers"** (not "Internal Testing" — that one
requires actual Apple Developer team membership, which testers don't have). Once the new build
finishes processing:
- Add it to the "External Testers" group (or whichever group is already receiving builds — check
  what group build 7 went to and match it).
- Release notes: something like *"Home screen now always shows your queue status, even with no
  appointment today, plus quick links to health tips, a waiting-room game, and relaxing music
  while you wait."*
- If this is a genuinely new build to an *existing* External Testing group (not a first-ever
  submission), it should go straight to `Testing` status with no additional Apple review wait —
  that's been true for every build since 1.0.7(6). If it instead shows `Waiting for Review`,
  that's unexpected — report it, don't just wait silently.

## 7. Report back

When done, the summary that matters: build number shipped (`1.0.7+8`), confirmation it's
`Complete`/processed in App Store Connect, which testing group it's assigned to, and whether it
needed Apple review or went straight to Testing. If anything above didn't hold (signing expired,
`pod install` needed changes, the build number was already taken, etc.), say so explicitly rather
than silently working around it — this doc may be stale by the time you're reading it, same as
`IOS_HANDOFF.md` was for this session.
