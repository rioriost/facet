# Facet 1.2.0 (6): iPhone Duo対応と審査記録

## 対象と設計

- 既存アプリの更新。App Store ID `6812192295`、Bundle ID `st.rio.facet`。
- iOS 18 / watchOS 11の最小対応、SwiftUI構成、3プロファイルの独立した許可リスト、端末内保存、WatchへのQRパターンのみの同期を維持。
- Duoの閉じた画面、開いた画面、半開き、回転でQR全体を読めることが今回の要件。大きな文字では案内文にスクロールで到達でき、ページ表示と重ならないことを確認する。
- `AdaptiveQRPage`は利用可能な領域に正方形のQRを収める。iOS 27.1以降ではSwiftUIの公開API `reservedRegions(kind: .division, layoutDirectionBehavior: .fixed)`で有効な折り目とその余白を避ける。古いOSでは通常の表示領域を使う。
- ページ表示のための下部余白を確保し、縦スクロールで大きな文字の案内文に到達できるよう変更。横向きにも対応。設定ボタンはシステムのオーバーフロー表示でも名称が伝わるLabelにした。
- 連絡先処理、QRの内容、通信、Watch画面は変更していない。

## Apple一次資料

2026-10-17に現行ページとSDKを確認。HIGは設計指針、SwiftUIはAPI契約、App Reviewとスクリーンショット仕様は提出要件として分けて判断した。

