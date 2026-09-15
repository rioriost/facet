# App Review resubmission — 2026-09-16

## Result

- Facet – Contact QR, iOS 1.0.0 **(3)**, including the watchOS companion.
- Uploaded successfully at **04:12 JST**; Apple processing completed and build 3 became selectable.
- Replaced rejected build 2, saved the version, updated the review item, and resubmitted at **04:22 JST** under the developer's explicit instruction.
- App Store Connect displayed **審査待ち (Waiting for Review)** for both the submission and its only item, **1.0.0 (3)**.
- Submission ID: `acb7c3e1-bf29-46a0-adee-f453ad6ec6c9` (existing submission reused).
- Build ID: `146a33a2-b018-4be5-b330-50b857dd7765`.
- Automatic release after approval remains selected. Review acceptance is pending; this is not an approval or publication record.

[Submission](https://appstoreconnect.apple.com/apps/6812192295/distribution/reviewsubmissions/details/acb7c3e1-bf29-46a0-adee-f453ad6ec6c9) · [Build 3](https://appstoreconnect.apple.com/teams/e392d05d-0ae2-4ed0-95bc-3229f9d1384e/apps/6812192295/testflight/ios/146a33a2-b018-4be5-b330-50b857dd7765)

## Correction and validation

Source: `07b75dc`. The Watch icon now uses an opaque light blue background, retaining the three-facet card design. App Store Connect's uploaded Watch asset preview visibly showed the light background and circular silhouette. Contact-sharing and QR behavior are unchanged from the developer-tested build 2.

- Xcode 27.0 (27A266a) Release archive succeeded. Both bundles report 1.0.0 (3), correct bundle IDs and minimum iOS 18/watchOS 11; signatures verify.
- Both bundled privacy manifests match build 2. The compiled Watch asset catalog includes the opaque 1024px AppIcon.
- Distribution export reported `Upload succeeded` and `EXPORT SUCCEEDED`. A restricted tool PATH avoided the known Apple/Homebrew rsync incompatibility.
- Review notes explain the icon correction and retain contact selection, manual refresh and Watch setup instructions.
- All 12 store locales retain four iPhone and three Watch screenshots, with nonempty promotional text, description, keywords and support URL within field limits.
- All 175 listed storefront prices are zero. Free-app agreement is active. No payment functionality, IAP products or subscription groups were found.
- Published privacy disclosure remains data not collected; policy and support URLs returned HTTP 200. Age rating 4+, standard Apple EULA and Business/Utilities categories remain set.

The preflight covered Safety, Performance, Business, Design and Legal/Privacy against the [current App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/). It does not guarantee approval.

## Remaining qualifications

- Review contact phone/email remain empty as in the preceding accepted submission; no private contact data was inferred. App Store Connect accepted this resubmission without a validation error. Contact completeness remains a follow-up item.
- The owner has declared trader status. The Business page lists DSA verification submitted on September 15 as **審査中**; regional availability remains subject to Apple's verification.
- No renewed oldest-OS or physical-device test was performed for this icon-only change. The preceding icon-fix work verified circular previews and Watch simulator installation/launch; the uploaded icon was visually verified in App Store Connect.

## Local evidence

Git-ignored artifacts: `work/Facet-1.0.0-3.xcarchive`, `work/resubmission-3/archive.log`, `upload.log`, `preflight.json`, and `preflight-summary.md`. Distribution used upload destination, so no standalone exported IPA is claimed.
