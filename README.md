# Facet – Contact QR

**相手に見せる、自分の一面。**

Apple Contactsを正本に、自分の連絡先を仕事用・プライベート用・双方の3つのQRで共有するiPhoneアプリとApple Watch companionです。無料・MIT・広告なし・アプリ内課金なし。

## 開発状況

初期実装。Contactsの公開設定、vCard 3.0/UTF-8生成、QR表示、WatchConnectivityによる同期、Watchのオフライン表示を実装しています。ストア公開済み製品ではありません。検証結果と未完了項目は[テスト状況](docs/test-status.md)を参照してください。

## 特徴

- 初回起動と設定アイコンから元の連絡先・公開項目を設定。
- 電話・メール・住所・URLの個々の値をプロファイル別に選択。初期値は非公開。
- 「双方」も独立した許可リスト。写真・メモ・誕生日は含めません。
- iPhoneとWatchで横スワイプ切替。WatchはContactsにアクセスしません。
- QR読取はiOS標準カメラへ任せます。サーバー・アカウント不要。
- 日本語・英語・簡体字・繁体字・韓国語・フランス語・ドイツ語・スペイン語2地域・ポルトガル語2地域・イタリア語の12ローカライズ。[言語対応](docs/localization.md)を参照。

## 開発環境

- 最小対応: iOS 18.0 / watchOS 11.0。
- 実測環境: Xcode 27 beta (27A5228h)、Swift 6.4、XcodeGen 2.46.0、macOS 27。
- Bundle ID: `st.rio.facet` / `st.rio.facet.watchkitapp`。
- 外部ライブラリなし。SwiftUI、Contacts、Core Image（iPhoneのみ）、WatchConnectivity。

```sh
# 環境に合わせて変更。システムのxcode-selectは変更不要。
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
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

使い捨てSimulatorを作成し、OSのContacts権限を許可→取消して、個別メールの選択、QRへの非公開値混入防止、設定の再起動保持、Contactsの編集・追加・削除、権限取消後の非表示を検証します。終了時にそのSimulatorだけを削除します。ログと結果は`work/contacts-日時/`に残ります。ランタイムIDは導入済みのiOSランタイムに合わせて変更してください。

`FacetContactsTests` schemeはこの手順用です。3ケースは権限状態と連絡先の存在状態が異なるため、一括実行せずスクリプトを使います。`--contacts-fixture`と`--reset-fixture-settings`はDebug Simulator限定のテスト引数で、前者は架空の連絡先を作成し、後者はFacetの設定だけを初期化します。実機・Releaseには含まれません。

Debug限定の起動引数`--demo`で架空の連絡先によるUI検証ができます。このモードはContactsにアクセスせず、設定を保存せず、WatchへQRを送信しません。Releaseには含まれません。

## 設計・公開準備

- [実装プラン](docs/implementation-plan.md) / [プランレビュー](docs/plan-review.md)
- [App Store準備](docs/app-store.md) / [テスト状況](docs/test-status.md)
- [Privacy Policy](PRIVACY_POLICY.md) / [Support](SUPPORT.md) / [MIT License](LICENSE)

ソースコード: https://github.com/rioriost/facet 。GitHubでソース・プライバシーポリシー・サポート文書を公開しています。

[アイコン原稿・再生成方法](Assets/README.md)もリポジトリに含めています。

**オフラインのWatchには旧QRが残ります。** iPhone側の変更は次回同期時に反映されます。即時消去が必要な場合はWatch上で消去してください。