| 資料 | 今回の適用範囲 |
|---|---|
| [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) | 開閉、連続性、折り目、標準バーと可変領域。2026-09-09更新 |
| [Layout](https://developer.apple.com/design/human-interface-guidelines/layout) / [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) | 固定画面サイズを前提にせず、大きな文字と利用可能な領域に対応 |
| [Prepare for iPhone Duo](https://developer.apple.com/iphone-duo/prepare/) | Xcode 27.1 SDKによる対応とシミュレータ検証 |
| [SwiftUI GeometryProxy](https://developer.apple.com/documentation/swiftui/geometryproxy) | reservedRegions、isActive、view-local座標、margins、fixed layout directionをSDK宣言とDocCで照合 |
| [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) | Duoの1398×2034、2853×2007などの登録サイズ |
| [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) | 全5分野をルーティング。特に2.1、2.3、2.4、2.5、4.2、5.1 |
| [Apple releases](https://developer.apple.com/news/releases/) | Xcode 27.1 (27A9275)の公開を確認 |

## 検証

使用環境: Xcode 27.1 (27A9275)、iPhone Duo / iOS 27.1 (24A94232)、iPhone 17 Pro / iOS 27.0。専用の検証用シミュレータを作成し、他プロジェクトのシミュレータや実機データには触れていない。

- コアテスト25件成功。vCard、QR、共有設定などの既存ロジックを確認。
- Duoの修正前ベースライン4件成功。全12言語の基本画面、初回設定、共有同意と4ページ遷移を含む。
- Duoの新規レイアウトテスト2件成功。縦横回転、各QRの画像からの復号、設定を閉じた後のページ保持、大きな文字での案内文への到達を確認。
- 通常iPhoneの既存UIテスト3件成功。新規レイアウトテスト2件も最終実行で成功。
- 12ローカライズ、76 UI文字列、書式指定とソース参照の整合確認に成功。
- 実際の画像で、外側・内側・半開き、大きな文字と通常iPhoneの横向き・ダークモードを確認。半開きではQRが折り目から離れた領域に表示される。

### テスト設備側の問題と修正

iOS 27.0の横向きでは`app.screenshot()`が回転前の領域で画像を切り出す現象を確認した。Device Hubとsimctlの画面は正常で、テストを`XCUIScreen.main.screenshot()`に変更した後に復号検査が成功した。大きな文字のテストは開始時に縦向きを明示し、前のテストや手動回転に依存しないようにした。

Duo内側の初回撮影ではアプリ全体を対象にしたスワイプがページを切り替えなかった。ページのCollectionViewを対象にしたスワイプへ変更した。失敗時の記録も保存し、成功した操作検証の後、ストア用画像はネイティブ解像度で撮影する。

Duoは2つの画面を持ち、XCTestのmain画面は閉じた側を指す。内側はXCUIScreen.screensで選べるが、Xcodeの画像出力は2006×2852に丸められた。この画像はテスト証拠としてだけ残し、ストア用は`capture-duo-store.py`でテストと同期してsimctlのdisplay 3から2853×2007の原寸を取得する。画像の拡大・補間は行わない。

Device Hubが一時的に空の画面になった際は、専用Duoシミュレータの再起動で復旧した。Xcodeはランタイムのビルド番号に関する診断を出すが、ビルド・テストの最終結果とは区別した。

## App Store Review Preflight

- App/platform: Facet / iOS + bundled watchOS companion
- Version/build: 1.2.0 / 6
- Submission type: update
- Guidelines checked: retrieved 2026-10-17
- Readiness: READY FOR SUBMISSION within the stated simulator validation scope
- Findings: BLOCKER 0 / WARNING 2 / MANUAL 0 / PASS 5 family summaries / NOT APPLICABLE 8 feature groups

| 分野 | 判定と根拠 |
|---|---|
| 1 Safety | PASS。ネイティブな連絡先共有ユーティリティ。公開投稿、チャット、外部コンテンツ配信なし。選択項目だけをQR化し、サポート先と連絡先を登録済み |
| 2 Performance | PASS、下記の検証範囲に関するWARNING。バージョン、12言語の説明、実画面、レビュー手順を照合。Releaseからデモ用引数と架空氏名が除外されていることを確認。公開SwiftUI APIを使用 |
| 3 Business | PASS。無料、広告・アカウント・課金・外部購入なし。App Store Connectの現行価格0.00、175地域で利用可能という表示を確認 |
| 4 Design | PASS。3つの共有プロファイル、ローカルQR生成、Watchでの表示というネイティブ機能。既存のブランド・アイコン・同梱構成を維持。新たな第三者コンテンツなし |
| 5 Legal | PASS。App Privacyはデータ収集なし、公開済みポリシーあり。ソースのPrivacy Manifestも収集・追跡なし。1件選択のシステムContacts pickerを使用。既存の権利申告・標準EULA・年齢区分4+・trader申告を確認。法的権利の独立した保証を意味しない |

NOT APPLICABLEの8グループ: UGC/公開メッセージ、Kids/医療・危険操作、IAP/サブスクリプション/外部購入、広告/金融/暗号資産、ダウンロードコード/ミニアプリ、Game Center/Apple Pay等の未使用サービス、賭博/懸賞、VPN/MDM。アプリ構成とソースに該当機能がないため。

### WARNINGと確認範囲

1. **2.1 / 2.4: 実機と最小OSの実行検証は未実施。** Duoはシミュレータ上で検証。今回、実機のカメラによる読み取り、iOS 18 / watchOS 11上の実行、物理Watchとの新規同期は行っていない。SDKの最小対応設定、画像からのQR復号、既存のコアテストと同梱Watchの署名確認は実施。根拠: [App Review Guidelines — Performance](https://developer.apple.com/app-store/review/guidelines/#performance)。
2. **2.4 / 4: アクセシビリティの網羅検査ではない。** 大きな文字、可視表示、要素ラベルと操作到達性を検証したが、実際のVoiceOver読み上げ、Switch Control、外部キーボードの全操作は未検証。アクセシビリティツリー確認をVoiceOver使用実績とは扱わない。根拠: [App Review Guidelines — Design](https://developer.apple.com/app-store/review/guidelines/#design)、[HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)。

### 提出物の同一性

- Archive: `work/duo-20261017/Facet-1.2.0-6.xcarchive`
- 配布IPA: `work/duo-20261017/Facet-1.2.0-6.ipa`
- IPA SHA-256: `5aa17b3bbe6c97f00e4f27bcf79898b74f98d72655c1048c46d6d2a2c41e8b54`
- iPhone/Watchとも1.2.0 (6)。iPhoneのSDK27.1、最小iOS18、Watch最小11。
- Archiveと配布用再署名後のbundleを別々に検査。配布版はApple Distribution署名、`get-task-allow=false`、deep/strict署名検証成功。暗号化申告は既存の非対象設定。
- 2026-10-17 17:17 JSTにアップロード成功。Connect上で処理完了したビルド6を1.2.0に選択。ビルドID `6e225225-ae98-45ae-ab73-6f971b00deb7`。
- 既存の通常iPhoneとWatchの画像、公開地域、無料価格、審査後の自動リリース、評価維持を継承。
- 全12言語の更新説明を保存後に再取得して照合。レビュー用メモにはDuo対応、連絡先選択、Watchの初期同期とオフライン時の旧QRの注意を記載。

ローカル検証記録は`work/duo-20261017/`に保存。`core-tests.log`、`adaptive.xcresult`、`regression-final.xcresult`、`store-outer.xcresult`、`preflight-distribution.json`、`upload.log`を参照。失敗した初回実行の証拠も残している。

## スクリーンショット

- 12言語 × 7枚 = 84枚。各言語に外側の設定・仕事用・プライベート用・双方・アプリ紹介の5枚と、内側の仕事用・アプリ紹介の2枚。
- 外側1398×2034、内側2853×2007、RGB PNG。全画像の寸法と透過なしを検査。
- 全84枚を一覧画像で目視確認し、日本語の内側画面、大きな文字、半開き、通常iPhone横向き・ダークモードは個別画像でも確認。
- Apple Visionで連絡先QR48枚、App Store URLのQR24枚の内容を検査。設定12枚にはQRがないことを確認。架空のAlex Morganの連絡先のみ使用。
- 原寸撮影のUIテスト成功: `work/duo-20261017/native-inner/capture.xcresult`。画面遷移と取得完了を同期する`capture-duo-store.py`を追加。
- 最終画像: `work/duo-20261017/store/screenshots/<locale>/`。検査結果: `screenshot-qr-verification.txt`、`outer-sheet-*.jpg`、`inner-sheet-*.jpg`。

## 審査提出結果

- **2026-10-17 17:42 JST: 1.2.0 (6)を審査へ提出し、審査待ちを確認。** 承認・公開完了ではない。
- 提出ID: `d755ee35-475c-40b6-8cfb-9bf9c1cc4dc4`
- [App Store Connectの提出記録](https://appstoreconnect.apple.com/apps/6812192295/distribution/reviewsubmissions/details/d755ee35-475c-40b6-8cfb-9bf9c1cc4dc4)
- 12言語すべてでDuo画像7枚が保存されていることをリロード後に確認。既存の通常iPhone・Watch画像も継承。
- 審査後は既存設定どおり自動リリース。段階的リリースは使用せず、既存評価を維持。
- 受付画面: `work/duo-20261017/asc-review-submitted.png`、画面テキスト: `asc-review-submitted.txt`。
- ユーザーからUIテスト、修正、画像追加、バージョンアップ、審査申請まで明示的に依頼されているため、その範囲で実施。新たな契約・権利許諾・課金条件の変更は行っていない。
