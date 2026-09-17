# 言語対応

## 対応する12種類

| 言語・地域 | リソース識別子 |
|---|---|
| 日本語 | `ja` |
| 英語（米国英語を基本） | `en` |
| 中国語・簡体字 | `zh-Hans` |
| 中国語・繁体字（台湾向けの表現） | `zh-Hant` |
| 韓国語 | `ko` |
| フランス語（フランス） | `fr` |
| ドイツ語 | `de` |
| スペイン語（スペイン） | `es` |
| スペイン語（中南米） | `es-419` |
| ポルトガル語（ブラジル） | `pt-BR` |
| ポルトガル語（ポルトガル） | `pt-PT` |
| イタリア語 | `it` |

日本語を含む12ローカライズ。設定画面、プロフィール名、同期状態、エラー、確認画面、アプリ内プライバシー説明、リンク名、QRのVoiceOverラベルに共通86項目を用意し、iPhoneのContactsアクセス許可説明も12種類に翻訳した。ブランド名は `Facet – Contact QR` / `Facet` のまま。

## 動作とデータ

- iPhone / WatchはそれぞれのOSの優先言語に従う。iPhoneのアプリ別言語設定にも対応。アプリ独自の言語ピッカーは設けない。
- 開発言語・最終フォールバックは英語。言語変更後の再起動でモデル内の表示用文字列も更新される。
- Work / Personal / Bothの保存IDは従来の `work` / `personal` / `combined` を維持する。設定移行や公開項目の再選択は不要。
- Watchに送るのは従来のQRモジュールとプロフィールID。翻訳済みのタイトルは送らず、Watch自身で表示言語を解決する。
- 氏名・組織・住所・電話番号・メールなどの連絡先値、ユーザー定義ラベルは翻訳しない。標準のContactsラベルはAppleのローカライズAPIに任せる。vCard 3.0 / UTF-8のデータ形式・公開許可リストは変更しない。
- スペイン語の `Ajustes` / `Configuración`、ポルトガル語の `Endereço` / `Morada`、`salvar` / `guardar` などを地域別に調整した。
- 「双方」は各言語でも独立したプロファイルとして説明する。他の2つを自動統合する意味にはしない。

## ファイル構成

- `Sources/FacetCore/Resources/<言語>.lproj/Localizable.strings`: iPhone / Watch共有の翻訳正本。
- `Sources/FacetCore/L10n.swift`: Swift packageの`Bundle.module`を使った文字列解決。動的な状態・エラーも同じ経路を使う。
- `Apps/iOS/Resources/<言語>.lproj/InfoPlist.strings`: アプリ名とContactsアクセス許可説明。
- `Apps/Watch/Resources/<言語>.lproj/InfoPlist.strings`: Watchアプリ名。Contacts権限の文言は含まない。
- `Package.swift`: `defaultLocalization: "en"` とリソース処理を宣言。
- `project.yml`: 開発言語と既知の地域を宣言。アプリの言語対応は同梱される各`.lproj`から認識される。

文字列を追加するときは安定したキーを全12ファイルに追加し、`L10n.text`経由で使用する。連絡先値をローカライズキーとして渡さない。書式文字列の`%1$@`、`%2$@`は維持する。

## 検証

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
python3 scripts/check-localizations.py
swift test
xcodegen generate
# Contacts権限が未選択の専用Simulatorを指定する。
xcodebuild -project Facet.xcodeproj -scheme Facet \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_ID>' \
  -derivedDataPath work/LocalizationBuild CODE_SIGNING_ALLOWED=NO \
  -parallel-testing-enabled NO test
python3 scripts/check-localizations.py \
  --app work/LocalizationBuild/Build/Products/Debug-iphonesimulator/Facet.app
```

- 共通テストで全12言語のキー・値・書式・地域差・プライバシー説明内のボタン名を検証。
- UIテストで各言語を指定してデモ起動し、プロフィール名、設定タイトル、項目名、名前未選択エラーを検証。実際にQRを読み戻し、全言語でペイロードが一致することを検証。
- 設定画面のスクリーンショットをxcresultへ保存する。
- ビルド後のiPhoneアプリと同梱Watchアプリについても、全12言語のリソースとWatchのContacts権限不在を検証する。

Watchランタイムでの表示確認、最大Dynamic Type、母語話者レビューは別途必要。外部のGitHub文書本文やApp Store掲載文・スクリーンショットの全12言語化はこのアプリ内対応に含めていない。

参考: [Apple: Localizing package resources](https://developer.apple.com/documentation/xcode/localizing-package-resources)、[Apple: Information Property List Files](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html)。

## Build 2

連絡先の単一選択に合わせて権限関連の不要な文言を削除し、共有する連絡先・端末内保存・編集後の再選択を12言語で更新。現行カタログは74キー。キー集合、空文字、書式プレースホルダー、両アプリ内の収録を検証する。App Store Connectの12言語の概要にも手動更新を追記済み。

## アプリ紹介QR画面（2026-09-17）

`app.share` に「Facet - Contact QRを共有」と各言語の対応タイトルを追加。組織・部署の追加分も含めて76キー。App Store URLはすべての言語で同一とし、指定された日本向けURLをそのままQRに格納する。
