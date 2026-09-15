import Foundation

public enum VCard {
    public static let maximumBytes = 600
    public static func make(fields: [ContactField], selection: ProfileSelection) throws -> Data {
        let allowed = fields.filter { selection.fields.contains($0.id) }
        guard let name = allowed.first(where: { $0.kind == .name }),
              !name.displayValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw FacetError.nameRequired
        }
        var lines = ["BEGIN:VCARD", "VERSION:3.0", "FN:\(escape(name.displayValue))",
                     "N:\(structured(name.components, count: 5))"]
        for field in allowed where field.kind != .name {
            let value = escape(field.components.first ?? "")
            switch field.kind {
            case .name: break
            case .organization: lines.append("ORG:\(value)")
            case .title: lines.append("TITLE:\(value)")
            case .phone: lines.append("TEL:\(value)")
            case .email: lines.append("EMAIL;TYPE=INTERNET:\(value)")
            case .address: lines.append("ADR:\(structured(field.components, count: 7))")
            case .url: lines.append("URL:\(value)")
            }
        }
        lines.append("END:VCARD")
        let data = Data((lines.map(fold).joined(separator: "\r\n") + "\r\n").utf8)
        guard data.count <= maximumBytes else { throw FacetError.tooDense }
        return data
    }
    static func structured(_ values: [String], count: Int) -> String {
        (0..<count).map { escape($0 < values.count ? values[$0] : "") }.joined(separator: ";")
    }
    public static func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
    }
    /// RFC 2425 folding: physical lines <= 75 octets, continuation includes one space.
    public static func fold(_ line: String) -> String {
        var result = "", octets = 0
        for scalar in line.unicodeScalars {
            let text = String(scalar), length = text.utf8.count
            if octets + length > 75 { result += "\r\n "; octets = 1 }
            result += text; octets += length
        }
        return result
    }
}
