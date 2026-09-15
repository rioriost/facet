# App Review submission — Facet 1.0.0 (2)

## Result

- Submitted: 2026-09-15 16:50 JST.
- Verified App Store Connect status: **Waiting for Review / 審査待ち**.
- App: Facet - Contact QR, Apple ID 6812192295, bundle st.rio.facet.
- Submitted build: 1.0.0 (2), build ID f41205aa-b819-44b3-8eab-c36672b6dd26.
- Submission ID: acb7c3e1-bf29-46a0-adee-f453ad6ec6c9.
- [Submission](https://appstoreconnect.apple.com/apps/6812192295/distribution/reviewsubmissions/details/acb7c3e1-bf29-46a0-adee-f453ad6ec6c9).
- User confirmed operation of this TestFlight build and explicitly requested submission. No new binary was uploaded.
- Existing release setting preserved: automatic release after approval.

## Preflight coverage

Checked against the current [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) and [submission workflow](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app).

| Family | Evidence and result |
| --- | --- |
| 1. Safety | Local contact sharing, no hosted user content, chat, health advice or regulated service. Synthetic Alex Morgan data in store screenshots. GitHub support URL returns HTTP 200; obsolete permission and automatic-refresh instructions corrected. |
| 2. Performance | Existing build 2 accepted by Apple; archive signature verifies. User confirmed device operation. Prior core, contact-picker and Watch QR checks recorded in test documentation. Twelve locale screenshot captures succeeded. All 72 QR screenshots decode with the expected profile fields; 12 settings screenshots contain no QR. Review notes describe setup, manual contact refresh and Watch offline behavior. |
| 3. Business | Live price table: all 175 countries/regions have zero prices. No IAP items or subscription groups. No accounts, ads, payment UI or StoreKit configuration. Free-app agreement active. |
| 4. Design | Native contact picker, three independently configured profiles, swipe navigation and bundled display-only Watch app. No repackaged website or downloaded executable features. Accessibility declarations make no unverified support claims. |
| 5. Legal / Privacy | Published data-not-collected declaration matches local processing and paired-Watch transfer. Privacy URL returns HTTP 200. Privacy manifests declare no tracking, collection or required-reason APIs. Single contact is chosen explicitly; users choose each shared field. Reset and offline Watch deletion limitations are documented. MIT source license and standard Apple EULA. DSA declaration remains an account-owner action. |

## Metadata and screenshots

Replaced all 84 screenshots with the current behavior, using localized simulator captures: four iPhone screens (settings, Work, Personal, Both), three Watch QR screens per locale. Image order verified in the upload UI. iPhone images are 1284 × 2778 PNG; Watch images are 416 × 496 JPEG. The Watch captures use the unchanged full-width QR implementation included in build 2. Layout preserves the required QR quiet zone.

Locales: Japanese, English (US), Simplified Chinese, Traditional Chinese, Korean, French, German, Spanish (Spain), Spanish (Mexico), Portuguese (Brazil), Portuguese (Portugal), Italian.

Descriptions and review notes explain manual reselection after editing Contacts. Version build association was saved as build 2. Privacy policy, support and marketing URLs are populated. Age rating is 4+. Mac and Vision Pro availability remain disabled.

## Remaining account and qualification notes

- App Review phone and email fields were visibly empty. The owner was asked for them; no private values were inferred or entered. Contrary to the initial assumption that they would block submission, App Store Connect accepted the final submission and confirmed Waiting for Review. These can be completed when supplied.
- The Business page displayed an incomplete EU Digital Services Act trader declaration. The owner was asked to complete it because this is an account-wide legal declaration. It did not prevent this review submission; EU distribution still requires the account's compliance state to be resolved.
- Minimum deployment targets are iOS 18 and watchOS 11; this run did not execute the app on those oldest OS versions. No new minimum-OS or accessibility qualification claim is made.
- Apple makes the final review decision. No approval or release is claimed by this record.

## Local evidence

- work/submission/StoreScreenshots.xcresult: 12-locale iPhone capture test passed.
- work/submission/image-validation.log: verified 72 QR and 12 settings screenshots.
- work/submission/preflight.json: archive and project inspection (also contains historical work-directory artifacts; only build 2 is the submitted candidate).
- work/submission/screenshots and work/submission/watch-screenshots: exact uploaded images.
- Public support correction: commit f509305.
