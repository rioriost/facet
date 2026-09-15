import XCTest
@testable import FacetCore

final class WatchCacheTests: XCTestCase {
    private func snapshot(token: UUID? = nil) throws -> WatchSnapshot {
        let matrix = try QRMatrix(width: 21, modules: Data(repeating: 0, count: 441))
        return WatchSnapshot(cards: [.init(id: .work, matrix: matrix)], restoreToken: token)
    }
    func testLocalErasureRemovesModulesAndSurvivesBothRestarts() throws {
        let original = try snapshot()
        var cache = try WatchCache(snapshot: original)
        cache.clear()
        XCTAssertTrue(cache.hidden)
        XCTAssertTrue(cache.snapshot.cards.isEmpty)
        cache = try JSONDecoder().decode(WatchCache.self, from: JSONEncoder().encode(cache))
        try cache.receive(original) // cached context after Watch restart
        XCTAssertTrue(cache.hidden)
        let phoneRestart = try snapshot() // different snapshot ID, same restore token
        try cache.receive(phoneRestart)
        XCTAssertTrue(cache.hidden)
        XCTAssertTrue(cache.snapshot.cards.isEmpty)
        XCTAssertEqual(cache.snapshot.id, phoneRestart.id)
    }
    func testOnlyExplicitRestoreTokenMakesHiddenQRVisible() throws {
        let token = UUID()
        var cache = try WatchCache(snapshot: snapshot(token: token))
        cache.clear()
        try cache.receive(snapshot(token: token))
        XCTAssertTrue(cache.hidden)
        let restored = try snapshot(token: UUID())
        try cache.receive(restored)
        XCTAssertFalse(cache.hidden)
        XCTAssertEqual(cache.snapshot.cards, restored.cards)
    }
    func testEmptyDeletionReplacesExistingPayload() throws {
        var cache = try WatchCache(snapshot: snapshot())
        try cache.receive(WatchSnapshot(cards: []))
        XCTAssertTrue(cache.snapshot.cards.isEmpty)
    }
    func testEmptyDeletionDoesNotUndoLocalErasure() throws {
        let token = UUID()
        var cache = try WatchCache(snapshot: snapshot(token: token))
        cache.clear()
        try cache.receive(WatchSnapshot(cards: [], restoreToken: token))
        try cache.receive(snapshot(token: token))
        XCTAssertTrue(cache.hidden)
        XCTAssertTrue(cache.snapshot.cards.isEmpty)
    }
    func testInvalidIncomingSnapshotPreservesCurrentState() throws {
        var cache = try WatchCache(snapshot: snapshot())
        let original = cache
        var invalid = try snapshot(); invalid.version = 100
        XCTAssertThrowsError(try cache.receive(invalid))
        XCTAssertEqual(cache, original)
    }
    func testLegacySettingsAndSnapshotDecodeWithoutRestoreToken() throws {
        var settings = FacetSettings(); settings.watchRestoreToken = UUID()
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(settings)) as! [String: Any]
        json.removeValue(forKey: "watchRestoreToken")
        XCTAssertNil(try JSONDecoder().decode(FacetSettings.self, from: JSONSerialization.data(withJSONObject: json)).watchRestoreToken)
        let legacy = try snapshot().encoded()
        XCTAssertNil(try WatchSnapshot.decode(legacy).restoreToken)
    }
    func testReceiptTimestampIsNotThePhoneGenerationTimestamp() throws {
        let firstReceipt = Date(timeIntervalSince1970: 100)
        let nextReceipt = Date(timeIntervalSince1970: 200)
        let first = try snapshot()
        var cache = try WatchCache(snapshot: first, receivedAt: firstReceipt)
        XCTAssertEqual(cache.receivedAt, firstReceipt)
        try cache.receive(first, at: nextReceipt)
        XCTAssertEqual(cache.receivedAt, firstReceipt) // Reading the same cached context is not a new sync.
        try cache.receive(snapshot(), at: nextReceipt)
        XCTAssertEqual(cache.receivedAt, nextReceipt)
    }

}
