# App Review — build 4, 2026-09-16

## Scope and validation

Facet – Contact QR, iOS 1.0.0 **(4)** with the watchOS companion. Source commit: `53045d1`. This submission adds separate company/department sharing controls and changes Japanese contact-sharing wording from 公開 to 共有. The light-background Watch icon correction remains included.

- Core tests: 24 passed, including actual QR/Contacts round trips and independent company/department consent.
- Contacts integration: 5 tests passed on a disposable iPhone SE (3rd generation) simulator running iOS 26.3.1.
- Localization validation: 75 keys across 12 language/region variants passed.
- Release archive: Xcode 27.0 (27A266a); both bundles report 1.0.0 (4), iOS 18/watchOS 11 minimums and the expected bundle identifiers. Both signatures verify.
- Store capture: 48 iPhone screenshots generated across 12 locales. All 36 QR screenshots decoded successfully; all 12 initial settings images contain no QR. Japanese initial settings visually checked.

## Upload and store metadata

- Upload succeeded at **12:27 JST** (`Upload succeeded`, `EXPORT SUCCEEDED`). Apple processing completed.
- Build ID: `cfde2f7e-ac74-4855-b5a4-9855dfb21570`.
- Existing internal TestFlight group `facet test` includes build 4 and displays **テスト中**, with 90 days remaining. Test notes explain reselecting the contact and enabling the new department field.
- All 12 descriptions now list department separately from company. Existing manual-refresh instructions remain.
- Japanese iPhone screenshots updated in settings/work/personal/both order. The newly captured work screenshot contained a Simulator notification, so its previously verified capture of the unchanged QR screen is reused. Settings, personal and both use new captures. Other locales and Watch screenshot content are unchanged. All 12 locales verified to retain four iPhone and three Watch images, with nonempty promotional text, description, keywords and support URL within limits.
- Review notes explain both the department fix and retained Watch icon correction. The uploaded build 4 Watch asset preview visibly shows the light blue circular background.

## Preflight

App Store Review Preflight — resubmission of first release, 1.0.0 (4).
Guidelines retrieved: 2026-09-16. Readiness: READY WITH MANUAL CONFIRMATIONS.
Counts (the five family rows below): BLOCKER 0 / WARNING 1 / MANUAL 1 / PASS 3 / NOT APPLICABLE 0.
No code or metadata blocker identified in the checks below. This does not guarantee approval.

| Family | Status | Evidence |
|---|---|---|
| Safety | PASS | Local contact utility; no hosted user content, messaging, medical claims or regulated activity. |
| Performance | PASS / MANUAL | Archive, 24 core tests, 5 Contacts integration tests and screenshot capture passed. Build 4 physical-device and oldest-OS qualification were not repeated. |
| Business | PASS | All 175 storefront prices are zero; free-app agreement active. No purchase/subscription code added. |
| Design | PASS | Existing single-contact selection flow retained; company and department independently selectable; corrected circular Watch icon verified in uploaded assets. |
| Legal / Privacy | PASS / WARNING | Published data-not-collected disclosure and GitHub privacy URL verified; policy includes department and matches the repository. No developer server or Watch Contacts access. DSA trader declaration exists; Apple verification remains 審査中. |

Sources: [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [privacy policy](https://github.com/rioriost/facet/blob/main/PRIVACY_POLICY.md).

App Store Connect sections inspected: iOS version and all 12 localizations, build 4 and internal TestFlight group, App Information, App Privacy, Pricing and Availability, Business agreements and DSA status. Age rating remains 4+, categories Business/Utilities, standard Apple EULA, no third-party content. Automatic release after approval remains selected. No new agreements or regional declarations were accepted.

Remaining qualifications: actual iPhone/Watch scanning and minimum-OS testing of build 4 are not claimed. DSA verification is Apple's pending regional process. Existing review contact information is preserved; no private contact values were inferred or changed.

## Submission result

- Submitted at **12:47 JST** on 2026-09-16 under the developer's explicit request to upload and resubmit 1.0.0 (4).
- App Store Connect displayed **審査待ち (Waiting for Review)** for the submission and its only item, **1.0.0 (4)**.
- Submission ID: `49944c90-24d2-41cc-8a30-b3fd12e82061`.
- Previous build 3 submission `acb7c3e1-bf29-46a0-adee-f453ad6ec6c9` was removed from review before replacement. An initial Add for Review request returned an unexpected server error; checking the submission list showed no new draft, and retrying succeeded. The final draft contained only build 4.
- Automatic release after approval remains selected. Approval/publication has not yet occurred.

[Submission](https://appstoreconnect.apple.com/apps/6812192295/distribution/reviewsubmissions/details/49944c90-24d2-41cc-8a30-b3fd12e82061) · [TestFlight build 4](https://appstoreconnect.apple.com/teams/e392d05d-0ae2-4ed0-95bc-3229f9d1384e/apps/6812192295/testflight/ios/cfde2f7e-ac74-4855-b5a4-9855dfb21570)

## Local evidence

Git-ignored files: `work/Facet-1.0.0-4.xcarchive`, `work/company-department-core-tests.log`, `work/company-department-archive.log`, `work/contacts-20260916-122004/`, and `work/resubmission-4/{upload.log,preflight.json,screens.log,screens.xcresult,screenshots/}`. Distribution used upload destination; no standalone exported IPA is claimed.
