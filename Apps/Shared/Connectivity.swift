import Foundation
import Combine
import WatchConnectivity
import FacetCore

@MainActor
final class Connectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var status = "Watchを確認中"
    var onSnapshot: ((WatchSnapshot) -> Bool)?
    private var pending: WatchSnapshot?
    private var acknowledged: String?
    private let session: WCSession? = WCSession.isSupported() ? .default : nil

    override init() {
        super.init()
        session?.delegate = self
        session?.activate()
        if session == nil { status = "この環境ではWatch同期を利用できません" }
    }
    func send(_ snapshot: WatchSnapshot) {
        pending = snapshot
        transmit()
    }
    func transmit() {
        guard let session, session.activationState == .activated else {
            status = "Watchへの送信待ち"; return
        }
        #if os(iOS)
        guard session.isPaired else { status = "Apple Watchがペアリングされていません"; return }
        guard session.isWatchAppInstalled else { status = "WatchにFacetをインストールしてください"; return }
        guard let pending else { return }
        do {
            try session.updateApplicationContext(["snapshot": pending.encoded()])
            status = acknowledged == pending.id.uuidString ? "Watch受信済み" : "Watchへの送信待ち"
        } catch { status = "Watchへの送信に失敗しました。設定から再同期してください。" }
        #endif
    }
    private func receive(_ context: [String: Any]) {
        #if os(iOS)
        if let ack = context["ack"] as? String {
            acknowledged = ack
            if ack == pending?.id.uuidString { status = "Watch受信済み" }
        }
        #else
        guard let data = context["snapshot"] as? Data else { return }
        do {
            let snapshot = try WatchSnapshot.decode(data)
            guard onSnapshot?(snapshot) == true else { status = "保存できませんでした"; return }
            try session?.updateApplicationContext(["ack": snapshot.id.uuidString])
            status = "同期済み"
        } catch { status = "同期できません。iPhoneから再同期してください。" }
        #endif
    }
    func readLatest() {
        if let session { receive(session.receivedApplicationContext) }
    }
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if error != nil { self.status = "Watchの接続を開始できませんでした"; return }
            self.readLatest(); self.transmit()
        }
    }
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in self.receive(applicationContext) }
    }
    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in self.status = "Watchを切替中"; self.acknowledged = nil }
    }
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.transmit() }
    }
    #endif
}
