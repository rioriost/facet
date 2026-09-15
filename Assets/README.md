# Facet app icon

`Icon.svg` is the editable source: one contact card divided into three facets for Work, Personal, and Combined. The square background is intentional; iOS and watchOS apply their own masks.

Both targets contain `Assets.xcassets/AppIcon.appiconset` with a single 1024×1024 opaque sRGB PNG. Xcode generates the required sizes for each platform. No QR-reader motif, lettering, or baked-in outer corner mask is used.

## Regenerate on macOS

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
scripts/export-icon.sh
xcodegen generate
```

The script renders the existing SVG using macOS Quick Look and exports an opaque PNG with Core Graphics. It requires no downloaded graphics library. Both PNGs should be identical, 1024px square, and have no alpha channel.

The source and PNG were visually inspected, and the catalogs compiled for iOS/watchOS. Physical Home Screen and Watch launcher appearance still need device verification.

[Apple: configuring app icons with an asset catalog](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)
