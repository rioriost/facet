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

## 実機で確認する項目

1. TestFlightからiPhoneへインストールし、Watchアプリもインストールする。
2. 初回設定で本人の連絡先と公開項目を選択し、仕事用・私用・双方を設定する。
3. 別端末の標準カメラで3つのQRを読み、公開した項目だけが含まれることを確認する。
4. Watchで横スワイプして3プロフィールを切り替え、同じ項目が読めることを確認する。
5. iPhoneで公開項目を変更し、Watchへの同期と再起動後の保持を確認する。
6. 同期後、iPhoneが接続されていない状態でWatchのQRを確認する。
7. iPhone SE (第3世代)、iPhone 16 Pro、Apple Watch Series 10で表示・読み取りを記録する。

## 配信記録

2026-09-15: アーカイブ作成前。アップロードとApple側の処理完了は未確認。
