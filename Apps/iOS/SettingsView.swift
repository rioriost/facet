import SwiftUI
import Contacts
import ContactsUI
import FacetCore

struct SettingsView: View {
    @ObservedObject var model: PhoneModel
    @State private var profile: ProfileID = .work
    @State private var showContacts = false
    @State private var showAccess = false
    @State private var showReset = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("相手に見せる、自分の一面。").font(.headline)
                    Text("連絡先を選び、QRごとに公開する項目をオンにしてください。設定はその都度保存されます。")
                }
                Section("元の連絡先") {
                    if model.authorization == .notDetermined {
                        Button("Apple Contactsへのアクセスを許可") { Task { await model.requestAccess() } }
                    } else if model.authorization == .denied || model.authorization == .restricted {
                        Text("連絡先の使用が許可されていません。")
                        Button("iPhoneの設定を開く") { openURL(URL(string: UIApplication.openSettingsURLString)!) }
                    } else {
                        Button { showContacts = true } label: {
                            LabeledContent("自分の連絡先", value: model.fields.first(where: { $0.kind == .name })?.displayValue ?? "選択してください")
                        }
                        .accessibilityIdentifier("select-contact")
                        if model.authorization == .limited {
                            Button("アクセスを許可する連絡先を変更") { showAccess = true }
                        }
                    }
                }
                Section {
                    Picker("QRプロファイル", selection: $profile) {
                        ForEach(ProfileID.allCases) { Text($0.title).tag($0) }
                    }
                    ForEach(model.fields) { field in
                        Toggle(isOn: Binding(
                            get: { model.settings.profiles[profile]?.fields.contains(field.id) == true },
                            set: { model.setField(field.id, in: profile, enabled: $0) }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(field.label).font(.caption).foregroundStyle(.secondary)
                                Text(field.displayValue)
                            }
                        }.accessibilityIdentifier("field-\(field.id)")
                    }
                    if let issue = model.issues[profile] { Text(issue).foregroundStyle(.secondary) }
                    if let card = model.cards.first(where: { $0.id == profile }) {
                        QRView(matrix: card.matrix).frame(maxWidth: 220).frame(maxWidth: .infinity)
                    }
                } header: { Text("公開する項目") } footer: {
                    Text("初期状態はすべて非公開です。氏名はQRに必要です。「双方」も独立した設定で、自動的には統合しません。元の連絡先を変えると選択をリセットします。")
                }
                SyncSection(connectivity: model.connectivity, resync: model.resync)
                Section("このアプリについて") {
                    Text("Facet – Contact QR · 完全無料")
                    NavigationLink("プライバシー") {
                        ScrollView {
                            Text("連絡先はiPhone内で処理し、開発者へ送信しません。Watchには公開を許可した情報のQRだけを送ります。QRを読み取った相手はその情報を保存できます。\n\nWatchがオフラインの間は、iPhoneで設定を変更しても以前のQRが残ります。Watchの『保存したQRを消去』から端末内のQRを消去できます。\n\n写真・メモ・誕生日はQRに含めません。広告、解析、アカウント、アプリ内課金はありません。\n\nプライバシーポリシーとサポートはGitHubで公開しています。お問い合わせに連絡先情報やQRを添付しないでください。")
                                .padding()
                            Link("Privacy Policy", destination: URL(string: "https://github.com/rioriost/facet/blob/main/PRIVACY_POLICY.md")!).padding()
                            Link("Support", destination: URL(string: "https://github.com/rioriost/facet/blob/main/SUPPORT.md")!).padding()
                        }.navigationTitle("プライバシー")
                    }
                    Button("設定とQRをすべて消去", role: .destructive) { showReset = true }
                }
            }
            .navigationTitle("公開設定")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { model.finishSetup(); if model.settings.onboardingComplete { dismiss() } }
                }
            }
            .sheet(isPresented: $showContacts) { ContactListView(model: model) }
            .contactAccessPicker(isPresented: $showAccess) { _ in Task { await model.refresh() } }
            .confirmationDialog("公開設定と保存済みQRを消去しますか？", isPresented: $showReset, titleVisibility: .visible) {
                Button("すべて消去", role: .destructive) { model.reset() }
            } message: { Text("オフラインのWatchのQRは、再接続するかWatchで消去するまで残ります。") }
        }
        .alert("確認してください", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("OK") { model.error = nil }
        } message: { Text(model.error ?? "") }
        .interactiveDismissDisabled(!model.settings.onboardingComplete)
    }
}

private struct SyncSection: View {
    @ObservedObject var connectivity: Connectivity
    let resync: () -> Void
    var body: some View {
        Section {
            Text(connectivity.status).font(.subheadline)
            Button("Watchに再同期") { resync() }
        } header: { Text("Apple Watch") } footer: {
            Text("Watchがオフラインの間は、以前のQRが残ります。急いで消す場合はWatch側で消去してください。")
        }
    }
}

private struct ContactListView: View {
    @ObservedObject var model: PhoneModel
    @State private var search = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(model.contacts.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }) { contact in
                Button(contact.name.isEmpty ? "名前のない連絡先" : contact.name) {
                    Task { await model.selectContact(contact.id); dismiss() }
                }
            }
            .overlay { if model.contacts.isEmpty { ContentUnavailableView("連絡先がありません", systemImage: "person.crop.rectangle", description: Text("Contactsに自分の連絡先を追加し、アクセスを許可してください。")) } }
            .searchable(text: $search, prompt: "名前で検索")
            .navigationTitle("自分の連絡先を選択")
            .toolbar { Button("キャンセル") { dismiss() } }
        }
    }
}
