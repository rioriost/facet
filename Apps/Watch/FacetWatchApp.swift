import SwiftUI
import Combine
import FacetCore

@MainActor
final class WatchModel: ObservableObject {
    @Published private(set) var snapshot: WatchSnapshot?
    @Published var error: String?
    @Published private(set) var synchronizedAt: Date?
    let connectivity = Connectivity()
    private var cache: WatchCache?
    init() {
        do {
            cache = try PrivateStore.read(WatchCache.self, name: "watch.json")
            try cache?.snapshot.validate()
            synchronizedAt = cache?.receivedAt
            if cache?.hidden != true { snapshot = cache?.snapshot }
        } catch { self.error = "保存したQRを読み込めません。iPhoneから再同期してください。" }
        connectivity.onSnapshot = { [weak self] in self?.receive($0) }
        connectivity.readLatest()
    }
    private func receive(_ incoming: WatchSnapshot) -> Bool? {
        do {
            var next: WatchCache
            if let cache {
                next = cache
                try next.receive(incoming)
            } else {
                next = try WatchCache(snapshot: incoming)
            }
            try PrivateStore.write(next, name: "watch.json")
            cache = next; snapshot = next.hidden ? nil : next.snapshot
            synchronizedAt = next.receivedAt
            return next.hidden
        } catch { self.error = "QRを保存できませんでした。"; return nil }
    }
    func clear() {
        do {
            var next = try cache ?? WatchCache(snapshot: WatchSnapshot(cards: []))
            next.clear()
            try PrivateStore.write(next, name: "watch.json")
            cache = next; snapshot = nil
            connectivity.acknowledge(next.snapshot, hidden: true)
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
                    WatchSyncStatus(connectivity: model.connectivity)
                    if let date = model.synchronizedAt {
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

private struct WatchSyncStatus: View {
    @ObservedObject var connectivity: Connectivity
    var body: some View { Text(connectivity.status).font(.caption2).multilineTextAlignment(.center) }
}
