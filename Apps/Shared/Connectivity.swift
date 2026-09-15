import Foundation
import Combine
import WatchConnectivity
import FacetCore

@MainActor
final class Connectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var status = "Watchを確認中"
    /// Returns the local hidden state, or nil when saving failed.
    var onSnapshot: ((WatchSnapshot) -> Bool?)?
    private var pending: WatchSnapshot?
    private var acknowledged: String?
    private var acknowledgedHidden = false
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
            status = acknowledged == pending.id.uuidString ? acknowledgmentStatus : "Watchへの送信待ち"
        } catch { status = "Watchへの送信に失敗しました。設定から再同期してください。" }
        #endif
    }
    private func receive(_ context: [String: Any]) {
        #if os(iOS)
        if let ack = context["ack"] as? String {
            acknowledged = ack
            acknowledgedHidden = context["hidden"] as? Bool ?? false
            if ack == pending?.id.uuidString { status = acknowledgmentStatus }
        }
        #else
        guard let data = context["snapshot"] as? Data else { return }
        do {
            let snapshot = try WatchSnapshot.decode(data)
            guard let hidden = onSnapshot?(snapshot) else { status = "保存できませんでした"; return }
            acknowledge(snapshot, hidden: hidden)
        } catch { status = "同期できません。iPhoneから再同期してください。" }
        #endif
    }
    private var acknowledgmentStatus: String {
        acknowledgedHidden ? "Watchで消去済み。再同期すると復元します" : "Watch受信済み"
    }
    #if os(watchOS)
    func acknowledge(_ snapshot: WatchSnapshot, hidden: Bool) {
        do {
            try session?.updateApplicationContext(["ack": snapshot.id.uuidString, "hidden": hidden])
            status = hidden ? "QRはこのWatchで消去済み" : "同期済み"
        } catch { status = "保存済み・iPhoneへの受信確認は送信待ち" }
    }
    #endif
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
