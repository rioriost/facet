# Facet – Contact QR 実装プラン

作成: 2026-09-15 / 状態: レビュー済み・初期実装済み。実機と公開前のゲートは継続中。

## 目的・要件

Apple Contactsを正本として、自分の連絡先を仕事用・プライベート用・双方の3つのQRプロファイルで公開する。初回起動と設定アイコンから、元の連絡先と各プロファイルの公開フィールドを設定する。無料・MIT・広告なし・課金なし。QRの読取機能は実装しない。

- iPhone: `st.rio.facet`、表示名 `Facet – Contact QR`。
- 同梱watchOS companion: `st.rio.facet.watchkitapp`。表示専用、横スワイプで切替。
- vCard 3.0 / UTF-8。写真・メモ・誕生日は対象外。氏名、会社、役職、電話、メール、住所、URLを対象とする。
- Watchへ送るのは明示的に許可された情報から作るQRペイロードのみ。WatchにContacts権限を要求しない。
- アイコン: 1つのカードが3面に分かれた抽象図形。初期実装は編集可能なベクター原稿を用意し、最終ストア用アセットは後続工程で検証。

## 環境の実測

- Mac: macstudio2025.rio.st、macOS 27.0、Apple Silicon。
- `/Applications/Xcode-beta.app`: Xcode 27.0 (27A5228h)、iOS/watchOS SDK 27.0。
- システムのxcode-selectはCommandLineTools。各コマンドにDEVELOPER_DIRを指定し、システム設定は変更しない。
- Swift 6.4、XcodeGen 2.46.0。外部実行時依存なし、SwiftUI + Apple標準フレームワーク。
- iOS Simulator 26.3 / 27.0あり。watchOS Simulatorランタイムは一覧にない。
- iPhone SE (3rd gen)、iPhone 16 Pro、Apple Watch Series 10がpaired/available。
- 対象ディレクトリ・GitHubのrioriost/facetは未作成。

## 最小サポートバージョン

**iOS 18.0 / watchOS 11.0**。iOS 18のContacts限定アクセスを扱い、指定実機をカバーする。Swift言語モードは5、SDK付属コンパイラでビルドする。SDK 27 betaでの検証はApp Store提出資格の保証ではなく、提出時点でAppleが受け付けるXcodeによるArchiveが必要。

## 構成

- `Sources/FacetCore`: Foundationの設定モデル、フィールド許可、vCard生成、同期スナップショット。QRGeneratorのみ条件付きでCore Imageを使う（watchOSではコンパイル対象外）。
- `Apps/iOS`: Contacts読取、明示的な連絡先選択、プロファイル設定、共通QRGeneratorの呼出、WatchConnectivity送信。
- `Apps/Watch`: 最新スナップショット保存、QRページ表示。
- `Apps/Shared`: QR描画、ローカル保存、WatchConnectivity共通部分。
- `Tests/FacetCoreTests`: vCardの情報漏洩防止とUTF-8、設定、同期検証。
- `project.yml` + 生成済みXcodeプロジェクト。Swift Packageとして共通ロジックをMac上でも検証できる。

## QR / Watch同期

Watch SDKにCoreImage.frameworkが存在しないことを実測したため、iPhoneでCIQRCodeGeneratorから白黒モジュール配列を生成する。Watchへは固定プロファイルID・生成日時・スナップショットUUID・対応するモジュール配列のみを送る。vCard文字列は送信・保存しない。Watch側は整数物理ピクセル・白背景・黒モジュール・4モジュール余白で描画する。

WCSession.updateApplicationContextで最新状態を置換し、受信後ローカルに保存。初期未同期・転送待ち・エラーを表示。QR密度上限を超える場合は項目削減を促す。

## ステージと受入条件

1. 本プランを保存 → git init → 初回commit。
2. 技術的な弱点・過剰設計・不足項目・優先順位をレビューし、本プラン修正とレビュー記録をcommit。
3. 共通モデル・vCard・情報公開テスト実装をcommit。
4. iPhone設定・QR画面、Watch同期・表示とXcodeプロジェクトを実装してcommit。
5. ビルド、Simulator動作、実機テストを可能な範囲で実施。成功・未検証・阻害要因を区別してdocsに残す。
6. README、MIT LICENSE、PRIVACY_POLICY.md、SUPPORT.md、App Store準備事項を整備してcommit。

## テスト対象

