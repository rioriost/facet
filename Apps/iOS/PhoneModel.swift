import Foundation
import Combine
import Contacts
import FacetCore

@MainActor
final class PhoneModel: ObservableObject {
    @Published private(set) var settings = FacetSettings()
    @Published private(set) var fields: [ContactField] = []
    @Published private(set) var cards: [QRCard] = []
    @Published private(set) var issues: [ProfileID: String] = [:]
    @Published var error: String?
    let connectivity = Connectivity()
    private let repository = ContactRepository()
    private var refreshID = UUID()
    private var latest: WatchSnapshot?
    private var demo = false
    #if DEBUG && targetEnvironment(simulator)
    private var fixtureTask: Task<String, Error>?
    #endif

    init() {
        #if DEBUG && targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("--reset-fixture-settings") {
            do { try PrivateStore.write(FacetSettings(), name: "settings.json") }
            catch { self.error = L10n.text("error.test") }
        }
        #endif
        #if DEBUG
        demo = ProcessInfo.processInfo.arguments.contains("--demo")
        #endif
        if demo {
            settings.contactID = "demo"
            settings.onboardingComplete = true
            fields = [
                .init(id: "name", kind: .name, label: L10n.text("field.name"), displayValue: "Alex Morgan", components: ["Morgan", "Alex"]),
                .init(id: "work-email", kind: .email, label: L10n.fieldLabel(L10n.text("field.email"), L10n.text("field.work")), displayValue: "alex@example.com", components: ["alex@example.com"]),
                .init(id: "private-phone", kind: .phone, label: L10n.fieldLabel(L10n.text("field.phone"), L10n.text("field.home")), displayValue: "+1 202-555-0142", components: ["+1 202-555-0142"])
            ]
            settings.profiles[.work] = .init(fields: ["name", "work-email"])
            settings.profiles[.personal] = .init(fields: ["name", "private-phone"])
            settings.profiles[.combined] = .init(fields: ["name", "work-email", "private-phone"])
            rebuild()
        } else {
            do { settings = try PrivateStore.read(FacetSettings.self, name: "settings.json") ?? FacetSettings() }
            catch { self.error = L10n.text("error.settings.read") }
        }
    }
    var selectedContactName: String? {
        fields.first(where: { $0.kind == .name })?.displayValue
    }
    func selectContact(_ contact: CNContact) {
        importContact(contact.identifier, fields: ContactRepository.fields(from: contact))
    }
    private func importContact(_ id: String, fields: [ContactField]) {
        refreshID = UUID()
        var next = settings
        next.selectContact(id)
        next.contactFields = fields
        guard save(next) else { return }
        self.fields = ContactRepository.localized(fields)
        rebuild()
    }
    func refresh() async {
        guard !demo else { return }
        #if DEBUG && targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("--contacts-fixture") {
            let firstFixtureLoad = fixtureTask == nil
            if firstFixtureLoad { fixtureTask = Task { try await repository.prepareUITestContact() } }
            do {
                let id = try await fixtureTask!.value
                if firstFixtureLoad && ProcessInfo.processInfo.arguments.contains("--fixture-import") {
                    importContact(id, fields: try await repository.fields(for: id))
                }
            } catch { self.error = error.localizedDescription; return }
        }
        #endif
        let token = UUID(); refreshID = token
        if let cached = settings.contactFields {
            fields = ContactRepository.localized(cached)
            rebuild()
            return
        }
        fields = []; rebuild()
        // One-time migration of build 1 settings, using only an already granted permission.
        guard let id = settings.contactID else { return }
        let authorization = CNContactStore.authorizationStatus(for: .contacts)
        guard authorization == .authorized || authorization == .limited else { return }
        do {
            let loaded = try await repository.fields(for: id)
            guard refreshID == token else { return }
            importContact(id, fields: loaded)
        } catch {
            guard refreshID == token else { return }
            // A removed/inaccessible legacy selection needs manual selection only once.
            var next = settings
            next.contactID = nil
            _ = save(next)
        }
    }
    func setField(_ id: String, in profile: ProfileID, enabled: Bool) {
        var next = settings
        var selection = next.profiles[profile] ?? .init()
        if enabled { selection.fields.insert(id) } else { selection.fields.remove(id) }
        next.profiles[profile] = selection
        if save(next) { rebuild() }
    }
    func finishSetup() {
        var next = settings; next.onboardingComplete = true
        _ = save(next)
    }
    func reset() {
        refreshID = UUID()
        var next = FacetSettings()
        next.watchRestoreToken = settings.watchRestoreToken
        if save(next) { fields = []; rebuild(force: true) }
    }
    func resync() {
        var next = settings
        next.watchRestoreToken = UUID()
        if save(next) { rebuild(force: true) }
    }
    private func save(_ next: FacetSettings) -> Bool {
        do {
            if !demo { try PrivateStore.write(next, name: "settings.json") }
            settings = next; return true
        } catch { self.error = L10n.text("error.settings.save"); return false }
    }
    private func rebuild(force: Bool = false) {
        var generated: [QRCard] = [], failures: [ProfileID: String] = [:]
        for id in ProfileID.allCases {
            do {
                let data = try VCard.make(fields: fields, selection: settings.profiles[id] ?? .init())
                generated.append(.init(id: id, matrix: try QRGenerator.make(data)))
            } catch { failures[id] = error.localizedDescription }
        }
        cards = generated; issues = failures
        if force || latest?.cards != generated {
            latest = WatchSnapshot(cards: generated, restoreToken: settings.watchRestoreToken)
        }
        if let latest, !demo { connectivity.send(latest) }
    }
}
