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
        } catch { self.error = L10n.text("watch.read") }
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
        } catch { self.error = L10n.text("watch.save"); return nil }
    }
    func clear() {
        do {
            var next = try cache ?? WatchCache(snapshot: WatchSnapshot(cards: []))
            next.clear()
            try PrivateStore.write(next, name: "watch.json")
            cache = next; snapshot = nil
            connectivity.acknowledge(next.snapshot, hidden: true)
        } catch { self.error = L10n.text("watch.erase.error") }
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
                        Text(L10n.text("watch.setup")).font(.caption2).multilineTextAlignment(.center)
                    }
                }.padding(.horizontal, 4)
            }
            ScrollView {
                VStack(spacing: 10) {
                    Text("Facet").font(.headline)
                    WatchSyncStatus(connectivity: model.connectivity)
                    if let date = model.synchronizedAt {
                        Text(L10n.text("watch.last")).font(.caption)
                        Text(date, format: .dateTime.month().day().hour().minute()).font(.caption2)
                    }
                    Text(L10n.text("watch.offline")).font(.caption2)
                    Button(L10n.text("watch.erase"), role: .destructive) { confirmClear = true }
                }
            }
        }
        .tabViewStyle(.page)
        .privacySensitive()
        .onChange(of: phase) { _, next in if next == .active { model.connectivity.readLatest() } }
        .confirmationDialog(L10n.text("watch.confirm"), isPresented: $confirmClear) {
            Button(L10n.text("erase"), role: .destructive) { model.clear() }
        } message: { Text(L10n.text("watch.restore")) }
        .alert(L10n.text("attention"), isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button(L10n.text("ok")) { model.error = nil }
        } message: { Text(model.error ?? "") }
    }
}

private struct WatchSyncStatus: View {
    @ObservedObject var connectivity: Connectivity
    var body: some View { Text(connectivity.status).font(.caption2).multilineTextAlignment(.center) }
}
