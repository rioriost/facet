import SwiftUI
import Combine
import FacetCore

private struct WatchCache: Codable {
    var snapshot: WatchSnapshot
    var hidden: Bool
}

@MainActor
final class WatchModel: ObservableObject {
    @Published private(set) var snapshot: WatchSnapshot?
    @Published var error: String?
    let connectivity = Connectivity()
    private var cache: WatchCache?
    init() {
        do {
            cache = try PrivateStore.read(WatchCache.self, name: "watch.json")
            try cache?.snapshot.validate()
            if cache?.hidden != true { snapshot = cache?.snapshot }
        } catch { self.error = "保存したQRを読み込めません。iPhoneから再同期してください。" }
        connectivity.onSnapshot = { [weak self] in self?.receive($0) == true }
        connectivity.readLatest()
    }
    private func receive(_ incoming: WatchSnapshot) -> Bool {
        if cache?.snapshot.id == incoming.id { return true }
        do {
            let next = WatchCache(snapshot: incoming, hidden: false)
            try PrivateStore.write(next, name: "watch.json")
            cache = next; snapshot = incoming; return true
        } catch { self.error = "QRを保存できませんでした。"; return false }
    }
    func clear() {
        do {
            // Retain only the tombstone ID, never the erased modules.
            let tombstone = WatchSnapshot(cards: [], id: cache?.snapshot.id ?? UUID())
            let next = WatchCache(snapshot: tombstone, hidden: true)
            try PrivateStore.write(next, name: "watch.json")
            cache = next; snapshot = nil
        } catch { self.error = "QRを消去できませんでした。" }
    }
}

@main
struct FacetWatchApp: App {
    @StateObject private var model = WatchModel()
    var body: some Scene { WindowGroup { WatchView(model: model) } }
}

struct WatchView: View {
    @ObservedObject var model: WatchModel
    @State private var confirmClear = false
    @Environment(\.scenePhase) private var phase
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    var body: some View {
        TabView {
            ForEach(ProfileID.allCases) { id in
                VStack(spacing: 2) {
                    Text(id.title).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
                    if let card = model.snapshot?.cards.first(where: { $0.id == id }),
                       phase == .active, !isLuminanceReduced {
                        QRView(matrix: card.matrix)
                    } else {
                        Image(systemName: id.symbol).font(.title)
                        Text("iPhoneで設定・同期してください").font(.caption2).multilineTextAlignment(.center)
                    }
                }.padding(.horizontal, 4)
            }
            ScrollView {
                VStack(spacing: 10) {
                    Text("Facet").font(.headline)
                    if let date = model.snapshot?.createdAt {
                        Text("最終同期").font(.caption)
                        Text(date, format: .dateTime.month().day().hour().minute()).font(.caption2)
                    }
                    Text("同期後はiPhoneが近くになくても表示できます。").font(.caption2)
                    Button("保存したQRを消去", role: .destructive) { confirmClear = true }
                }
            }
        }
        .tabViewStyle(.page)
        .privacySensitive()
        .onChange(of: phase) { _, next in if next == .active { model.connectivity.readLatest() } }
        .confirmationDialog("保存したQRを消去しますか？", isPresented: $confirmClear) {
            Button("消去", role: .destructive) { model.clear() }
        } message: { Text("再表示するにはiPhoneで「Watchに再同期」を押してください。") }
        .alert("確認してください", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("OK") { model.error = nil }
        } message: { Text(model.error ?? "") }
    }
}
