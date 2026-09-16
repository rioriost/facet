import XCTest
import CoreImage

final class FacetContactsUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }
    @MainActor private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = extra + ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        return app
    }
    @MainActor private func chooseFixture(_ app: XCUIApplication) {
        app.buttons["select-contact"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), app.debugDescription)
        search.tap()
        search.typeText("FacetUITestFixture")
        let row = app.collectionViews["検索結果"].cells.matching(NSPredicate(format: "label CONTAINS %@", "FacetUITestFixture")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), app.debugDescription)
        row.tap()
        XCTAssertTrue(app.switches["field-name"].waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }
    @MainActor func testManualSelectionAndRefreshPreserveConsent() throws {
        var app = launch(["--contacts-fixture", "--reset-fixture-settings"])
        XCTAssertTrue(app.buttons["select-contact"].waitForExistence(timeout: 15))
        chooseFixture(app)
        let name = app.switches["field-name"]
        XCTAssertEqual(name.value as? String, "0")
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        let workEmail = app.switches.matching(NSPredicate(format: "label CONTAINS %@", "work@facet.example")).firstMatch
        reveal(workEmail, in: app)
        XCTAssertEqual(workEmail.value as? String, "0")
        workEmail.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let before = try decodeQR(app)
        XCTAssertTrue(before.contains("work@facet.example"))
        XCTAssertFalse(before.contains("private@facet.example"))
        XCTAssertFalse(before.contains("TEL:"))
        app.terminate()
        app = launch(["--contacts-fixture", "--fixture-update"])
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertEqual(try decodeQR(app), before, "Changes in Contacts must wait for explicit reselection")
        app.buttons["settings"].tap()
        app.buttons["select-contact"].tap()
        XCTAssertTrue(app.buttons["キャンセル"].waitForExistence(timeout: 10))
        app.buttons["キャンセル"].tap()
        XCTAssertEqual(app.switches["field-name"].value as? String, "1")
        chooseFixture(app)
        XCTAssertEqual(app.switches["field-name"].value as? String, "1")
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let updated = try decodeQR(app)
        XCTAssertTrue(updated.contains("updated@facet.example"))
        XCTAssertFalse(updated.contains("work@facet.example"))
        XCTAssertFalse(updated.contains("new-private@facet.example"))
        XCTAssertFalse(updated.contains("private@facet.example"))
        app.terminate()
        app = launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertEqual(try decodeQR(app), updated)
    }

    @MainActor func testCompanyAndDepartmentHaveIndependentSharingControls() throws {
        let app = launch(["--contacts-fixture", "--reset-fixture-settings"])
        XCTAssertTrue(app.buttons["select-contact"].waitForExistence(timeout: 15))
        chooseFixture(app)
        XCTAssertTrue(app.navigationBars["共有設定"].exists)
        let name = app.switches["field-name"]
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        let company = app.switches["field-organization"]
        let department = app.switches["field-department"]
        reveal(company, in: app)
        XCTAssertTrue(company.label.contains("会社名"))
        XCTAssertEqual(company.value as? String, "0")
        company.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        reveal(department, in: app)
        XCTAssertTrue(department.label.contains("組織・部署"))
        XCTAssertEqual(department.value as? String, "0")
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let companyOnly = try decodeQR(app)
        XCTAssertTrue(companyOnly.contains("ORG:Facet Example Inc.\r\n"))
        XCTAssertFalse(companyOnly.contains("研究開発部"))

        app.buttons["settings"].tap()
        reveal(department, in: app)
        department.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertTrue(try decodeQR(app).contains("ORG:Facet Example Inc.;研究開発部\r\n"))

        app.buttons["settings"].tap()
        reveal(company, in: app)
        company.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let departmentOnly = try decodeQR(app)
        XCTAssertTrue(departmentOnly.contains("ORG:;研究開発部\r\n"))
        XCTAssertFalse(departmentOnly.contains("Facet Example Inc."))
        app.terminate()
        app.launchArguments = ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertEqual(try decodeQR(app), departmentOnly)
    }
    @MainActor func testPickerAndSavedQRWorkWithoutContactsPermission() throws {
        let app = launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let before = try decodeQR(app)
        app.buttons["settings"].tap()
        chooseFixture(app)
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertEqual(try decodeQR(app), before)
    }
    @MainActor func testResetAllowsSelectingContactAgainWithoutRestart() {
        let app = launch()
        XCTAssertTrue(app.buttons["settings"].waitForExistence(timeout: 10))
        app.buttons["settings"].tap()
        let reset = app.buttons["設定とQRをすべて消去"]
        reveal(reset, in: app)
        reset.tap()
        app.buttons["すべて消去"].tap()
        for _ in 0..<8 { app.swipeDown() }
        XCTAssertFalse(app.switches["field-name"].exists)
        chooseFixture(app)
        let name = app.switches["field-name"]
        XCTAssertEqual(name.value as? String, "0", "Reset must not restore previous disclosure consent")
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        app.buttons["完了"].tap()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
    }
    @MainActor func testDeletedOriginalDoesNotChangeSavedCopy() throws {
        var app = launch()
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        let before = try decodeQR(app)
        app.terminate()
        app = launch(["--contacts-fixture", "--fixture-delete"])
        XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
        XCTAssertEqual(try decodeQR(app), before)
        XCTAssertFalse(app.alerts.firstMatch.exists)
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
