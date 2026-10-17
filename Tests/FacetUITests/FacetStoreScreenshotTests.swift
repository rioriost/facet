import XCTest

/// Explicitly selected by FacetStoreScreenshots; never runs in the normal test scheme.
final class FacetStoreScreenshotTests: XCTestCase {
    /// Run with the Duo inner display open; preserves the current device pose.
    @MainActor func testCaptureLocalizedDuoInnerScreenshots() {
        continueAfterFailure = false
        let locales = [("ja", "ja_JP"), ("en", "en_US"), ("zh-Hans", "zh_CN"), ("zh-Hant", "zh_TW"), ("ko", "ko_KR"), ("fr", "fr_FR"), ("de", "de_DE"), ("es", "es_ES"), ("es-419", "es_MX"), ("pt-BR", "pt_BR"), ("pt-PT", "pt_PT"), ("it", "it_IT")]
        for (language, locale) in locales {
            let app = XCUIApplication()
            app.launchArguments = ["--demo", "-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launch()
            XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10))
            capture(app, "\(language)__06-inner-work")
            for profile in ["personal", "combined", "app-share"] {
                app.collectionViews.firstMatch.swipeLeft()
                XCTAssertTrue(app.otherElements["qr-\(profile)"].waitForExistence(timeout: 10))
            }
            capture(app, "\(language)__07-inner-app-share")
            app.terminate()
        }
    }

    @MainActor func testCaptureLocalizedStoreScreenshots() {
        let locales = [("ja", "ja_JP"), ("en", "en_US"), ("zh-Hans", "zh_CN"), ("zh-Hant", "zh_TW"), ("ko", "ko_KR"), ("fr", "fr_FR"), ("de", "de_DE"), ("es", "es_ES"), ("es-419", "es_MX"), ("pt-BR", "pt_BR"), ("pt-PT", "pt_PT"), ("it", "it_IT")]
        for (language, locale) in locales {
            let app = XCUIApplication()
            app.launchArguments = ["--reset-fixture-settings", "-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launch()
            XCTAssertTrue(app.navigationBars.element.waitForExistence(timeout: 10))
            capture(app, "\(language)__01-settings")
            app.terminate()
            app.launchArguments = ["--demo", "-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launch()
            for (index, profile) in ["work", "personal", "combined", "app-share"].enumerated() {
                if index > 0 { app.swipeLeft() }
                XCTAssertTrue(app.otherElements["qr-\(profile)"].waitForExistence(timeout: 10))
                capture(app, "\(language)__0\(index + 2)-\(profile)")
            }
            app.terminate()
        }
    }
    @MainActor func testCaptureLocalizedAppShareScreenshots() {
        let locales = [("ja", "ja_JP"), ("en", "en_US"), ("zh-Hans", "zh_CN"), ("zh-Hant", "zh_TW"), ("ko", "ko_KR"), ("fr", "fr_FR"), ("de", "de_DE"), ("es", "es_ES"), ("es-419", "es_MX"), ("pt-BR", "pt_BR"), ("pt-PT", "pt_PT"), ("it", "it_IT")]
        for (language, locale) in locales {
            let app = XCUIApplication()
            app.launchArguments = ["--demo", "-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launch()
            for profile in ["work", "personal", "combined"] {
                XCTAssertTrue(app.otherElements["qr-\(profile)"].waitForExistence(timeout: 10))
                app.swipeLeft()
            }
            XCTAssertTrue(app.otherElements["qr-app-share"].waitForExistence(timeout: 10))
            capture(app, "\(language)__05-app-share")
            app.terminate()
        }
    }
    @MainActor private func capture(_ app: XCUIApplication, _ name: String) {
        if name.contains("inner"), ProcessInfo.processInfo.environment["FACET_NATIVE_CAPTURE"] == "1" {
            let acknowledgment = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            let marker = "FACET_DUO_CAPTURE \(name) \(acknowledgment.path)\n"
            FileHandle.standardOutput.write(Data(marker.utf8))
            let deadline = Date().addingTimeInterval(30)
            while !FileManager.default.fileExists(atPath: acknowledgment.path), Date() < deadline {
                Thread.sleep(forTimeInterval: 0.1)
            }
            XCTAssertTrue(FileManager.default.fileExists(atPath: acknowledgment.path), "Native screenshot was not acknowledged")
            try? FileManager.default.removeItem(at: acknowledgment)
        }
        // Xcode rounds the inner screen by one pixel. Store assets use the native
        // display capture from capture-duo-store.py; this attachment is test evidence.
        let screen = name.contains("inner") ? XCUIScreen.screens.last! : XCUIScreen.main
        let attachment = XCTAttachment(screenshot: screen.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
