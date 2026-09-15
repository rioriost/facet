import Foundation

/// A local erasure stays in effect across phone restarts and ordinary sync updates.
/// Only the phone's explicit restore action changes restoreToken.
public struct WatchCache: Codable, Equatable, Sendable {
    public private(set) var snapshot: WatchSnapshot
    public private(set) var hidden: Bool
    public private(set) var receivedAt: Date?

    public init(snapshot: WatchSnapshot, hidden: Bool = false, receivedAt: Date = Date()) throws {
        try snapshot.validate()
        self.hidden = hidden
        self.receivedAt = receivedAt
        self.snapshot = hidden ? Self.tombstone(for: snapshot) : snapshot
    }

    public mutating func receive(_ incoming: WatchSnapshot, at date: Date = Date()) throws {
        try incoming.validate()
        guard incoming.id != snapshot.id else { return }
        receivedAt = date
        if hidden && incoming.restoreToken == snapshot.restoreToken {
            snapshot = Self.tombstone(for: incoming)
        } else {
            snapshot = incoming
            hidden = false
        }
    }

    public mutating func clear() {
        snapshot = Self.tombstone(for: snapshot)
        hidden = true
    }

    private static func tombstone(for source: WatchSnapshot) -> WatchSnapshot {
        WatchSnapshot(cards: [], id: source.id, createdAt: source.createdAt, restoreToken: source.restoreToken)
    }
}
