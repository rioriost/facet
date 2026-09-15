import XCTest

/// Explicitly selected by FacetStoreScreenshots; never runs in the normal test scheme.
final class FacetStoreScreenshotTests: XCTestCase {
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
            for (index, profile) in ["work", "personal", "combined"].enumerated() {
                if index > 0 { app.swipeLeft() }
                XCTAssertTrue(app.otherElements["qr-\(profile)"].waitForExistence(timeout: 10))
                capture(app, "\(language)__0\(index + 2)-\(profile)")
            }
            app.terminate()
        }
    }
    @MainActor private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
