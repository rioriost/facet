# App Store公開準備

2026-09-15時点。実装準備資料であり、審査合格・提出完了を示すものではない。

## メタデータ

| 項目 | 内容 |
|---|---|
| アプリ名 | Facet – Contact QR |
| Bundle ID | st.rio.facet |
| Watch Bundle ID | st.rio.facet.watchkitapp |
| バージョン | App Store Connectとアプリを1.0.0 (1)に統一。配信状況はdocs/testflight.mdに記録 |
| 価格 | 無料、IAP・広告なし |
| プライバシーURL | https://github.com/rioriost/facet/blob/main/PRIVACY_POLICY.md |
| サポートURL | https://github.com/rioriost/facet/issues（アプリ内ではSUPPORT.mdも利用） |
| マーケティングURL | https://github.com/rioriost/facet |
| ライセンス | MIT（ソースコード）。配布アプリのEULAはApple標準を想定 |

## 公開前ゲート

- **完了（2026-09-15）:** GitHub Publicリポジトリを作成しmainをpush。Policy/Support/Issuesの認証なしHTTP 200とPolicy/Supportのローカル一致を確認。
- アプリ内にPolicy/Supportへの直接リンクを配置し、「公開予定」表記を削除済み。提出時にもリンク先の到達性を再確認する。
- 開発者の連絡先を確定する。Issuesは公開されるため、機密の問い合わせを受ける私的連絡先は別途本人から指定してもらう。
- 実装に合わせてApp Privacyを申告。現状は開発者による収集・追跡なし、Apple標準フレームワークのみ。Contactsアクセス自体と開発者による収集は区別する。
- PrivacyInfo.xcprivacyは両アプリに同梱。現在のソースにUserDefaultsやファイル時刻取得等のRequired Reason APIの直接使用はない。ArchiveのPrivacy Reportと実際のバイナリで再確認。
- App Iconは3面カードの1024px asset catalogを実装済み。実機上での表示確認、実機スクリーンショット、説明・年齢区分・カテゴリ・著作権・輸出申告を確定する。最終アイコンの見た目とwatchOSアセット要件を確認する。
- iOS 18 / watchOS 11での実行、指定実機での標準カメラ読取、日本語/長い項目/複数電話、Watch同期・通信断・権限取消・削除を完了する。
- 提出時に受け付けられるXcode版でRelease Archive、Validate、配布署名を確認する。現在のbeta SDKのビルド成功だけで提出可能としない。
- App Store Connectのレコード6812192295を確認。12言語のプロモーション用テキスト・概要・キーワード・サブタイトルを保存。価格は全175地域で0、IAP・サブスクリプションなし。Mac/Vision Proの互換配信は対象外としてオフ。ビルドのアップロード・TestFlight・審査送信は未実施。
- 年齢区分4+、ビジネス/ユーティリティ、Apple標準EULA、収集なしの公開済みApp Privacy、12言語のPolicy URLをレビュー。無料・有料アプリ契約は有効。
- App Reviewのサインイン不要と英語の審査手順を保存。連絡先の電話番号・メールは本人からの指定待ち。EUのDSA事業者区分も本人の判断・申告が必要。
- アクセシビリティはiPhone/Watchともサポートを宣言しない既存下書き。対応表示を増やす前に各機能を実機で検証する。
- [スクリーンショット撮影と検証](store-screenshots.md): iPhone48枚、Watch36枚。

## 審査メモ案

Facet is a free contact-sharing app. It does not scan QR codes, use accounts, show ads, or offer in-app purchases. Create a sample contact in Apple Contacts, open Facet, allow access to that contact, select it, and enable the name and desired fields separately for each of the three profiles. The recipient uses the standard Camera app. The Watch companion needs initial configuration and synchronization from its paired iPhone, then displays QR codes offline. No contact information is sent to a developer server.

## 一次資料

- [App Review Guidelines 1.5 / 5.1.1](https://developer.apple.com/app-store/review/guidelines/): サポート連絡先、アプリ内とメタデータのプライバシーリンク。
- [App Review: Broken links / Placeholder content](https://developer.apple.com/app-store/review/): 公開予定のままでは提出しない。
- [App Privacy](https://developer.apple.com/help/app-store-connect/reference/app-privacy/): Privacy Policy URLは必須。
- [Privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files): 使用API/収集実態に即して申告。
