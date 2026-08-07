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

**CONFIRMED MATCH (2026-08-07, via browser in Play Console):** `keystore.jks` is the correct,
currently-registered upload key. Both fingerprints match exactly:
```
SHA-1:   29:19:0C:F2:4E:93:37:8C:A8:C4:15:48:9F:C5:63:F9:BD:CF:C7:55
SHA-256: 7F:C2:5F:9F:41:3D:46:51:32:C9:B8:F9:15:41:D2:D6:61:D6:E0:9F:A2:7C:96:D3:7F:4E:72:AE:CC:74:5A:43
```
Google Play App Signing is enabled (Google holds the actual app signing key; `keystore.jks` is
the *upload* key used to sign AABs before Google re-signs them) — confirmed via Protected with
Play → App signing → Upload key certificate. The other two keystores (`.keystore`,
`releasekey.jks`) are confirmed stale/unused — safe to archive out of the way (not delete
outright without asking), and add explicit `.gitignore` entries (`android/key.properties`,
`*.jks`, `*.keystore`) so this can't become an accidental git-tracked secret later. **Not yet
done — still needs the user's go-ahead before touching those files.**

**Important side-finding: the Play Console developer account lives under a DIFFERENT Google
account than expected.** `vic@smartqsys.com` (the account initially tried) has no Play Console
developer account at all — navigating there prompts to *create* a new one. The account that
actually owns and published this app is `vic10809@gmail.com` ("Vic10809", a Personal account,
Account ID `7397171470470613499`), which required enabling 2-Step Verification to access (done
this session). This is worth the user being aware of for any future publishing work — don't
assume `vic@smartqsys.com` has Play Console access. App Store Connect, by contrast, IS under
`vic@smartqsys.com` (see Apple Developer Program section below) — the two stores' owning
accounts are not the same identity.

### iOS certificates/provisioning — CHECKED, real problem found (2026-08-07)

Checked developer.apple.com/account → Certificates, Identifiers & Profiles under `vic@smartqsys.com`
(Team ID `FN232J5K2B`):

- **Certificates: zero.** No signing certificates exist on this account at all — none active,
  none expired-but-listed. Completely empty.
- **Identifiers: `com.smartqsys.sqapptapp` is correctly registered** (as "SQ Appointment App") —
  so the account/team itself is right. (The identifiers list is cluttered with several Xcode
  auto-generated "XC ..." entries from ad-hoc dev signing, plus a few unrelated bundle IDs
  `com.credit.creditvault12`, `com.mixerltd.mixer32`, etc. — not this app's concern, ignore.)
- **Profiles: only one exists**, `SQProfile` — type **Development** (not App Store distribution),
  platform iOS, **expired 2025/03/25** (well over a year stale). No App Store distribution
  profile exists at all.

**Conclusion:** even though App Store Connect shows a build already at "1.0.4 Ready for
Distribution" (presumably built and signed by the contractor at the time, using certificates
that were never shared into this account and have since disappeared/expired), **there is
currently no valid certificate or App Store distribution provisioning profile under this
account that would let anyone build and submit a new iOS release.** Before any iOS update ships:
1. Generate a Certificate Signing Request (CSR) from whatever Mac/Xcode installation will do the
   actual building (Keychain Access → Certificate Assistant → Request a Certificate).
2. Create a new **Apple Distribution** certificate at developer.apple.com using that CSR.
3. Create a new **App Store** distribution provisioning profile for `com.smartqsys.sqapptapp`,
   using that certificate.

This requires physical/remote access to a Mac — can't be done from this Windows checkout or the
browser alone.

**RESOLVED 2026-08-07:** user generated a CSR on their Mac and created both a new Apple
Distribution certificate ("Victoriano Dela Rosa", valid until 2027/08/07) and a new App Store
distribution provisioning profile ("SQ Appt App - App Store", iOS, valid until 2027/08/07) for
`com.smartqsys.sqapptapp`. Confirmed present via developer.apple.com. The old expired `SQProfile`
(Development, expired 2025/03/25) is still listed but harmless — can be deleted as cleanup
whenever convenient, not urgent. iOS builds should now be signable from a Mac with this
certificate installed in Keychain.

### Store listing name mismatch — CONFIRMED via App Store Connect (2026-08-07)

User-reported: app shows as "SmartQ" in Play Store search but "sq appt app" (or similar) in App
Store search. Checked the source — **both platforms already have the correct in-app display name**
(`AndroidManifest.xml`'s `android:label="SmartQ"`, iOS `Info.plist`'s `CFBundleDisplayName =
SmartQ`) — this is not a code bug. Store *search-result* names are a separate metadata field set
directly in each console (Play Console's Store Listing "App name", App Store Connect's App
Information "Name"), independent of the manifest/plist values, though normally kept in sync.

