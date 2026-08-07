# SmartQ Mobile App (`sq_appt_app`) — Briefing for Claude in VS Code

Read this first when starting a new Claude Code session here. It captures everything worked out
in a prior session (terminal-based, working from `D:\Claude\`) before this VS Code workspace
existed, so you don't have to re-derive it.

## What this project is

Flutter app (`sq_notification` internally, "SmartQ" as the display name), the patient-facing
mobile client for the SmartQ ecosystem — books appointments, tracks queue position, gets push
notifications. It calls `node_app_server` (Node/Express, `POST /create-booking`, `/login`, etc.)
directly; it does not talk to CareConnect or SAM itself. See "Ecosystem context" below.

## Locations — READ CAREFULLY, three different things named similarly

| Path | What it is |
|------|------------|
| `D:\Claude\sq_appt_app` (this workspace) | **New working copy**, cloned fresh from GitHub, branch `mobile-redesign`. Do development work here. |
| `C:\Users\vic\AndroidStudioProjects\sq_appt_app_2` | **The original checkout — leave it alone.** Branch `improved`, has uncommitted local changes (a CC-admin push tap-handling fix in `lib/notification/notification.dart`, plus an uncommitted edit in `lib/view/home/get_ticket.dart` — never reviewed/committed, context unknown). The user explicitly wants this left intact as a known-good reference/fallback. Don't edit or commit here unless specifically asked to. |
| `github.com/vicdlr/sq_appt_app_2` | The GitHub remote both checkouts point at (`origin`). Branches: `main`, `improved` (contractor-created — see below), and now `mobile-redesign` (this workspace's branch, already pushed). |

**Why a new branch instead of reusing `improved`:** the user's rule was "if Claude created
`improved`, keep using it; otherwise branch off it." Checked: `improved`'s earliest unique
commits (April–July 2025) are all authored by `ashish mittal` / `ashishcoderoofs`
(`coderoofitsolutions@gmail.com`, `ashish@coderoofs.com`) — the original contractor, not Claude. A
later commit on `improved` (2026-07-31, "Force-update dialog...") *was* Claude's, but that's a
commit on a pre-existing branch, not branch creation. So: new branch, `mobile-redesign`, created
off `improved` and already pushed to `origin`.

## The user's stated priority: verify publishing setup BEFORE changing anything

Direct quote: "since it was the contractor that published it in AppStore and PlayStore, I want us
to be able to ensure we have the correct setup to publish before we change anything." This is the
real first task, not a formality — do not start feature work until this is resolved or the user
explicitly says to proceed anyway.

### Android signing — the core open risk

`android/app/` has **three different keystore files**, none tracked in git (good — no
secret-in-history exposure like a known issue in the CareConnect repo) but also **not explicitly
`.gitignore`'d** (fragile — an incautious `git add -A` could commit one):

| File | Date | Status |
|------|------|--------|
| `.keystore` | Mar 17 2024 | Fingerprint not obtained — password unknown, none of the guessed passwords/aliases worked |
| `releasekey.jks` | May 1 2025 | Fingerprint not obtained — same |
| `keystore.jks` | May 2 2025 | **Currently wired** in `android/key.properties` (alias `upload`). Fingerprinted successfully: |

```
Owner: CN=coderoof, OU=coderoof, O=coderoof, L=mohali, ST=punjab, C=91
Valid from: Tue Dec 03 2024 until: Sat Apr 20 2052
SHA1:   29:19:0C:F2:4E:93:37:8C:A8:C4:15:48:9F:C5:63:F9:BD:CF:C7:55
SHA256: 7F:C2:5F:9F:41:3D:46:51:32:C9:B8:F9:15:41:D2:D6:61:D6:E0:9F:A2:7C:96:D3:7F:4E:72:AE:CC:74:5A:43
```

Note the certificate `Owner` is the **contractor's own company identity** ("coderoof"), not
SmartQ's — not necessarily wrong (contractors often generate keystores under their own details),
but worth the user consciously confirming that's expected.

**What's still needed (requires the user's Play Console access, not something Claude can check
from the repo):** log into Google Play Console → the app → Release → Setup → App integrity → App
signing, and compare the SHA1/SHA256 fingerprint shown there against the `keystore.jks` one
above.
- **If it matches**: `keystore.jks` is confirmed as the real upload key. The other two
  (`.keystore`, `releasekey.jks`) are almost certainly stale/leftover — safe to archive out of
  the way (not delete outright without asking) once confirmed, and add explicit `.gitignore`
  entries (`android/key.properties`, `*.jks`, `*.keystore`) so this can't become an accidental
  git-tracked secret later.
- **If it does NOT match**: stop. That means the *real* signing key is one of the other two files
  (get their passwords from wherever the contractor/prior team stored them, or from a password
  manager/handoff doc) — or worse, isn't present in this checkout at all, which would need
  resolving with Google Play support before any update could ship. Do not attempt to build/submit
  a release with the wrong key; Play Store will reject an update signed with a non-matching key.

**iOS side, not yet checked as deeply:** no `.p12`/`.mobileprovision`/provisioning-profile files
found in the repo (normal — these usually live in the developer's Keychain/Apple Developer
account, not the repo). Whoever has Apple Developer Program access (the user, per CareConnect's
own DEVLOG: "paying the renewal" after an App Store visibility lapse likely caused by a lapsed
membership) needs to confirm the certificates/provisioning profiles for
`com.smartqsys.sqapptapp` are current and that Xcode/Fastlane on whatever machine builds iOS
releases can actually sign with them. Not verified this session.

### Store listing name mismatch (found, not yet fixed)

User-reported: app shows as "SmartQ" in Play Store search but "sq appt app" (or similar) in App
Store search. Checked the source — **both platforms already have the correct in-app display name**
(`AndroidManifest.xml`'s `android:label="SmartQ"`, iOS `Info.plist`'s `CFBundleDisplayName =
SmartQ`) — this is not a code bug. Store *search-result* names are a separate metadata field set
directly in each console (Play Console's Store Listing "App name", App Store Connect's App
Information "Name"), independent of the manifest/plist values, though normally kept in sync. Play
Console's is apparently already right; App Store Connect's isn't — needs updating there directly.
Requires App Store Connect access, which Claude doesn't have.

### App Store "Seller" shows the user's personal name (found, not a simple fix)

User-reported: their own name appears on the App Store download page instead of something like
"SmartQ Team." This is **not a free-text field** — Apple ties the "Seller" name shown on a listing
to the Apple Developer Program account type itself:
- **Individual account**: seller name is legally required to be the account holder's real/legal
  name (tied to tax/contract details on file with Apple). This is almost certainly what's
  happening here — can't just be retyped to something else.
- **Organization account**: shows the verified legal business name on file, which requires
  enrolling as an org (D-U-N-S number + business verification). Even then it must be a real
  registered legal entity name — "SmartQ Team" specifically wouldn't be accepted unless that's
  literally SmartQ's registered business name.

So before doing anything here, find out what type of Apple Developer account this actually is.
If Individual, changing the displayed seller means converting to an Organization account under
SmartQ's real legal entity — an Apple-side re-enrollment process (documents, D-U-N-S
verification), not a settings toggle. Worth scoping as its own task, not a quick fix.

Play Store's equivalent ("Developer name" in Play Console → Store presence → Store listing) is a
plain editable text field on an established account, not tied to legal-entity verification the
same way — check what it currently says there; if it's already fine, this is an iOS-only concern.

### Package/bundle identifiers (found, likely fine, worth a conscious confirm)

- Android `applicationId`: `com.smartqsys.sq_notification`
- iOS `PRODUCT_BUNDLE_IDENTIFIER`: `com.smartqsys.sqapptapp`
- Firebase project: `sqnotification`

These don't match each other, which is unusual (many apps keep Android/iOS IDs identical) but not
inherently wrong — each platform's identifier only needs to be internally consistent with what's
already registered in that platform's console. Just worth the user confirming this was
intentional/known, not a surprise.

## Recommended next step

Don't start UI/feature work yet. Publish-setup checklist, all pending the user checking their own
consoles (Claude has no access to either):
1. Play Console → App integrity → App signing: cross-check the fingerprint shown there against
   `keystore.jks`'s SHA1/SHA256 above.
2. App Store Connect: confirm certificate/provisioning-profile status for
   `com.smartqsys.sqapptapp` is current and buildable.
3. App Store Connect → App Information → Name: update from whatever contractor-era value it has
   to "SmartQ" (Play Console's already correct).
4. Confirm what type of Apple Developer account this is (Individual vs Organization) before
   deciding whether/how to fix the Seller-name-shows-personal-name issue.

Once signing is confirmed solid on both platforms, THEN move on to whatever the actual
improvement work is (not yet scoped when this briefing was written).

## Ecosystem context (from the broader SmartQ project family, `D:\Claude\`)

This app is one piece of a larger ecosystem — useful background, not this repo's own concern:

| Project | Path | Relation |
|---------|------|----------|
| `node_app_server` | `C:\Users\vic\AndroidStudioProjects\node_app_server` | The backend this app talks to directly (`/login`, `/create-booking`, etc.) |
| SQ_APP_Manager (SAM) | `D:\Claude\SQ_APP_Manager` | Admin/application-facing gateway, shares the same Postgres DB as `node_app_server` |
| SQ_CareConnect | `D:\Claude\SQ_CareConnect` | A newer queue-handling service some bookings route through; calls `node_app_server`'s `/create-booking` server-to-server the same way this mobile app does, and reads `node_app_server`'s DB read-only for booking-time hierarchy lookups |

A known, documented (not yet acted on) security issue in `node_app_server`: its `.env` (Firebase
service account, JWT `PRIVATEKEY`, Cloudinary credentials) was tracked in git history at one
point — untracked now, but history still has every value, treat as compromised. Not this app's
direct problem, but the JWT `PRIVATEKEY` is what signs this app's own login tokens, so a future
rotation there would invalidate every live mobile session — needs deliberate planning whenever
that's tackled.

## Session conventions carried over from the rest of this ecosystem

- Never commit unless explicitly asked; when there's unrelated pre-existing uncommitted work,
  ask whether to scope narrowly or include it.
- Never push without being explicitly asked.
- Verify changes (build/lint/tests) before reporting done; no browser/device automation
  available in the terminal-based sessions this ecosystem has used so far — state that
  explicitly rather than claiming a UI was actually clicked through.
- For anything touching real store submissions, signing keys, or production data: confirm with
  the user before acting, same caution as the keystore analysis above.
