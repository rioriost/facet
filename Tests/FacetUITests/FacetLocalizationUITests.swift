import XCTest
import CoreImage

final class FacetLocalizationUITests: XCTestCase {
    @MainActor func testAllLocalizationsResolveInAppAndPreserveQRPayload() throws {
        let cases = [
            ("ja", "ja_JP", "仕事用", "共有設定", "氏名", "氏名を選ぶとQRを表示できます。"),
            ("en", "en_US", "Work", "Sharing settings", "Name", "Select the name to display a QR code."),
            ("zh-Hans", "zh_CN", "工作", "共享设置", "姓名", "选择姓名后即可显示二维码。"),
            ("zh-Hant", "zh_TW", "工作", "分享設定", "姓名", "選取姓名後即可顯示 QR 碼。"),
            ("ko", "ko_KR", "업무용", "공유 설정", "이름", "이름을 선택하면 QR 코드를 표시할 수 있습니다."),
            ("fr", "fr_FR", "Travail", "Réglages de partage", "Nom", "Sélectionnez le nom pour afficher un code QR."),
            ("de", "de_DE", "Beruflich", "Freigabeeinstellungen", "Name", "Wähle den Namen aus, um einen QR-Code anzuzeigen."),
            ("es", "es_ES", "Trabajo", "Ajustes de uso compartido", "Nombre", "Selecciona el nombre para mostrar un código QR."),
            ("es-419", "es_MX", "Trabajo", "Configuración para compartir", "Nombre", "Selecciona el nombre para mostrar un código QR."),
            ("pt-BR", "pt_BR", "Trabalho", "Ajustes de compartilhamento", "Nome", "Selecione o nome para exibir um código QR."),
            ("pt-PT", "pt_PT", "Trabalho", "Definições de partilha", "Nome", "Selecione o nome para mostrar um código QR."),
            ("it", "it_IT", "Lavoro", "Impostazioni di condivisione", "Nome", "Seleziona il nome per visualizzare un codice QR.")
        ]
        var originalPayload: String?
        for (language, locale, profile, title, nameLabel, issue) in cases {
            let app = XCUIApplication()
            app.launchArguments = ["--demo", "-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launch()
            XCTAssertTrue(app.otherElements["qr-work"].waitForExistence(timeout: 10), language)
            XCTAssertTrue(app.staticTexts[profile].exists, language)
            let image = try XCTUnwrap(app.screenshot().image.cgImage)
            let detector = try XCTUnwrap(CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
            let qr = try XCTUnwrap(detector.features(in: CIImage(cgImage: image)).first as? CIQRCodeFeature)
            let payload = try XCTUnwrap(qr.messageString)
            if let originalPayload { XCTAssertEqual(payload, originalPayload, language) }
            else { originalPayload = payload }
            app.buttons["settings"].tap()
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5), language)
            let name = app.switches["field-name"]
            if !name.isHittable { app.swipeUp() }
            XCTAssertTrue(name.exists, language)
            XCTAssertTrue(name.label.contains(nameLabel), language)
            name.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
            XCTAssertEqual(name.value as? String, "0", language)
            if !app.staticTexts[issue].isHittable { app.swipeUp() }
            XCTAssertTrue(app.staticTexts[issue].exists, language)
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Sharing settings – \(language)"
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
    }
}
