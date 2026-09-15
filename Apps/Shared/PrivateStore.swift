import Foundation

/// App-local settings/cache, excluded from backup. Never logs contact data.
enum PrivateStore {
    static func url(_ name: String) throws -> URL {
        let manager = FileManager.default
        var directory = try manager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Facet", isDirectory: true)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try directory.setResourceValues(values)
        return directory.appendingPathComponent(name)
    }
    static func read<T: Decodable>(_ type: T.Type, name: String) throws -> T? {
        let path = try url(name)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        return try JSONDecoder().decode(type, from: Data(contentsOf: path))
    }
    static func write<T: Encodable>(_ value: T, name: String) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: url(name), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}
