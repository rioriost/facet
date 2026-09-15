# 検証状況

検証日: 2026-09-15。Simulator・署名・実機動作・光学読取を別々に記録する。

## 確認済み

| 項目 | 結果・範囲 |
|---|---|
| 共通ロジック | `swift test`: 11 tests、0 failures |
| 公開境界 | 選択外電話の排除、初期全OFF、元連絡先変更でリセット、双方の独立設定、削除済み/新規フィールドの非公開 |
| vCard | 氏名の明示許可、CRLF/構文注入対策、日本語UTF-8の75オクテット折返し、600 bytes超の拒否 |
| Simulator画面のQR | SEの実際の描画スクリーンショットをApple Visionで読取成功。仕事用メールを含み、私用電話を含まないことを確認。画面の目視確認も実施 |
| QR往復 | 実際のCore Image生成モジュールから画像を作り、Apple Visionで読取。Apple Contactsで日本語氏名・メール・構造化住所を復元 |
| 同期形式 | 空スナップショット、バージョン/サイズ/モジュール/重複プロフィールの検証 |
| Simulatorビルド | iOS 18 / watchOS 11 deployment targetでiOS/watchOS SDK 27ビルド成功。iPhoneにWatch appを同梱 |
| iPhone SE 3 Simulator | iOS 26.3.1、UIテスト2件成功。初回設定、QR横スワイプ、設定から氏名OFF→仕事用QR非表示 |
| iPhone 16 Pro Simulator | iOS 26.3.1、同じUIテスト2件成功 |
| Release実機向けビルド | 署名付きiPhone+Watchビルド成功。codesignのdeep/strict検証成功。両アプリのBundle IDと最低OSを確認、WatchのContacts権限文言なし |
| Debug実機向けビルド | 署名付きiPhone+Watchビルド成功。Apple Development証明書を使用、チームIDはローカルのビルド引数のみ |
| Privacy manifest | iPhone appと同梱Watch appの双方に配置されることを確認 |

## 実機の到達状況

| 対象 | 環境・結果 |
|---|---|
| iPhone SE (3rd gen) | iOS 27.0 (24A435)、paired/available。インストールは `device still locked` (10003 / not unlocked recently 1016)で停止 |
| iPhone 16 Pro | iOS 27.0 (24A435)、paired/available。Developer Disk Imageのmountが端末ロック (10003)で停止 |
| Apple Watch Series 10 | ペアリングと機種Watch7,9を確認。詳細取得時はdisconnectedでOSバージョン取得不可。実機起動/同期は未検証 |

端末のロック解除を依頼済み。ロック解除後にインストール・起動・光学読取・同期検証を実施する。ペアリング済みという表示だけでは接続成功としない。

## 未完了のリリースゲート

- 実機3台での起動・UI操作、SE/16 Pro相互およびWatchからの標準カメラ読取。
- 全許可・限定許可・拒否・権限取消、実際のContacts編集/削除/同じ連絡先再選択。
- Watchの受信確認、再起動オフライン表示、通信断での変更/削除、再接続、Watch切替、ローカル消去。
- watchOS Simulatorランタイムが未導入。watchOS Simulator上の実行は未検証（コンパイルのみ）。
- iOS 18 / watchOS 11の最低OSでの実行。現存SimulatorはiOS 26.3/27.0で最低OSテストを代替しない。
- VoiceOver、最大Dynamic Type、Always On実機、QRサイズ上限の実測調整。
- 最終App Icon asset catalog、英語を含むUIローカライズ、App Store用画面撮影。
- GitHub作成・push、公開URLの到達性、連絡先確定、配布Archive/Validate、TestFlight、審査提出。

## 検証中に修正した問題

- CIQRCodeGeneratorは1モジュールの余白を含むため、出力からその余白を外して保存し、共通ビューで4モジュールの余白を追加。実際のQR decodeテストで確認。
- 元の連絡先が取得できない場合でも、読み込み済みの連絡先一覧を保持し、別の連絡先を選択できるよう修正。
- 小画面のUIテストはToggleラベル中央でなくスイッチ本体を操作するよう修正。公開解除→QR消去を確認。

## 再実行

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
swift test
xcodegen generate
xcodebuild -project Facet.xcodeproj -scheme Facet \
  -destination 'platform=iOS Simulator,name=Facet iPhone SE 3' \
  -derivedDataPath work/DerivedData CODE_SIGNING_ALLOWED=NO test
```

UIテストの初回設定ケースは、アプリをまだ設定していないテスト用Simulatorを前提とする。デモケースは架空の連絡先のみ使用し、永続化・Watch送信を行わない。

ログとxcresultはローカルの`work/`（Git対象外）に保存。代表例: `core-tests.log`、`ui-tests-se-retest.log`、`Simulator-SE-retest.xcresult`、`Simulator-Pro.xcresult`、`release-build-final.log`、`device-build.log`、`install-se.log`、`install-pro.log`。ログは公開前に内容を見直す。
