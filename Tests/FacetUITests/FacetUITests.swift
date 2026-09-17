import XCTest
import CoreImage

final class FacetUITests: XCTestCase {
    @MainActor func testAppShareIsFourthPageWithAndWithoutContact() throws {
        let app = XCUIApplication()
        for fixture in ["--demo", "--reset-fixture-settings"] {
            app.launchArguments = [fixture, "-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
            app.launch()
            if fixture == "--reset-fixture-settings" {
                XCTAssertTrue(app.buttons["select-contact"].waitForExistence(timeout: 10))
                app.buttons["完了"].tap()
            } else {
                XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
            }
            app.swipeLeft()
            XCTAssertTrue(app.staticTexts["プライベート用"].waitForExistence(timeout: 5))
            app.swipeLeft()
            XCTAssertTrue(app.staticTexts["双方"].waitForExistence(timeout: 5))
            app.swipeLeft()
            XCTAssertTrue(app.otherElements["qr-app-share"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["Facet - Contact QRを共有"].exists)
            let image = try XCTUnwrap(app.screenshot().image.cgImage)
            let detector = try XCTUnwrap(CIDetector(ofType: CIDetectorTypeQRCode,
                context: CIContext(options: [.useSoftwareRenderer: true]),
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
            let codes = detector.features(in: CIImage(cgImage: image)).compactMap { $0 as? CIQRCodeFeature }
            XCTAssertEqual(codes.count, 1)
            XCTAssertEqual(codes.first?.messageString, "https://apps.apple.com/jp/app/facet-contact-qr/id6812192295")
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "app-share-\(fixture)"; attachment.lifetime = .keepAlways; add(attachment)
            app.swipeRight()
            XCTAssertTrue(app.staticTexts["双方"].waitForExistence(timeout: 5))
            if fixture == "--demo" { XCTAssertTrue(app.otherElements["qr-combined"].exists) }
            app.terminate()
        }
    }

    @MainActor func testFirstLaunchShowsSettingsWithoutRequestingContacts() {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-fixture-settings"]
        app.launchArguments += ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.navigationBars["共有設定"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.navigationBars["共有設定"].waitForExistence(timeout: 5))
        let name = app.switches["field-name"]
        XCTAssertTrue(name.exists)
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        XCTAssertEqual(name.value as? String, "0")
        app.buttons["完了"].tap()
        app.swipeRight()
        XCTAssertFalse(app.otherElements["qr-work"].exists)
    }
}
