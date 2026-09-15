import Foundation
import Combine
import WatchConnectivity
import FacetCore

@MainActor
final class Connectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var status = L10n.text("sync.checking")
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
        if session == nil { status = L10n.text("sync.unavailable") }
    }
    func send(_ snapshot: WatchSnapshot) {
        pending = snapshot
        transmit()
    }
    func transmit() {
        guard let session, session.activationState == .activated else {
            status = L10n.text("sync.waiting"); return
        }
        #if os(iOS)
        guard session.isPaired else { status = L10n.text("sync.unpaired"); return }
        guard session.isWatchAppInstalled else { status = L10n.text("sync.install"); return }
        guard let pending else { return }
        do {
            try session.updateApplicationContext(["snapshot": pending.encoded()])
            status = acknowledged == pending.id.uuidString ? acknowledgmentStatus : L10n.text("sync.waiting")
        } catch { status = L10n.text("sync.failed") }
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
            guard let hidden = onSnapshot?(snapshot) else { status = L10n.text("error.save"); return }
            acknowledge(snapshot, hidden: hidden)
        } catch { status = L10n.text("sync.retry") }
        #endif
    }
    private var acknowledgmentStatus: String {
        acknowledgedHidden ? L10n.text("sync.erased") : L10n.text("sync.received")
    }
    #if os(watchOS)
    func acknowledge(_ snapshot: WatchSnapshot, hidden: Bool) {
        do {
            try session?.updateApplicationContext(["ack": snapshot.id.uuidString, "hidden": hidden])
            status = hidden ? L10n.text("sync.hidden") : L10n.text("sync.complete")
        } catch { status = L10n.text("sync.ack") }
    }
    #endif
    func readLatest() {
        if let session { receive(session.receivedApplicationContext) }
    }
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if error != nil { self.status = L10n.text("sync.connection"); return }
            self.readLatest(); self.transmit()
        }
    }
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in self.receive(applicationContext) }
    }
    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in self.status = L10n.text("sync.switching"); self.acknowledged = nil }
    }
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.transmit() }
    }
    #endif
}
