import SwiftUI
import Contacts
import ContactsUI
import FacetCore

struct SettingsView: View {
    @ObservedObject var model: PhoneModel
    @State private var profile: ProfileID = .work
    @State private var showContacts = false
    @State private var showReset = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(L10n.text("intro.title")).font(.headline)
                    Text(L10n.text("intro.body"))
                }
                Section {
                    Button { showContacts = true } label: {
                        HStack {
                            Text(model.selectedContactName ?? L10n.text("contact.choose"))
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }.accessibilityIdentifier("select-contact")
                } header: { Text(L10n.text("contact.source")) } footer: {
                    Text(L10n.text("contact.refresh"))
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
            .confirmationDialog(L10n.text("reset.confirm"), isPresented: $showReset, titleVisibility: .visible) {
                Button(L10n.text("reset.all"), role: .destructive) { model.reset() }
            } message: { Text(L10n.text("reset.footer")) }
        }
        .background {
            SingleContactPicker(isPresented: $showContacts) { model.selectContact($0) }
                .frame(width: 0, height: 0)
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

// Present UIKit's picker directly. Wrapping its automatic dismissal in a SwiftUI
// sheet can dismiss the underlying settings sheet as well on iOS 26.
private struct SingleContactPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let selection: (CNContact) -> Void
    func makeUIViewController(context: Context) -> Presenter { Presenter() }
    func updateUIViewController(_ presenter: Presenter, context: Context) {
        presenter.isRequested = isPresented
        presenter.completion = { contact in
            isPresented = false
            if let contact { selection(contact) }
        }
        presenter.showIfNeeded()
    }
    final class Presenter: UIViewController, CNContactPickerDelegate {
        var isRequested = false
        var completion: ((CNContact?) -> Void)?
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            showIfNeeded()
        }
        func showIfNeeded() {
            guard isRequested, viewIfLoaded?.window != nil, presentedViewController == nil else { return }
            let picker = CNContactPickerViewController()
            picker.delegate = self
            picker.predicateForSelectionOfContact = NSPredicate(value: true)
            present(picker, animated: true)
        }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) { completion?(contact) }
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) { completion?(nil) }
    }
}
