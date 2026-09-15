import XCTest
@testable import FacetCore

final class LocalizationTests: XCTestCase {
    private let languages = ["en", "ja", "zh-Hans", "zh-Hant", "ko", "fr", "de", "es", "es-419", "pt-BR", "pt-PT", "it"]

    func testEveryLanguageHasCompletePackagedTranslations() throws {
        var baseline: Set<String>?
        for language in languages {
            let folder = try XCTUnwrap(L10n.resourceBundle.url(forResource: language, withExtension: "lproj"))
            let data = try Data(contentsOf: folder.appendingPathComponent("Localizable.strings"))
            let values = try XCTUnwrap(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String])
            if let baseline { XCTAssertEqual(Set(values.keys), baseline, language) }
            else { baseline = Set(values.keys) }
            XCTAssertNotNil(values["contact.refresh"], language)
            for (key, value) in values {
                XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "\(language): \(key)")
            }
            let localized = try XCTUnwrap(Bundle(url: folder))
            XCTAssertEqual(localized.localizedString(forKey: "settings.title", value: nil, table: nil), values["settings.title"])
            let format = try XCTUnwrap(values["field.labeled"])
            XCTAssertEqual(String(format: format, "Email", "Custom label"), "Email · Custom label", language)
        }
    }

    func testRegionalVariantsAndPrivacyInstructions() throws {
        func value(_ language: String, _ key: String) throws -> String {
            let path = try XCTUnwrap(L10n.resourceBundle.path(forResource: language, ofType: "lproj"))
            return try XCTUnwrap(Bundle(path: path)).localizedString(forKey: key, value: nil, table: nil)
        }
        XCTAssertEqual(try value("es", "settings"), "Ajustes")
        XCTAssertEqual(try value("es-419", "settings"), "Configuración")
        XCTAssertEqual(try value("pt-BR", "field.address"), "Endereço")
        XCTAssertEqual(try value("pt-PT", "field.address"), "Morada")
        for language in languages {
            let privacy = try value(language, "privacy.body")
            XCTAssertEqual(privacy.components(separatedBy: "\n\n").count, 4, language)
            XCTAssertTrue(privacy.contains(try value(language, "watch.erase")), language)
            XCTAssertTrue(try value(language, "watch.restore").contains(try value(language, "sync.button")), language)
        }
    }
}
