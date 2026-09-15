import Contacts
import FacetCore

actor ContactRepository {
    private let store = CNContactStore()
    static let keys: [CNKeyDescriptor] = [
        CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey,
        CNContactMiddleNameKey, CNContactNamePrefixKey, CNContactNameSuffixKey,
        CNContactOrganizationNameKey, CNContactJobTitleKey, CNContactPhoneNumbersKey,
        CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactUrlAddressesKey
    ] as [CNKeyDescriptor]

    func fields(for id: String) throws -> [ContactField] {
        let c = try store.unifiedContact(withIdentifier: id, keysToFetch: Self.keys)
        return Self.fields(from: c)
    }
    static func fields(from c: CNContact) -> [ContactField] {
        var fields: [ContactField] = []
        func add(_ id: String, _ kind: FieldKind, _ label: String, _ value: String, _ components: [String]? = nil) {
            if !value.isEmpty { fields.append(.init(id: id, kind: kind, label: label, displayValue: value, components: components ?? [value])) }
        }
        let family = c.isKeyAvailable(CNContactFamilyNameKey) ? c.familyName : ""
        let given = c.isKeyAvailable(CNContactGivenNameKey) ? c.givenName : ""
        let middle = c.isKeyAvailable(CNContactMiddleNameKey) ? c.middleName : ""
        let prefix = c.isKeyAvailable(CNContactNamePrefixKey) ? c.namePrefix : ""
        let suffix = c.isKeyAvailable(CNContactNameSuffixKey) ? c.nameSuffix : ""
        let name = [prefix, family, middle, given, suffix].filter { !$0.isEmpty }.joined(separator: " ")
        add("name", .name, L10n.text("field.name"), name, [family, given, middle, prefix, suffix])
        if c.isKeyAvailable(CNContactOrganizationNameKey) { add("organization", .organization, L10n.text("field.organization"), c.organizationName) }
        if c.isKeyAvailable(CNContactJobTitleKey) { add("title", .title, L10n.text("field.title"), c.jobTitle) }
        for p in c.isKeyAvailable(CNContactPhoneNumbersKey) ? c.phoneNumbers : [] { add("phone:\(p.identifier)", .phone, L10n.fieldLabel(L10n.text("field.phone"), label(p.label)), p.value.stringValue) }
        for e in c.isKeyAvailable(CNContactEmailAddressesKey) ? c.emailAddresses : [] { add("email:\(e.identifier)", .email, L10n.fieldLabel(L10n.text("field.email"), label(e.label)), e.value as String) }
        for u in c.isKeyAvailable(CNContactUrlAddressesKey) ? c.urlAddresses : [] { add("url:\(u.identifier)", .url, L10n.fieldLabel(L10n.text("field.url"), label(u.label)), u.value as String) }
        for a in c.isKeyAvailable(CNContactPostalAddressesKey) ? c.postalAddresses : [] {
            let p = a.value
            add("address:\(a.identifier)", .address, L10n.fieldLabel(L10n.text("field.address"), label(a.label)),
                CNPostalAddressFormatter.string(from: p, style: .mailingAddress),
                ["", "", p.street, p.city, p.state, p.postalCode, p.country])
        }
        let labels = (c.isKeyAvailable(CNContactPhoneNumbersKey) ? c.phoneNumbers.map { ("phone:\($0.identifier)", $0.label) } : [])
            + (c.isKeyAvailable(CNContactEmailAddressesKey) ? c.emailAddresses.map { ("email:\($0.identifier)", $0.label) } : [])
            + (c.isKeyAvailable(CNContactUrlAddressesKey) ? c.urlAddresses.map { ("url:\($0.identifier)", $0.label) } : [])
            + (c.isKeyAvailable(CNContactPostalAddressesKey) ? c.postalAddresses.map { ("address:\($0.identifier)", $0.label) } : [])
        for index in fields.indices { fields[index].contactLabel = labels.first(where: { $0.0 == fields[index].id })?.1 }
        return fields
    }
    static func localized(_ fields: [ContactField]) -> [ContactField] {
        fields.map { field in
            var next = field
            let title: String
            switch field.kind {
            case .name: title = L10n.text("field.name")
            case .organization: title = L10n.text("field.organization")
            case .title: title = L10n.text("field.title")
            case .phone: title = L10n.text("field.phone")
            case .email: title = L10n.text("field.email")
            case .url: title = L10n.text("field.url")
            case .address: title = L10n.text("field.address")
            }
            switch field.kind {
            case .phone, .email, .url, .address: next.label = L10n.fieldLabel(title, label(field.contactLabel))
            default: next.label = title
            }
            return next
        }
    }
    private static func label(_ raw: String?) -> String {
        raw.map { CNLabeledValue<NSString>.localizedString(forLabel: $0) } ?? L10n.text("field.other")
    }
}
