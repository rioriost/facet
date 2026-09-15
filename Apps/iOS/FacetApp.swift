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
                .onReceive(NotificationCenter.default.publisher(for: .CNContactStoreDidChange).receive(on: DispatchQueue.main)) { _ in
                    Task { await model.refresh() }
                }
        }
    }
}

struct PhoneView: View {
    @ObservedObject var model: PhoneModel
    @State private var showSettings = false
    @State private var page: ProfileID = .work
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
                            Text("相手のカメラで読み取ってもらう").font(.subheadline).foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "person.crop.rectangle").font(.system(size: 64)).foregroundStyle(.indigo)
                            Text(model.issues[id] ?? "設定で公開する項目を選んでください。")
                                .multilineTextAlignment(.center).padding(.horizontal)
                            Button("公開項目を設定") { showSettings = true }.buttonStyle(.borderedProminent)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).tag(id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle("Facet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("設定").accessibilityIdentifier("settings")
                }
            }
        }
        .onAppear { showSettings = !model.settings.onboardingComplete }
        .sheet(isPresented: $showSettings) { SettingsView(model: model) }
        .alert("確認してください", isPresented: Binding(get: { model.error != nil && !showSettings }, set: { if !$0 { model.error = nil } })) {
            Button("OK") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .privacySensitive()
    }
}
