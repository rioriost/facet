# TestFlight 配信

## 初回ビルド

- バージョン: 1.0.0 (1)
- iPhone: `st.rio.facet`、iOS 18.0以上
- 同梱Watch: `st.rio.facet.watchkitapp`、watchOS 11.0以上
- 配布対象: まず所有者の内部テスト。App Store審査への提出は別操作。
- 署名チームはローカルのビルド引数で指定し、認証情報をリポジトリに保存しない。

## 暗号化の申告

両アプリのInfo.plistに`ITSAppUsesNonExemptEncryption = NO`を設定する。
現行ソースは独自暗号・暗号ライブラリ・外部通信SDKを実装せず、保存データの保護とWatchConnectivityはApple OSの機能だけを利用する。
この判定は現在の実装に対するもので、暗号機能や外部SDKを追加した際に見直す。

根拠: [Apple: Complying with Encryption Export Regulations](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations)。

## 実機で確認する項目

1. TestFlightからiPhoneへインストールし、Watchアプリもインストールする。
2. 初回設定で本人の連絡先と公開項目を選択し、仕事用・私用・双方を設定する。
3. 別端末の標準カメラで3つのQRを読み、公開した項目だけが含まれることを確認する。
4. Watchで横スワイプして3プロフィールを切り替え、同じ項目が読めることを確認する。
5. iPhoneで公開項目を変更し、Watchへの同期と再起動後の保持を確認する。
6. 同期後、iPhoneが接続されていない状態でWatchのQRを確認する。
7. iPhone SE (第3世代)、iPhone 16 Pro、Apple Watch Series 10で表示・読み取りを記録する。

## 配信記録

2026-09-15:

- ソースcommit: `c155e1e`。
- Xcode 27.0 (27A5228h)でRelease Archive成功。
- iPhoneとWatchの署名、1.0.0 (1)、最低OS、12言語、Privacy Manifest、撮影用データの除外を確認。
- 初回exportはApple標準openrsyncとHomebrew rsync 3.5.0の混在による`Copy failed`で停止。配布コマンドの`PATH=/usr/bin:/bin:/usr/sbin:/sbin`で解消し、アップロード処理へ進行。
- ベータ版による送信はApple側の`Unsupported SDK or Xcode version`で失敗。
- Mac App Storeから正式版Xcode 27.0 (27A266a)を追加。既存Xcode-beta.appとシステムのxcode-select設定は変更せず、`DEVELOPER_DIR`で正式版を指定。
- 正式版でRelease Archiveと共通テスト20件が成功。iPhone/WatchのBundle ID・1.0.0 (1)・最低OS・12言語・署名・撮影用データの除外を再確認。
- 15:23 JST: `Upload succeeded` / `EXPORT SUCCEEDED`を確認。
- Apple側の処理完了後、内部グループ`facet test`で1.0.0 (1)が「テスト中」、有効期限「期限切れまで90日」と表示されることを確認。
- グループは内部テスター1名（所有者）、ビルド1個。所有者は「招待済み」。既存のグループと招待を利用し、追加のテスターや外部公開リンクは作成していない。
- App Storeの公開審査には提出していない。実機へのTestFlightインストールとiPhone/Watchの動作確認は所有者が実施する。

App Store Connectのビルド: https://appstoreconnect.apple.com/teams/e392d05d-0ae2-4ed0-95bc-3229f9d1384e/apps/6812192295/testflight/ios/f2cfd632-b563-411a-80cc-bbd11df82ec3

正式版のローカル証跡: `work/Facet-1.0.0-1-27A266a.xcarchive`、`work/testflight-official-archive.log`、`work/testflight-official-upload.log`、`work/testflight-official-tests.log`、`work/testflight-official-preflight.json`。これらはGit管理対象外。
