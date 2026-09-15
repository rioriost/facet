import Contacts
import FacetCore

struct ContactSummary: Identifiable, Sendable {
    let id: String
    let name: String
}

actor ContactRepository {
    private let store = CNContactStore()
    static let keys: [CNKeyDescriptor] = [
        CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey,
        CNContactMiddleNameKey, CNContactNamePrefixKey, CNContactNameSuffixKey,
        CNContactOrganizationNameKey, CNContactJobTitleKey, CNContactPhoneNumbersKey,
        CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactUrlAddressesKey
    ] as [CNKeyDescriptor]

    func requestAccess() async throws -> Bool { try await store.requestAccess(for: .contacts) }
    func list() throws -> [ContactSummary] {
        let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey] as [CNKeyDescriptor])
        request.sortOrder = .userDefault
        var contacts: [ContactSummary] = []
        try store.enumerateContacts(with: request) { contact, _ in
            let name = [contact.familyName, contact.givenName].filter { !$0.isEmpty }.joined(separator: " ")
            contacts.append(.init(id: contact.identifier, name: name.isEmpty ? contact.organizationName : name))
        }
        return contacts
    }
    func fields(for id: String) throws -> [ContactField] {
        let c = try store.unifiedContact(withIdentifier: id, keysToFetch: Self.keys)
        var fields: [ContactField] = []
        func add(_ id: String, _ kind: FieldKind, _ label: String, _ value: String, _ components: [String]? = nil) {
            if !value.isEmpty { fields.append(.init(id: id, kind: kind, label: label, displayValue: value, components: components ?? [value])) }
        }
        let name = [c.namePrefix, c.familyName, c.middleName, c.givenName, c.nameSuffix].filter { !$0.isEmpty }.joined(separator: " ")
        add("name", .name, L10n.text("field.name"), name, [c.familyName, c.givenName, c.middleName, c.namePrefix, c.nameSuffix])
        add("organization", .organization, L10n.text("field.organization"), c.organizationName)
        add("title", .title, L10n.text("field.title"), c.jobTitle)
        for p in c.phoneNumbers { add("phone:\(p.identifier)", .phone, L10n.fieldLabel(L10n.text("field.phone"), label(p.label)), p.value.stringValue) }
        for e in c.emailAddresses { add("email:\(e.identifier)", .email, L10n.fieldLabel(L10n.text("field.email"), label(e.label)), e.value as String) }
        for u in c.urlAddresses { add("url:\(u.identifier)", .url, L10n.fieldLabel(L10n.text("field.url"), label(u.label)), u.value as String) }
        for a in c.postalAddresses {
            let p = a.value
            add("address:\(a.identifier)", .address, L10n.fieldLabel(L10n.text("field.address"), label(a.label)),
                CNPostalAddressFormatter.string(from: p, style: .mailingAddress),
                ["", "", p.street, p.city, p.state, p.postalCode, p.country])
        }
        return fields
    }
    private func label(_ raw: String?) -> String {
        raw.map { CNLabeledValue<NSString>.localizedString(forLabel: $0) } ?? L10n.text("field.other")
    }
}