**Confirmed via browser (App Store Connect → SQ Appt App → App Information):** the "Name" field
is literally `SQ Appt App` (19 chars), Subtitle is `Booking made easy`. This is the source of the
search-result mismatch. App Store Connect's own UI warns: *"To make changes to the app name,
category, or privacy policy, create a new app version."* — i.e. this can't be edited in place on
the current 1.0.4 "Ready for Distribution" version; changing it means cutting a new version.
There's also a second app in the same App Store Connect account, `SQ_Notify` (iOS 1.0.0, "Prepare
for Submission", bundle ID not yet checked) — worth understanding what that's for before touching
anything, in case it's a notification-service counterpart app.

Play Console's Store Listing name not re-verified this session (was reported already correct
previously) — worth a quick re-check when next in Play Console.

**User decision (2026-08-07): keep the "SQ Appt App" name for now.** Do not change App Store
Connect's Name field or cut a new version for this reason unless the user explicitly asks again.

### App Store "Seller" shows the user's personal name — CONFIRMED via developer.apple.com (2026-08-07)

User-reported: their own name appears on the App Store download page instead of something like
"SmartQ Team." This is **not a free-text field** — Apple ties the "Seller" name shown on a listing
to the Apple Developer Program account type itself.

**Confirmed via browser (developer.apple.com/account → Membership details):** `Enrolled as:
Individual`. Team ID `FN232J5K2B`, address on file is the user's personal Las Piñas address. This
means the Seller name showing the user's personal/legal name is expected Apple behavior for an
Individual account, not a bug or oversight — it's legally tied to tax/contract details on file.

Fixing it requires converting to an **Organization** account: D-U-N-S number + business
verification under SmartQ's real registered legal entity name (not just "SmartQ Team" unless
that's literally the registered business name) — an Apple-side re-enrollment process (documents,
verification lead time), not a settings toggle. Scope as its own task if the user wants to pursue
it; not attempted this session.

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

Don't start UI/feature work yet. Publish-setup checklist:
1. Play Console → App integrity → App signing: cross-check the fingerprint shown there against
   `keystore.jks`'s SHA1/SHA256 above. **DONE, confirmed match, 2026-08-07** — see Android signing
   section above. Remaining follow-up: archive the two stale keystores and add `.gitignore`
   entries, pending user go-ahead.
2. App Store Connect: confirm certificate/provisioning-profile status for
   `com.smartqsys.sqapptapp` is current and buildable. **DONE, 2026-08-07 — RESOLVED.** Initial
   check found zero certificates and no valid distribution profile; user generated a new
   certificate + App Store distribution profile on their Mac same day. See iOS certificates
   section above.
3. App Store Connect → App Information → Name: confirmed set to `SQ Appt App`, needs to become
   "SmartQ" — but per Apple's own UI this requires cutting a new app version, not an inline edit.
   **Confirmed 2026-08-07, fix not yet applied.**
4. Apple Developer account type: **confirmed Individual** (2026-08-07, via
   developer.apple.com/account). Seller-name-shows-personal-name is expected behavior for this
   account type; fixing it means an Organization-account conversion (D-U-N-S + business
   verification) — a separate, larger task if the user wants to pursue it.

Once signing is confirmed solid on both platforms, THEN move on to whatever the actual
improvement work is (not yet scoped when this briefing was written).

### Contractor's App Store Connect access — CHECKED, more serious than initially flagged (2026-08-07)

Ashish Mittal (`mittal.30ashish@gmail.com`) has **every role enabled**: Admin, App Manager,
Finance, Customer Support, Sales, Marketing, Developer — plus the "Create Apps" additional
permission. That's broader than a typical Admin grant (Finance/Sales aren't roles you'd expect a
contractor to need). **Last Login: Thursday, July 23, 2026** — about 2 weeks before this check,
so this is not a dormant leftover account; it's still being actively used.

**User decision (2026-08-07): do not revoke.** Leave Ashish Mittal's access as-is unless the user
explicitly asks again — this was a conscious choice, not an oversight. Two other
`@icloud.com`/`@gmail.com` accounts (Josefina Alejandro, Charito de La Rosa) hold Customer
Support only, and Harley Pangandaman holds Customer Support scoped to just the SmartQ app — those
look appropriately scoped by comparison.

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
