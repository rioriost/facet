import Foundation
import Combine
import Contacts
import FacetCore

@MainActor
final class PhoneModel: ObservableObject {
    @Published private(set) var settings = FacetSettings()
    @Published private(set) var fields: [ContactField] = []
    @Published private(set) var contacts: [ContactSummary] = []
    @Published private(set) var cards: [QRCard] = []
    @Published private(set) var issues: [ProfileID: String] = [:]
    @Published var error: String?
    @Published private(set) var authorization = CNContactStore.authorizationStatus(for: .contacts)
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
                .init(id: "name", kind: .name, label: L10n.text("field.name"), displayValue: "藤田 理央", components: ["藤田", "理央"]),
                .init(id: "work-email", kind: .email, label: L10n.fieldLabel(L10n.text("field.email"), L10n.text("field.work")), displayValue: "rio@example.com", components: ["rio@example.com"]),
                .init(id: "private-phone", kind: .phone, label: L10n.fieldLabel(L10n.text("field.phone"), L10n.text("field.home")), displayValue: "090-0000-0000", components: ["090-0000-0000"])
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
    func requestAccess() async {
        do { _ = try await repository.requestAccess(); await refresh() }
        catch { self.error = L10n.text("error.access") }
    }
    func refresh() async {
        guard !demo else { return }
        #if DEBUG && targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("--contacts-fixture") {
            if fixtureTask == nil { fixtureTask = Task { try await repository.prepareUITestContact() } }
            do {
                let id = try await fixtureTask!.value
                if settings.contactID == nil {
                    var next = settings; next.selectContact(id)
                    guard save(next) else { return }
                }
            } catch { self.error = error.localizedDescription; return }
        }
        #endif
        let token = UUID(); refreshID = token
        authorization = CNContactStore.authorizationStatus(for: .contacts)
        fields = []; cards = []
        guard authorization == .authorized || authorization == .limited else {
            contacts = []; rebuild(); return
        }
        let contactID = settings.contactID
        do {
            let list = try await repository.list()
            guard refreshID == token else { return }
            contacts = list
            let loaded = try await contactID.mapAsync { try await self.repository.fields(for: $0) } ?? []
            guard refreshID == token else { return }
            contacts = list; fields = loaded; rebuild()
        } catch {
            guard refreshID == token else { return }
            fields = []; rebuild()
            self.error = L10n.text("error.contact.read")
        }
    }
    func selectContact(_ id: String) async {
        var next = settings; next.selectContact(id)
        guard save(next) else { return }
        fields = []; rebuild()
        await refresh()
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
        if save(next) { fields = []; contacts = []; rebuild(force: true) }
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

private extension Optional where Wrapped == String {
    func mapAsync<T>(_ transform: (String) async throws -> T) async rethrows -> T? {
        if let value = self { return try await transform(value) }
        return nil
    }
}
