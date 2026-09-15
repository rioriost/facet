# 検証状況

検証日: 2026-09-15。Simulator・署名・実機動作・光学読取を別々に記録する。

## 確認済み

| 項目 | 結果・範囲 |
|---|---|
| 共通ロジック | `swift test`: 18 tests、0 failures（Watchの消去・再起動・手動復元・受信日時・旧設定互換の7件を追加） |
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

## 継続作業で確認済み

| 項目 | 結果・範囲 |
|---|---|
| 通常UI再検証 | iPhone 16 Pro Simulatorで通常2ケース成功。初回設定テストはテスト用引数で設定を初期化し、実Contactsケースは専用クラス/スキームへ分離 |
| 実Contacts結合テスト | iOS 26.3.1の使い捨てSimulatorに架空の連絡先を作成。氏名と仕事用メールだけを選択し、実際の画面QRをCore Imageでdecode。私用メール・電話の不在を確認。アプリ再起動後も同じQRで設定保持を確認 |
| Contacts権限取消 | 上記と同じ保存済み設定で、OS側からContacts権限をrevoke。QR非表示と設定画面のアクセス拒否案内を確認 |
| 再実行用スクリプト | `scripts/test-contacts.sh`を新規Simulatorで実行し2件成功。終了時に作成したSimulatorを削除 |
| Watch消去維持 | iPhone再起動や通常の更新では非表示を維持。手動再同期の復元トークン変更でのみ復元。Watchから消去状態を返しiPhoneにも表示。共通状態遷移テスト済み、Watchの実通信は未検証 |
| 受信日時 | Watchの「最終同期」は実際の受信日時。キャッシュ再読込では日時を更新しない |
| アイコン | iPhone/WatchのAppIcon catalogを作成。SVGを目視確認、1024px・sRGB・alphaなしを検証。ReleaseのCFBundleIcons/Assets.carとWatch用アイコンrenditionを確認 |
| Release再検証 | 両ターゲットの署名付きReleaseビルドとcodesign deep/strict成功。実機/Release用バイナリにテスト用の連絡先作成識別子が存在しないことを確認 |

結合テストはOSの権限をテスト用ツールでgrant/revokeしている。初回のシステム許可ダイアログや限定アクセスの操作が合格したという意味ではない。

## 実機の到達状況

| 対象 | 環境・結果 |
|---|---|
| iPhone SE (3rd gen) | iOS 27.0 (24A435)、paired/available。インストールは `device still locked` (10003 / not unlocked recently 1016)で停止 |
| iPhone 16 Pro | iOS 27.0 (24A435)、paired/available。Developer Disk Imageのmountが端末ロック (10003)で停止 |
| Apple Watch Series 10 | ペアリングと機種Watch7,9を確認。詳細取得時はdisconnectedでOSバージョン取得不可。実機起動/同期は未検証 |

継続時にも再試行したが、iPhone SE / 16 Proは接続確立失敗 (CoreDevice 4000 / transport disconnected)、Watchはdisconnected。インストール・起動成功はまだ確認できていない。

端末の接続・ロック解除を依頼済み。ロック解除後にインストール・起動・光学読取・同期検証を実施する。ペアリング済みという表示だけでは接続成功としない。

## 未完了のリリースゲート

- 実機3台での起動・UI操作、SE/16 Pro相互およびWatchからの標準カメラ読取。
- 初回のシステム許可ダイアログ、限定許可、実機での権限取消・Contacts編集/削除、同じ連絡先の再選択。Simulatorの全許可・保存・変更・追加・削除・取消は結合テスト済み。
- Watchの受信確認、再起動オフライン表示、通信断での変更/削除、再接続、Watch切替、ローカル消去。
- watchOS Simulatorランタイムが未導入。watchOS Simulator上の実行は未検証（コンパイルのみ）。
- iOS 18 / watchOS 11の最低OSでの実行。現存SimulatorはiOS 26.3/27.0で最低OSテストを代替しない。
- VoiceOver、最大Dynamic Type、Always On実機、QRサイズ上限の実測調整。
- App Iconの実機上での見え方、英語を含むUIローカライズ、App Store用画面撮影。asset catalogの生成・ビルド検証は完了。
- 私的なサポート連絡先の確定、配布Archive/Validate、TestFlight、審査提出。GitHub作成・pushと公開URLの確認は完了。

