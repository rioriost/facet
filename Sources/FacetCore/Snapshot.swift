import Foundation

public struct QRMatrix: Codable, Equatable, Sendable {
    public let width: Int
    public let modules: Data
    public init(width: Int, modules: Data) throws {
        self.width = width; self.modules = modules
        try validate()
    }
    public func validate() throws {
        guard (21...89).contains(width), (width - 21) % 4 == 0,
              modules.count == width * width, modules.allSatisfy({ $0 <= 1 }) else {
            throw FacetError.invalidSnapshot
        }
    }
}

public struct QRCard: Codable, Equatable, Identifiable, Sendable {
    public let id: ProfileID
    public let matrix: QRMatrix
    public init(id: ProfileID, matrix: QRMatrix) { self.id = id; self.matrix = matrix }
}

public struct WatchSnapshot: Codable, Equatable, Sendable {
    public var version: Int = 1
    public var id: UUID
    public var createdAt: Date
    public var cards: [QRCard]
    public init(cards: [QRCard], id: UUID = UUID(), createdAt: Date = Date()) {
        self.id = id; self.createdAt = createdAt; self.cards = cards
    }
    public func validate() throws {
        guard version == 1, cards.count <= 3, Set(cards.map(\.id)).count == cards.count else {
            throw FacetError.invalidSnapshot
        }
        try cards.forEach { try $0.matrix.validate() }
    }
    public func encoded() throws -> Data {
        try validate()
        let data = try JSONEncoder().encode(self)
        guard data.count <= 60_000 else { throw FacetError.invalidSnapshot }
        return data
    }
    public static func decode(_ data: Data) throws -> Self {
        guard data.count <= 60_000 else { throw FacetError.invalidSnapshot }
        let snapshot = try JSONDecoder().decode(Self.self, from: data)
        try snapshot.validate()
        return snapshot
    }
}
