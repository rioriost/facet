import Foundation

public enum ProfileID: String, Codable, CaseIterable, Identifiable, Sendable {
    case work, personal, combined
    public var id: String { rawValue }
    public var title: String {
        switch self { case .work: return L10n.text("profile.work"); case .personal: return L10n.text("profile.personal"); case .combined: return L10n.text("profile.combined") }
    }
    public var symbol: String {
        switch self { case .work: return "briefcase"; case .personal: return "house"; case .combined: return "square.stack.3d.up" }
    }
}

public struct ProfileSelection: Codable, Equatable, Sendable {
    public var fields: Set<String>
    public init(fields: Set<String> = []) { self.fields = fields }
}

public struct FacetSettings: Codable, Equatable, Sendable {
    public var contactID: String?
    public var contactFields: [ContactField]?
    public var profiles: [ProfileID: ProfileSelection]
    public var onboardingComplete: Bool
    public var watchRestoreToken: UUID?
    public init() {
        contactID = nil
        profiles = Dictionary(uniqueKeysWithValues: ProfileID.allCases.map { ($0, ProfileSelection()) })
        onboardingComplete = false
    }
    public mutating func selectContact(_ id: String) {
        guard contactID != id else { return }
        contactID = id
        contactFields = nil
        profiles = Dictionary(uniqueKeysWithValues: ProfileID.allCases.map { ($0, ProfileSelection()) })
    }
}

public enum FieldKind: String, Codable, Sendable {
    case name, organization, department, title, phone, email, address, url
}

/// Values are components, never raw vCard syntax. Name: family/given/middle/prefix/suffix.
/// Address: PO box/extended/street/city/region/postcode/country.
public struct ContactField: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var kind: FieldKind
    public var label: String
    public var contactLabel: String?
    public var displayValue: String
    public var components: [String]
    public init(id: String, kind: FieldKind, label: String, displayValue: String, components: [String]) {
        self.id = id; self.kind = kind; self.label = label
        self.displayValue = displayValue; self.components = components
    }
}

public enum FacetError: Error, LocalizedError, Equatable {
    case nameRequired, tooDense, invalidSnapshot
    public var errorDescription: String? {
        switch self {
        case .nameRequired: return L10n.text("error.name")
        case .tooDense: return L10n.text("error.dense")
        case .invalidSnapshot: return L10n.text("error.snapshot")
        }
    }
}
