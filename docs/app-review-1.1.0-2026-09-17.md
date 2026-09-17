# App Review — 1.1.0 (5), 2026-09-17

## Scope

Facet – Contact QR for iPhone with its watchOS companion. This update adds the App Store sharing QR page after Work, Personal and Both on both devices. The public URL is `https://apps.apple.com/jp/app/facet-contact-qr/id6812192295`. This page works without a contact selection or Watch synchronization. Existing contact privacy, independent profile selections and the corrected light-background Watch icon remain unchanged.

Release source commit: `6b56c5246434f25da578c0bb4ffac357b7981af2`. Xcode 27.0 (27A266a), iOS 18/watchOS 11 minimums. Both archived bundles report 1.1.0 (5) and their expected identifiers. Both signatures verify; automatic App Store distribution export/upload succeeded at **15:02:37 JST**.

## Preflight

App Store Review Preflight — version update.
Guidelines retrieved: 2026-09-17.
Readiness before submission: READY WITH MANUAL CONFIRMATIONS.
Counts by primary family status: BLOCKER 0 / WARNING 1 / MANUAL 1 / PASS 3 / NOT APPLICABLE 0.

| Family | Status | Evidence |
|---|---|---|
| Safety | PASS | Local contact-sharing utility. No hosted content, messaging, medical claims or regulated activities. Contact selection and field choices remain explicit. |
| Performance | MANUAL | Release archive and Apple upload validation succeeded. All 25 Core tests pass. All 12 localizations and 76 UI keys validate in both archived apps. Same feature implementation passed iPhone Simulator navigation and actual screenshot QR decoding. Physical-device and minimum-OS qualification of this release were not repeated. |
| Business | PASS | All 175 storefront prices are zero; free and paid app agreements active. No accounts, IAP, subscriptions, advertising or developer-operated backend. |
| Design | PASS | Native contact and QR UI retained; fourth sharing page documented on both devices. All 24 new localized store screenshots previously rendered and decoded to the exact App Store URL. Light-background Watch icon correction retained. |
| Legal / Privacy | WARNING | Published data-not-collected disclosure, public GitHub policy and support link checked. Policy describes fixed public App Store QR. DSA trader verification submitted September 15 remains 審査中; EU27 availability says trader contact information is missing. Japan and 147 other regions are distributable. |

Sources: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [submission workflow](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app), [upload workflow](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds), [privacy policy](https://github.com/rioriost/facet/blob/main/PRIVACY_POLICY.md).

Not applicable within those families: accounts/account deletion, hosted UGC moderation, payments, third-party login, health, gambling, VPN/MDM, mini apps and external purchase mechanisms. Facet's own App Store QR does not unlock features or process payment.

## Store preparation and evidence

- Build UUID: `98928f3e-303b-4d16-8702-a64154f9e2d7`. Apple processing completed. Build 5 association with 1.1.0 verified after page reload.
- All 12 language/region variants have updated promotional text, description and What's New. Saved content was read back and compared. Existing contact-refresh instructions and keywords are retained.
- Screenshots: five iPhone and four Watch images per locale, including the new sharing page. All 12 sets were verified during the immediately preceding screenshot upload task; this submission pass also checked every locale's five iPhone images.
- Review notes describe 1.1.0 (5), exact sharing URL, four-page navigation, no-contact sharing, contact refresh, and Watch synchronization/erase behavior. Existing review name, phone and email were visually checked and retained; sign-in is not required.
- App Information, App Privacy, Pricing and Availability, Business contracts/DSA, version metadata and selected build reviewed. Rating remains 4+, categories Business/Utilities, standard Apple EULA, no third-party content.
- Automatic release after approval remains selected, without phased release or rating reset. No agreements or trader declarations were changed.
- Local evidence: `work/Facet-1.1.0-5.xcarchive`, `work/release-1.1.0/{archive.log,upload.log,core-tests.log,preflight.json}`. Upload destination was used; no standalone exported IPA is claimed.
- Same-feature Simulator evidence: `work/app-share/ui.xcresult` (three UI tests), `work/share-store/iphone.xcresult` (localized screenshot capture), and `work/share-store/` images. No physical-device coverage is claimed.

## Submission authorization and result

The user explicitly requested uploading the new build and submitting it for review, and stated approval. Outstanding physical/minimum-OS test coverage and Apple's pending DSA verification were reported before submission. At preflight completion, no final submission action had yet been performed. Result to be recorded below after App Store Connect confirms receipt.

### Confirmed submission

- Submitted **2026-09-17 at 15:15 JST**. Apple confirmed one item submitted.
- Submission and its only item, **1.1.0 (5)**, both display **審査待ち (Waiting for Review)**.
- Submission ID: `49afe3f2-157e-4874-ae88-5159f9cd54d0`.
- Automatic release after approval remains selected. Approval/publication of 1.1.0 has not occurred.
- The previous released 1.0.0 remains available. The existing DSA regional restriction was not changed.

[App Review submission](https://appstoreconnect.apple.com/apps/6812192295/distribution/reviewsubmissions/details/49afe3f2-157e-4874-ae88-5159f9cd54d0) · [Uploaded build 5](https://appstoreconnect.apple.com/apps/6812192295/testflight/ios/98928f3e-303b-4d16-8702-a64154f9e2d7/metadata)
