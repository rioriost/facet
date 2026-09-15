# Watch icon review correction — 2026-09-16

## Review finding and change

Apple reported Guideline 4 for submission `acb7c3e1-bf29-46a0-adee-f453ad6ec6c9`, version 1.0.0 (2): the Watch icon's dark background obscured its circular shape on Watch. This finding comes from the review message supplied by the developer.

- Added `Assets/WatchIcon.svg`: opaque light blue background `#DCEBFF` covering the complete square canvas. watchOS applies the circular mask.
- Retained the same three-facet card silhouette; adjusted the facets to blue/indigo colors that remain visible on the light background.
- Exported a dedicated 1024 × 1024 opaque sRGB Watch AppIcon.png.
- Updated `scripts/export-icon.sh` to regenerate the dedicated Watch artwork, preventing future exports from restoring the dark iPhone icon.
- iPhone icon remains unchanged. No contact, QR, or synchronization behavior changed.
- Incremented both apps to 1.0.0 (3) for a future replacement upload.

References: [Apple app icons](https://developer.apple.com/design/human-interface-guidelines/app-icons), [watchOS design](https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos), [Apple's circular watchOS icon grid](https://developer.apple.com/videos/play/wwdc2025/220/).

## Affected checks

- PASS: circular-mask previews at multiple display sizes on black, visually inspected. Preview is a design rendering, not a Watch Home screenshot.
- PASS: PNG dimensions 1024 × 1024, no alpha channel.
- PASS: Xcode 27.0 (27A266a), Release iPhone build with embedded Watch companion.
- PASS: compiled Watch Assets.car contains opaque 1024 × 1024 AppIcon image; both app Info.plists point to AppIcon and report build 3.
- PASS: Release watchOS Simulator build and installation/launch on disposable Series 10 (46mm), watchOS 27.0 simulator. The verification simulator was removed afterward.
- iPhone and Watch builds have no icon warnings. Xcode reports its existing AppIntents metadata extraction notice because the app does not use AppIntents.

Local evidence: `work/watch-icon-fix/build.log`, `simulator-build.log`, `watch-assets.json`; products in `work/WatchIconBuild` and `work/WatchIconSimulator`.

## Scope and release status

This is verification of the specific icon remediation, not a renewed full submission audit. Simulator launch was verified; actual Watch Home presentation and a new signed distribution archive were not tested in this run. No App Store Connect metadata edit, upload, review reply or resubmission was performed. Build 3 must be archived/uploaded and selected to replace the reviewed build 2 before Apple can review the corrected icon.
