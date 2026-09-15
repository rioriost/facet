#!/bin/zsh
set -euo pipefail
facet_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$facet_root"
mkdir -p work/icon-export
qlmanage -t -s 1024 -o work/icon-export Assets/Icon.svg
swift scripts/opaque-png.swift work/icon-export/Icon.svg.png Apps/iOS/Assets.xcassets/AppIcon.appiconset/AppIcon.png
# Watch needs its own light background so the circular edge is visible on black.
qlmanage -t -s 1024 -o work/icon-export Assets/WatchIcon.svg
swift scripts/opaque-png.swift work/icon-export/WatchIcon.svg.png Apps/Watch/Assets.xcassets/AppIcon.appiconset/AppIcon.png