| 対象 | 確認内容 |
|---|---|
| Swift Package | 選択外フィールド排除、vCardエスケープ・改行・日本語、サイズ制限 |
| iOS Simulator | 初回設定、設定再表示、3ページ、権限拒否・限定アクセス・元データ変更 |
| iPhone SE (3rd gen) | 小画面、文字サイズ、標準カメラでのQR読取 |
| iPhone 16 Pro | 実機起動、QRの相互読取、日本語連絡先 |
| Apple Watch Series 10 | 横スワイプ、同期、オフライン起動、密度、権限なし |

## 公開関連（設計段階）

予定GitHub: https://github.com/rioriost/facet

- Privacy Policy: https://github.com/rioriost/facet/blob/main/PRIVACY_POLICY.md
- Support: https://github.com/rioriost/facet/blob/main/SUPPORT.md
- Marketing: https://github.com/rioriost/facet
- GitHub作成・push・公開URLの到達性確認は公開工程で実施し、現時点のURLを稼働済みと扱わない。
- App Privacyは開発者による収集なしを想定。実装・SDK一覧と突き合わせて提出前に確認。
- アカウント作成、サーバー、解析SDK、広告、IAP、連絡先編集、読取、NFC、複雑なバックエンドは非目標。

## 根拠

- [Contactsへのアクセスと限定アクセス](https://developer.apple.com/documentation/contacts/accessing-the-contact-store)
- [Watchプロジェクト構成](https://developer.apple.com/documentation/watchos-apps/setting-up-a-watchos-project)
- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity/transferring-data-with-watch-connectivity)

## レビュー後の確定事項（2026-09-15）

### 公開境界

- 「双方」は独立した許可リストとする。仕事用・私用から自動で和集合を生成しない。画面でも説明する。
- 初期状態は全項目OFF。氏名も明示的に許可が必要。vCardの必須FN/Nを構成する「氏名」を未選択ならそのQRを無効にする。
- 電話・メール・住所・URLはカテゴリ単位でなく個々の値単位で選ぶ。Contactsのlabel文字列をvCardの構文として流用しない。
- 元の連絡先を変更した場合、すべての許可をリセットする。新たに追加されたContactsのフィールドは自動許可しない。
- iOSのマイカードを自動特定する公開APIに依存しない。アクセス許可後、ユーザーが正本の連絡先を明示的に選ぶ。
- バックグラウンドでの常時監視はしない。起動・復帰・Contacts変更通知で正本を再読込する。権限喪失・削除・取得失敗時はQRを非表示にし、空スナップショットをWatchへ送る。

### 同期・削除

- WatchにvCard文字列は不要。同期・保存するのは許可済みvCardから作った白黒モジュール、固定プロファイルID、生成日時、UUIDのみとする。非公開データも元のcontact identifierも送らない。
- スナップショットはバージョンとサイズを検証し、丸ごと置換する。空スナップショットは削除命令として扱う。
- updateApplicationContext受付成功は受信確認ではない。WatchからUUID受信確認を返し、「送信待ち」と「Watch受信済み」を区別する。再起動・再activation・Watch切替で最新状態を再送する。
- 通信不能中のWatchに即時の遠隔消去は保証できない。Watchにもローカル消去を用意し、設定とPrivacy Policyで説明する。ローカル消去後は同じスナップショットを再表示しない。
- 個人情報をログに書かない。ファイルはApplication Supportに原子的保存、端末のファイル保護、バックアップ除外。iPhoneは連絡先の全文を保存せずIDと許可設定のみ保存する。

### QR・品質ゲート

- vCard 3.0のCRLF、テキストエスケープ、UTF-8文字を壊さない75オクテット折返しを実装する。名前・構造化住所も区切りを個別エスケープする。
- 誤り訂正M、最大600 UTF-8 bytes、最大89モジュールを初期保守的上限とする。実機で読み取りが悪ければ下げる。自動切捨てはしない。
- 読取機能をアプリへ加えず、検証用のApple Vision/Contactsを使用して生成した日本語vCardの往復を検証する。
- Watchに最終同期日時を表示。Always Onで非active時はQRを隠す。小画面はQR領域を優先し、動的文字サイズや設定画面は実機で確認する。
- 最低OSでの実行とWatchの光学読取・通信断/再接続はリリースゲート。SDKでコンパイルできただけでは合格にしない。
