import SwiftUI
import Contacts
import ContactsUI
import FacetCore

struct SettingsView: View {
    @ObservedObject var model: PhoneModel
    @State private var profile: ProfileID = .work
    @State private var showContacts = false
    @State private var showAccess = false
    @State private var showReset = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(L10n.text("intro.title")).font(.headline)
                    Text(L10n.text("intro.body"))
                }
                Section(L10n.text("contact.source")) {
                    if model.authorization == .notDetermined {
                        Button(L10n.text("contact.allow")) { Task { await model.requestAccess() } }
                    } else if model.authorization == .denied || model.authorization == .restricted {
                        Text(L10n.text("contact.denied"))
                        Button(L10n.text("contact.settings")) { openURL(URL(string: UIApplication.openSettingsURLString)!) }
                    } else {
                        Button { showContacts = true } label: {
                            LabeledContent(L10n.text("contact.mine"), value: model.fields.first(where: { $0.kind == .name })?.displayValue ?? L10n.text("contact.select"))
                        }
                        .accessibilityIdentifier("select-contact")
                        if model.authorization == .limited {
                            Button(L10n.text("contact.access")) { showAccess = true }
                        }
                    }
                }
                Section {
                    Picker(L10n.text("profile.picker"), selection: $profile) {
                        ForEach(ProfileID.allCases) { Text($0.title).tag($0) }
                    }
                    ForEach(model.fields) { field in
                        Toggle(isOn: Binding(
                            get: { model.settings.profiles[profile]?.fields.contains(field.id) == true },
                            set: { model.setField(field.id, in: profile, enabled: $0) }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(field.label).font(.caption).foregroundStyle(.secondary)
                                Text(field.displayValue)
                            }
                        }.accessibilityIdentifier("field-\(field.id)")
                    }
                    if let issue = model.issues[profile] { Text(issue).foregroundStyle(.secondary) }
                    if let card = model.cards.first(where: { $0.id == profile }) {
                        QRView(matrix: card.matrix).frame(maxWidth: 220).frame(maxWidth: .infinity)
                    }
                } header: { Text(L10n.text("fields.title")) } footer: {
                    Text(L10n.text("fields.footer"))
                }
                SyncSection(connectivity: model.connectivity, resync: model.resync)
                Section(L10n.text("about")) {
                    Text(L10n.text("about.free"))
                    NavigationLink(L10n.text("privacy")) {
                        ScrollView {
                            Text(L10n.text("privacy.body"))
                                .padding()
                            Link(L10n.text("privacy.policy"), destination: URL(string: "https://github.com/rioriost/facet/blob/main/PRIVACY_POLICY.md")!).padding()
                            Link(L10n.text("support"), destination: URL(string: "https://github.com/rioriost/facet/blob/main/SUPPORT.md")!).padding()
                        }.navigationTitle(L10n.text("privacy"))
                    }
                    Button(L10n.text("reset.button"), role: .destructive) { showReset = true }
                }
            }
            .navigationTitle(L10n.text("settings.title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("done")) { model.finishSetup(); if model.settings.onboardingComplete { dismiss() } }
                }
            }
            .sheet(isPresented: $showContacts) { ContactListView(model: model) }
            .contactAccessPicker(isPresented: $showAccess) { _ in Task { await model.refresh() } }
            .confirmationDialog(L10n.text("reset.confirm"), isPresented: $showReset, titleVisibility: .visible) {
                Button(L10n.text("reset.all"), role: .destructive) { model.reset() }
            } message: { Text(L10n.text("reset.footer")) }
        }
        .alert(L10n.text("attention"), isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button(L10n.text("ok")) { model.error = nil }
        } message: { Text(model.error ?? "") }
        .interactiveDismissDisabled(!model.settings.onboardingComplete)
    }
}

private struct SyncSection: View {
    @ObservedObject var connectivity: Connectivity
    let resync: () -> Void
    var body: some View {
        Section {
            Text(connectivity.status).font(.subheadline)
            Button(L10n.text("sync.button")) { resync() }
        } header: { Text("Apple Watch") } footer: {
            Text(L10n.text("sync.footer"))
        }
    }
}

private struct ContactListView: View {
    @ObservedObject var model: PhoneModel
    @State private var search = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(model.contacts.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }) { contact in
                Button(contact.name.isEmpty ? L10n.text("contact.unnamed") : contact.name) {
                    Task { await model.selectContact(contact.id); dismiss() }
                }
            }
            .overlay { if model.contacts.isEmpty { ContentUnavailableView(L10n.text("contact.empty"), systemImage: "person.crop.rectangle", description: Text(L10n.text("contact.empty.body"))) } }
            .searchable(text: $search, prompt: L10n.text("contact.search"))
            .navigationTitle(L10n.text("contact.choose"))
            .toolbar { Button(L10n.text("cancel")) { dismiss() } }
        }
    }
}
