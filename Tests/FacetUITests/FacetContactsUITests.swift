import XCTest
import CoreImage

final class FacetContactsUITests: XCTestCase {
    @MainActor func testContactsSelectionPersistsAndExcludesPrivateValues() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--contacts-fixture", "--reset-fixture-settings"]
        app.launch()
        XCTAssertTrue(app.navigationBars["公開設定"].waitForExistence(timeout: 15))
        let name = app.switches["field-name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        XCTAssertEqual(name.value as? String, "0")
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        let workEmail = app.switches.matching(NSPredicate(format: "label CONTAINS %@", "work@facet.example")).firstMatch
        reveal(workEmail, in: app)
        XCTAssertTrue(workEmail.exists)
        XCTAssertEqual(workEmail.value as? String, "0")
        workEmail.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        XCTAssertEqual(workEmail.value as? String, "1")
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let before = try decodeQR(app)
        XCTAssertTrue(before.contains("work@facet.example"))
        XCTAssertTrue(before.contains("理央"))
        XCTAssertFalse(before.contains("private@facet.example"))
        XCTAssertFalse(before.contains("TEL:"))
        app.terminate()
        app.launchArguments = ["--contacts-fixture"]
        app.launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertEqual(try decodeQR(app), before)
        app.swipeLeft()
        XCTAssertFalse(app.otherElements["qr-personal"].exists)
    }

    @MainActor func testRevokedContactsHidesPreviouslyConfiguredQR() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["settings"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.otherElements["qr-work"].exists)
        app.buttons["settings"].tap()
        XCTAssertTrue(app.staticTexts["連絡先の使用が許可されていません。"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["iPhoneの設定を開く"].exists)
    }

    @MainActor private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 {
            if element.exists {
                let center = element.frame.midY
                if element.isHittable && center > app.frame.minY + 120 && center < app.frame.maxY - 50 { return }
            }
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.55))
            start.press(forDuration: 0.1, thenDragTo: end)
        }
    }

    @MainActor private func decodeQR(_ app: XCUIApplication) throws -> String {
        let image = try XCTUnwrap(app.screenshot().image.cgImage)
        let context = CIContext(options: [.useSoftwareRenderer: true])
        let detector = try XCTUnwrap(CIDetector(ofType: CIDetectorTypeQRCode, context: context,
                                               options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
        let feature = detector.features(in: CIImage(cgImage: image)).first as? CIQRCodeFeature
        return try XCTUnwrap(feature?.messageString)
    }
}
