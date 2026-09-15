import Foundation
import FacetCore
let fields: [ContactField] = [
    .init(id: "name", kind: .name, label: "Name", displayValue: "Alex Morgan", components: ["Morgan", "Alex"]),
    .init(id: "email", kind: .email, label: "Work", displayValue: "alex@example.com", components: ["alex@example.com"]),
    .init(id: "phone", kind: .phone, label: "Personal", displayValue: "+1 202-555-0142", components: ["+1 202-555-0142"])
]
let selections: [ProfileID: Set<String>] = [.work: ["name", "email"], .personal: ["name", "phone"], .combined: ["name", "email", "phone"]]
let cards = try ProfileID.allCases.map { id in
    QRCard(id: id, matrix: try QRGenerator.make(VCard.make(fields: fields, selection: .init(fields: selections[id]!))))
}
let cache = try WatchCache(snapshot: WatchSnapshot(cards: cards))
try JSONEncoder().encode(cache).write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