## 検証中に修正した問題

- CIQRCodeGeneratorは1モジュールの余白を含むため、出力からその余白を外して保存し、共通ビューで4モジュールの余白を追加。実際のQR decodeテストで確認。
- 元の連絡先が取得できない場合でも、読み込み済みの連絡先一覧を保持し、別の連絡先を選択できるよう修正。
- 小画面のUIテストはToggleラベル中央でなくスイッチ本体を操作するよう修正。公開解除→QR消去を確認。Contactsテストでは下方の項目を画面内までスクロールしてから操作する。
- 実Contactsの変更通知をSwiftUIが背景スレッドで受ける警告が出たため、通知をメインキューへ配送するよう修正。再検証では警告なし。
- SimulatorのVisionバーコード検出が推論コンテキスト作成に失敗したため、UIテストの画面読取はCore ImageのCPU実装を使用。製品にスキャナー機能は追加していない。Mac上のVision往復テストは引き続き成功。

## 再実行

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
swift test
xcodegen generate
xcodebuild -project Facet.xcodeproj -scheme Facet \
  -destination 'platform=iOS Simulator,name=Facet iPhone SE 3' \
  -derivedDataPath work/DerivedData CODE_SIGNING_ALLOWED=NO test
```

UIテストの初回設定ケースはDebug Simulator限定の引数でFacet設定を初期化する。Contacts権限は未選択のテスト用Simulatorを前提とする。デモケースは架空の連絡先のみ使用し、永続化・Watch送信を行わない。

ログとxcresultはローカルの`work/`（Git対象外）に保存。代表例: `core-tests.log`、`ui-tests-se-retest.log`、`Simulator-SE-retest.xcresult`、`Simulator-Pro.xcresult`、`release-build-final.log`、`device-build.log`、`install-se.log`、`install-pro.log`。ログは公開前に内容を見直す。


継続作業の証跡: `work/core-tests-continue-final.log`、`work/contacts-20260915-125132/{granted.log,revoked.log,Granted.xcresult,Revoked.xcresult}`、`work/continue-release-final.log`、`work/watch-assets.json`。結合テストのために作成した使い捨てSimulatorは削除済み。

通常UI再検証の証跡: `work/Continue-UI-Pro-isolated.xcresult`、`work/continue-ui-pro-isolated.log`。18件の共通テスト、通常UI 2件、Contacts結合2件、署名付きReleaseビルドが継続作業の最終合格範囲。


## GitHub公開とContactsライフサイクル検証（2026-09-15）

- [rioriost/facet](https://github.com/rioriost/facet)をPublicで作成し、mainをpush。
- Repository / Privacy Policy / Support / Issuesは認証情報・CookieなしのHTTPリクエストで全て200。Policy/Supportのrawファイルはローカルとバイト単位で一致。
- アプリ内Privacy Policy/Supportリンクから「公開予定」を削除。公開Issue用のテンプレートを追加。
- Contacts結合3ケースが成功（通常の選択/再起動に変更・追加テストを組み込み、権限取消、削除を別ケースで検証）。公開済みメールの値変更はQRへ反映し、新規追加のメールは非公開を維持。元連絡先を削除するとQRが消え、再選択画面へ進める。
- 署名付きReleaseビルドとcodesign deep/strictが成功。Simulator専用の変更・削除処理がReleaseバイナリに含まれないことを検査。
- iPhone SE / 16 Proへの実機インストールは再試行したがCoreDevice 4000 / transport disconnectedで失敗。実機テストの合格を示すものではない。

証跡: `work/contacts-20260915-133312/{Granted,Revoked,Deleted}.xcresult`、同ディレクトリの3ログ、`work/publication-release.log`、`work/public-urls.json`。使い捨てSimulatorは削除済み。
