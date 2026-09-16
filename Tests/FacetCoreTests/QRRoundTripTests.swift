#if os(macOS)
import XCTest
import CoreGraphics
import Vision
import Contacts
@testable import FacetCore

final class QRRoundTripTests: XCTestCase {
    func testJapaneseContactSurvivesRealQRDecodeAndVCardImport() throws {
        let fields: [ContactField] = [
            .init(id: "name", kind: .name, label: "", displayValue: "藤田 理央", components: ["藤田", "理央"]),
            .init(id: "email", kind: .email, label: "", displayValue: "rio@example.com", components: ["rio@example.com"]),
            .init(id: "organization", kind: .organization, label: "", displayValue: "例示株式会社", components: ["例示株式会社"]),
            .init(id: "department", kind: .department, label: "", displayValue: "研究;開発,部", components: ["研究;開発,部"]),
            .init(id: "address", kind: .address, label: "", displayValue: "東京", components: ["", "", "丸の内1;2", "千代田区", "東京都", "100-0005", "日本"]),
            .init(id: "secret", kind: .phone, label: "", displayValue: "SECRET", components: ["SECRET"])
        ]
        let data = try VCard.make(fields: fields, selection: .init(fields: ["name", "email", "address", "organization", "department"]))
        let matrix = try QRGenerator.make(data)
        let unit = 8, side = (matrix.width + 8) * unit
        var pixels = [UInt8](repeating: 255, count: side * side)
        for y in 0..<matrix.width {
            for x in 0..<matrix.width where matrix.modules[y * matrix.width + x] == 1 {
                for dy in 0..<unit {
                    for dx in 0..<unit { pixels[((y + 4) * unit + dy) * side + (x + 4) * unit + dx] = 0 }
                }
            }
        }
        let provider = CGDataProvider(data: Data(pixels) as CFData)!
        let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: side,
                            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0),
                            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        let request = VNDetectBarcodesRequest(); request.symbologies = [.qr]
        try VNImageRequestHandler(cgImage: image).perform([request])
        let decoded = try XCTUnwrap(request.results?.first?.payloadStringValue)
        XCTAssertEqual(decoded, String(decoding: data, as: UTF8.self))
        XCTAssertFalse(decoded.contains("SECRET"))
        let contact = try XCTUnwrap(CNContactVCardSerialization.contacts(with: Data(decoded.utf8)).first)
        XCTAssertEqual(contact.givenName, "理央")
        XCTAssertEqual(contact.familyName, "藤田")
        XCTAssertEqual(contact.organizationName, "例示株式会社")
        XCTAssertEqual(contact.departmentName, "研究;開発,部")
        XCTAssertEqual(contact.emailAddresses.first?.value as? String, "rio@example.com")
        XCTAssertEqual(contact.postalAddresses.first?.value.street, "丸の内1;2")
    }

    func testCompanyAndDepartmentAreIndependentlySharedAndImported() throws {
        let fields: [ContactField] = [
            .init(id: "name", kind: .name, label: "", displayValue: "Alex Morgan", components: ["Morgan", "Alex"]),
            .init(id: "organization", kind: .organization, label: "", displayValue: "Example; Inc.", components: ["Example; Inc."]),
            .init(id: "department", kind: .department, label: "", displayValue: "研究開発部", components: ["研究開発部"])
        ]
        for shareCompany in [false, true] {
            for shareDepartment in [false, true] {
                var selection = ProfileSelection(fields: ["name"])
                if shareCompany { selection.fields.insert("organization") }
                if shareDepartment { selection.fields.insert("department") }
                let data = try VCard.make(fields: fields, selection: selection)
                let text = String(decoding: data, as: UTF8.self)
                let orgLines = text.components(separatedBy: "\r\n").filter { $0.hasPrefix("ORG:") }
                XCTAssertEqual(orgLines.count, shareCompany || shareDepartment ? 1 : 0)
                let contact = try XCTUnwrap(CNContactVCardSerialization.contacts(with: data).first)
                XCTAssertEqual(contact.organizationName, shareCompany ? "Example; Inc." : "")
                XCTAssertEqual(contact.departmentName, shareDepartment ? "研究開発部" : "")
            }
        }
    }
}
#endif
