import XCTest

final class FacetUITests: XCTestCase {
    @MainActor func testFirstLaunchShowsSettingsWithoutRequestingContacts() {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-fixture-settings"]
        app.launchArguments += ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.navigationBars["公開設定"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["select-contact"].exists)
    }
    @MainActor func testDemoProfilesAndConsentChange() {
        let app = XCUIApplication()
        app.launchArguments = ["--demo"]
        app.launchArguments += ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        app.swipeLeft()
        XCTAssertTrue(app.otherElements["qr-personal"].waitForExistence(timeout: 5))
        app.buttons["settings"].tap()
        XCTAssertTrue(app.navigationBars["公開設定"].waitForExistence(timeout: 5))
        let name = app.switches["field-name"]
        XCTAssertTrue(name.exists)
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        XCTAssertEqual(name.value as? String, "0")
        app.buttons["完了"].tap()
        app.swipeRight()
        XCTAssertFalse(app.otherElements["qr-work"].exists)
    }
}
