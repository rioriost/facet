#!/bin/zsh
# Real Contacts storage, per-value consent, persistence, and revoked access on a disposable Simulator.
set -euo pipefail
facet_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$facet_root"
facet_runtime="${1:?Usage: scripts/test-contacts.sh com.apple.CoreSimulator.SimRuntime.iOS-26-3}"
facet_stamp="$(date +%Y%m%d-%H%M%S)"
facet_output="work/contacts-$facet_stamp"
mkdir -p "$facet_output"
facet_simulator="$(xcrun simctl create "Facet Contacts Verification" com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation "$facet_runtime")"
cleanup() {
    xcrun simctl shutdown "$facet_simulator" >/dev/null 2>&1 || true
    xcrun simctl delete "$facet_simulator" >/dev/null 2>&1 || true
}
trap cleanup EXIT
xcrun simctl boot "$facet_simulator"
xcrun simctl bootstatus "$facet_simulator" -b > "$facet_output/boot.log" 2>&1
xcodegen generate
xcodebuild -project Facet.xcodeproj -scheme FacetContactsTests \
    -destination "platform=iOS Simulator,id=$facet_simulator" \
    -derivedDataPath work/DerivedData CODE_SIGNING_ALLOWED=NO \
    build-for-testing > "$facet_output/build.log" 2>&1
xcrun simctl install "$facet_simulator" work/DerivedData/Build/Products/Debug-iphonesimulator/Facet.app
xcrun simctl privacy "$facet_simulator" grant contacts st.rio.facet
xcodebuild -project Facet.xcodeproj -scheme FacetContactsTests \
    -destination "platform=iOS Simulator,id=$facet_simulator" -parallel-testing-enabled NO \
    -only-testing:FacetUITests/FacetContactsUITests/testContactsSelectionPersistsAndExcludesPrivateValues \
    -derivedDataPath work/DerivedData -resultBundlePath "$facet_output/Granted.xcresult" \
    CODE_SIGNING_ALLOWED=NO test-without-building > "$facet_output/granted.log" 2>&1
rg -q "Executed 1 test, with 0 failures" "$facet_output/granted.log"
xcrun simctl privacy "$facet_simulator" revoke contacts st.rio.facet
xcodebuild -project Facet.xcodeproj -scheme FacetContactsTests \
    -destination "platform=iOS Simulator,id=$facet_simulator" -parallel-testing-enabled NO \
    -only-testing:FacetUITests/FacetContactsUITests/testRevokedContactsHidesPreviouslyConfiguredQR \
    -derivedDataPath work/DerivedData -resultBundlePath "$facet_output/Revoked.xcresult" \
    CODE_SIGNING_ALLOWED=NO test-without-building > "$facet_output/revoked.log" 2>&1
rg -q "Executed 1 test, with 0 failures" "$facet_output/revoked.log"
print "Contacts integration and revocation passed. Evidence: $facet_output"
