import SwiftUI
import Contacts
import FacetCore

@main
struct FacetApp: App {
    @StateObject private var model = PhoneModel()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            PhoneView(model: model)
                .task { await model.refresh() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { Task { await model.refresh() } }
                }

        }
    }
}

struct PhoneView: View {
    @ObservedObject var model: PhoneModel
    @State private var showSettings = false
    @State private var page = ProfileID.work.rawValue
    @Environment(\.scenePhase) private var phase
    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                ForEach(ProfileID.allCases) { id in
                    VStack(spacing: 20) {
                        Label(id.title, systemImage: id.symbol).font(.title2.weight(.semibold))
                        if let card = model.cards.first(where: { $0.id == id }), phase == .active {
                            QRView(matrix: card.matrix).padding(.horizontal, 26)
                                .accessibilityIdentifier("qr-\(id.rawValue)")
                            Text(L10n.text("phone.scan")).font(.subheadline).foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "person.crop.rectangle").font(.system(size: 64)).foregroundStyle(.indigo)
                            Text(model.issues[id] ?? L10n.text("phone.choose"))
                                .multilineTextAlignment(.center).padding(.horizontal)
                            Button(L10n.text("phone.configure")) { showSettings = true }.buttonStyle(.borderedProminent)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).tag(id.rawValue)
                }
                AppShareView().tag("app-share")
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle("Facet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel(L10n.text("settings")).accessibilityIdentifier("settings")
                }
            }
        }
        .onAppear { showSettings = !model.settings.onboardingComplete }
        .sheet(isPresented: $showSettings) { SettingsView(model: model) }
        .alert(L10n.text("attention"), isPresented: Binding(get: { model.error != nil && !showSettings }, set: { if !$0 { model.error = nil } })) {
            Button(L10n.text("ok")) { model.error = nil }
        } message: { Text(model.error ?? "") }
        .privacySensitive()
    }
}
