#if DEBUG && targetEnvironment(simulator)
import Contacts

extension ContactRepository {
    /// Only available in Debug Simulator builds. Creates/updates/deletes one named test contact,
    /// never touches a physical address book, and requires real Contacts authorization.
    func prepareUITestContact() throws -> String {
        let store = CNContactStore()
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            throw NSError(domain: "FacetUITest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Grant Simulator Contacts access before running the fixture test."])
        }
        let marker = "FacetUITestFixture"
        let matches = try store.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: marker),
                                               keysToFetch: [CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor])
        if let existing = matches.first(where: { $0.familyName == marker && $0.givenName == "理央" }) {
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("--fixture-delete") {
                let request = CNSaveRequest()
                request.delete(existing.mutableCopy() as! CNMutableContact)
                try store.execute(request)
            } else if arguments.contains("--fixture-update") {
                let updated = existing.mutableCopy() as! CNMutableContact
                updated.emailAddresses = existing.emailAddresses.map {
                    $0.value as String == "work@facet.example" ? $0.settingValue("updated@facet.example" as NSString) : $0
                }
                if !updated.emailAddresses.contains(where: { $0.value as String == "new-private@facet.example" }) {
                    updated.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: "new-private@facet.example" as NSString))
                }
                let request = CNSaveRequest(); request.update(updated)
                try store.execute(request)
            }
            return existing.identifier
        }
        guard !ProcessInfo.processInfo.arguments.contains("--fixture-delete") else {
            throw NSError(domain: "FacetUITest", code: 2, userInfo: [NSLocalizedDescriptionKey: "No test fixture exists to delete."])
        }
        let contact = CNMutableContact()
        contact.familyName = marker; contact.givenName = "理央"
        contact.emailAddresses = [
            CNLabeledValue(label: CNLabelWork, value: "work@facet.example" as NSString),
            CNLabeledValue(label: CNLabelHome, value: "private@facet.example" as NSString)
        ]
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "090-0000-0000"))]
        let request = CNSaveRequest(); request.add(contact, toContainerWithIdentifier: nil)
        try store.execute(request)
        return contact.identifier
    }
}
#endif
