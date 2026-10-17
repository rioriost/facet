import XCTest
import CoreImage

final class FacetAdaptiveLayoutTests: XCTestCase {
    @MainActor func testQRRemainsReadableAcrossRotationAndSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--demo", "-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        defer { XCUIDevice.shared.orientation = .portrait }
        for orientation in [UIDeviceOrientation.portrait, .landscapeLeft, .landscapeRight, .portrait] {
            XCUIDevice.shared.orientation = orientation
            XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
            assertQR(app, name: "rotation-\(orientation.rawValue)")
            XCTAssertTrue(app.buttons["settings"].isHittable)
        }
        for profile in ["personal", "combined", "app-share"] {
            app.swipeLeft()
            XCTAssertTrue(app.otherElements["qr-\(profile)"].waitForExistence(timeout: 5))
            assertQR(app, name: profile)
        }
        app.buttons["settings"].tap()
        XCTAssertTrue(app.buttons["select-contact"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["完了"].isHittable)
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-app-share"].waitForExistence(timeout: 5))
    }

    @MainActor func testLargestTextKeepsInstructionsReachable() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["--demo", "-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP",
                               "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        assertQR(app, name: "largest-text-work")
        let instruction = app.staticTexts["相手のカメラで読み取ってもらう"]
        app.swipeUp()
        XCTAssertTrue(instruction.isHittable)
        let pageControl = app.pageIndicators.firstMatch
        if pageControl.exists {
            XCTAssertLessThanOrEqual(instruction.frame.maxY, pageControl.frame.minY)
        }
        capture(app, "largest-text-instruction")
        app.buttons["settings"].tap()
        XCTAssertTrue(app.buttons["完了"].waitForExistence(timeout: 5))
        app.buttons["完了"].tap()
        XCTAssertTrue(app.buttons["settings"].waitForExistence(timeout: 5))
    }

    @MainActor private func assertQR(_ app: XCUIApplication, name: String) {
        // Capture the display: app.screenshot() can crop a rotated iOS 27.0 window
        // using its pre-rotation bounds when driven by Xcode 27.1.
        let screenshot = XCUIScreen.main.screenshot()
        guard let image = screenshot.image.cgImage,
              let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(),
                                       options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            XCTFail("Unable to inspect screenshot"); return
        }
        let codes = detector.features(in: CIImage(cgImage: image)).compactMap { $0 as? CIQRCodeFeature }
        XCTAssertEqual(codes.count, 1, name)
        XCTAssertNotNil(codes.first?.messageString, name)
        capture(app, name)
    }

    @MainActor private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
