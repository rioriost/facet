import XCTest
@testable import FacetCore

final class FacetCoreTests: XCTestCase {
    let contactName = ContactField(id: "name", kind: .name, label: "氏名", displayValue: "藤田 理央", components: ["藤田", "理央"])
    let work = ContactField(id: "phone-work", kind: .phone, label: "仕事", displayValue: "03-1234-5678", components: ["03-1234-5678"])
    let secret = ContactField(id: "phone-home", kind: .phone, label: "自宅", displayValue: "090-9999-9999", components: ["090-9999-9999"])
    func testOnlyExplicitValuesAreDisclosed() throws {
        let data = try VCard.make(fields: [contactName, work, secret], selection: .init(fields: ["name", "phone-work"]))
        let text = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(text.contains("VERSION:3.0\r\nFN:藤田 理央"))
        XCTAssertTrue(text.contains("N:藤田;理央;;;"))
        XCTAssertTrue(text.contains(work.displayValue))
        XCTAssertFalse(text.contains(secret.displayValue))
    }
    func testInitialProfilesAndContactSwitchDoNotDisclose() {
        var settings = FacetSettings()
        XCTAssertTrue(settings.profiles.values.allSatisfy { $0.fields.isEmpty })
        settings.selectContact("a")
        settings.profiles[.work] = .init(fields: ["name"])
        XCTAssertTrue(settings.profiles[.combined]!.fields.isEmpty)
        settings.selectContact("b")
        XCTAssertTrue(settings.profiles.values.allSatisfy { $0.fields.isEmpty })
    }
    func testNameRequiresExplicitConsent() {
        XCTAssertThrowsError(try VCard.make(fields: [contactName, work], selection: .init(fields: ["phone-work"]))) {
            XCTAssertEqual($0 as? FacetError, .nameRequired)
        }
    }
    func testEscapeCannotInjectProperties() {
        XCTAssertEqual(VCard.escape("x\r\nTEL:secret;yes,no\\end"), "x\\nTEL:secret\\;yes\\,no\\\\end")
    }
    func testUTF8FoldingPreservesScalarsAndByteLimits() {
        let original = "FN:" + String(repeating: "理央👩🏽‍💻", count: 20)
        let folded = VCard.fold(original)
        XCTAssertEqual(folded.replacingOccurrences(of: "\r\n ", with: ""), original)
        XCTAssertTrue(folded.components(separatedBy: "\r\n").allSatisfy { $0.utf8.count <= 75 })
    }
    func testOversizedVCardIsRejectedWithoutTruncation() {
        let huge = ContactField(id: "org", kind: .organization, label: "会社", displayValue: "", components: [String(repeating: "長", count: 400)])
        XCTAssertThrowsError(try VCard.make(fields: [contactName, huge], selection: .init(fields: ["name", "org"]))) {
            XCTAssertEqual($0 as? FacetError, .tooDense)
        }
    }
    func testRemovedAndNewFieldsStayExcluded() throws {
        let data = try VCard.make(fields: [contactName, secret], selection: .init(fields: ["name", "phone-work"]))
        XCTAssertFalse(String(decoding: data, as: UTF8.self).contains("TEL:"))
    }
    func testEmptySnapshotIsValidDeletion() throws {
        let empty = WatchSnapshot(cards: [])
        XCTAssertEqual(try WatchSnapshot.decode(empty.encoded()), empty)
    }
    func testMalformedMatrixAndVersionAreRejected() throws {
        XCTAssertThrowsError(try QRMatrix(width: 22, modules: Data(repeating: 0, count: 484)))
        XCTAssertThrowsError(try QRMatrix(width: 21, modules: Data(repeating: 2, count: 441)))
        var snapshot = WatchSnapshot(cards: [])
        snapshot.version = 2
        XCTAssertThrowsError(try snapshot.encoded())
        XCTAssertThrowsError(try WatchSnapshot.decode(Data(repeating: 0, count: 60_001)))
    }
    func testDuplicateProfilesAreRejected() throws {
        let matrix = try QRMatrix(width: 21, modules: Data(repeating: 0, count: 441))
        XCTAssertThrowsError(try WatchSnapshot(cards: [.init(id: .work, matrix: matrix), .init(id: .work, matrix: matrix)]).encoded())
    }
}
