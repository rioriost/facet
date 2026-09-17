# Facet – Contact QR

**相手に見せる、自分の一面。**

Apple Contactsを正本に、自分の連絡先を仕事用・プライベート用・双方の3つのQRで共有するiPhoneアプリとApple Watch companionです。無料・MIT・広告なし・アプリ内課金なし。

## 開発状況

初期実装。Contactsの共有設定、vCard 3.0/UTF-8生成、QR表示、WatchConnectivityによる同期、Watchのオフライン表示を実装しています。ストア公開済み製品ではありません。検証結果と未完了項目は[テスト状況](docs/test-status.md)を参照してください。

## 特徴

- 初回起動と設定アイコンから共有する連絡先1件・共有項目を設定。
- **連絡先を編集した後は、Facetで同じ連絡先を選び直して更新してください。** 選択済みの情報はiPhone内に保存します。
- 氏名・会社名・組織／部署・役職・電話・メール・住所・URLの個々の値をプロファイル別に選択。初期状態では共有しません。
- 「双方」も独立した許可リスト。写真・メモ・誕生日は含めません。
- iPhoneとWatchで横スワイプ切替。WatchはContactsにアクセスしません。
- 「双方」の次に「Facet - Contact QRを共有」を表示。App StoreのFacetページをQRで紹介できます。連絡先の選択やWatch同期前でも利用できます。
- QR読取はiOS標準カメラへ任せます。サーバー・アカウント不要。
- 日本語・英語・簡体字・繁体字・韓国語・フランス語・ドイツ語・スペイン語2地域・ポルトガル語2地域・イタリア語の12ローカライズ。[言語対応](docs/localization.md)を参照。

## 開発環境

- 最小対応: iOS 18.0 / watchOS 11.0。
- 実測環境: Xcode 27 (27A266a)、Swift 6.4、XcodeGen 2.46.0、macOS 27。
- Bundle ID: `st.rio.facet` / `st.rio.facet.watchkitapp`。
- 外部ライブラリなし。SwiftUI、Contacts、Core Image（iPhoneのみ）、WatchConnectivity。

```sh
# 環境に合わせて変更。システムのxcode-selectは変更不要。
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test
xcodegen generate
open Facet.xcodeproj
```

XcodeでFacet schemeを選び、iPhone Simulatorを指定して実行します。実機は両ターゲットに自分のSigning Teamを指定してください。チームIDや証明書はプロジェクトに固定していません。

```sh
xcodebuild -project Facet.xcodeproj -scheme Facet \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath work/DerivedData CODE_SIGNING_ALLOWED=NO build
```

同梱WatchターゲットのSDKもXcodeが選択するため、全ターゲット共通の`-sdk iphonesimulator`を指定しないでください。Watch Simulatorで実行するにはwatchOSランタイムの追加が必要です。

### Contactsの結合テスト

```sh
scripts/test-contacts.sh com.apple.CoreSimulator.SimRuntime.iOS-26-3
```

使い捨てSimulatorで架空の連絡先を作り、システムの1件選択、共有項目の保持、編集後の手動更新、リセット後の再選択、アクセス権なしの選択を検証します。終了時にそのSimulatorだけを削除します。ログは`work/contacts-日時/`に残ります。

`FacetContactsTests` schemeはこの手順用です。テスト用連絡先の作成・編集にはSimulatorのアクセス権を使用しますが、製品の選択操作はアクセス権を要求しません。`--contacts-fixture`、`--fixture-import`、`--fixture-update`、`--reset-fixture-settings`などのデータ操作はDebug Simulator限定です。

Debug限定の起動引数`--demo`で架空の連絡先によるUI検証ができます。このモードはContactsにアクセスせず、設定を保存せず、WatchへQRを送信しません。Releaseには含まれません。

## 設計・公開準備

- [実装プラン](docs/implementation-plan.md) / [プランレビュー](docs/plan-review.md)
- [App Store準備](docs/app-store.md) / [テスト状況](docs/test-status.md)
- [Privacy Policy](PRIVACY_POLICY.md) / [Support](SUPPORT.md) / [MIT License](LICENSE)

ソースコード: https://github.com/rioriost/facet 。GitHubでソース・プライバシーポリシー・サポート文書を公開しています。

[アイコン原稿・再生成方法](Assets/README.md)もリポジトリに含めています。

**オフラインのWatchには旧QRが残ります。** iPhone側の変更は次回同期時に反映されます。即時消去が必要な場合はWatch上で消去してください。
