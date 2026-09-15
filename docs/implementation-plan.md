# Facet – Contact QR 実装プラン

作成: 2026-09-15 / 状態: 初稿（実装前にレビューする）

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

- `Sources/FacetCore`: Foundationのみの設定モデル、フィールド許可、vCard生成、同期スナップショット。
- `Apps/iOS`: Contacts読取、明示的な連絡先選択、プロファイル設定、QR生成、WatchConnectivity送信。
- `Apps/Watch`: 最新スナップショット保存、QRページ表示。
- `Apps/Shared`: QR描画、ローカル保存、WatchConnectivity共通部分。
- `Tests/FacetCoreTests`: vCardの情報漏洩防止とUTF-8、設定、同期検証。
- `project.yml` + 生成済みXcodeプロジェクト。Swift Packageとして共通ロジックをMac上でも検証できる。

## QR / Watch同期

Watch SDKにCoreImage.frameworkが存在しないことを実測したため、iPhoneでCIQRCodeGeneratorから白黒モジュール配列を生成する。WatchへはプロファイルID・名前・生成日時・許可済みvCard・対応するモジュール配列を送る。Watch側は整数物理ピクセル・白背景・黒モジュール・4モジュール余白で描画する。

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
