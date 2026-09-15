# App Storeスクリーンショット

2026-09-15。実際のSimulator画面を撮影し、画像加工や生成画像は使用しない。

## 撮影内容

| 対象 | 設定 | 各言語の画像 |
|---|---|---|
| iPhone | iPhone 13 Pro Max / iOS 26.3.1 / 1284 × 2778 PNG（アルファなし） | 初期設定、仕事用、プライベート用、双方 |
| Watch | Series 10 46mm / watchOS 27.0 / 416 × 496 JPEG | 仕事用、プライベート用、双方 |

言語・地域: ja, en-US, zh-Hans, zh-Hant, ko, fr, de, es-ES, es-MX, pt-BR, pt-PT, it。
アプリ内の `en`, `es`, `es-419` は掲載時にそれぞれ en-US, es-ES, es-MX に対応する。
App Store Connectでは416 × 496の枠が「Series 11」と表示される。Series 10の同じ解像度も公式仕様で受け付ける。

連絡先は架空のAlex Morgan、alex@example.com、+1 202-555-0142。仕事用は名前とメール、私用は名前と電話、双方は3項目。撮影用データはReleaseの初回起動に出ない。

## 再撮影

既存の利用中Simulatorではなく、撮影専用Simulatorを作成する。

1. `FacetStoreScreenshots` schemeをiPhone 13 Pro Maxでテスト。`FacetStoreScreenshotTests` が12言語×4枚をxcresult添付へ保存する。通常のFacetテスト、Contactsテストからは除外する。
2. `xcresulttool export attachments` で取り出し、`<locale>/01-settings.png`、`02-work.png`、`03-personal.png`、`04-combined.png` に配置する。
3. `swift run --package-path tools/StoreFixture StoreFixture <absolute-watch-cache.json>` で架空のWatchキャッシュを生成する。FacetCoreのvCard生成・QR生成・WatchCacheを使用する。
4. `FacetWatch` のDebugビルドを、起動済みの撮影専用Watch Simulatorへインストールする。
5. `scripts/capture-watch-store.py --device <UUID> --fixture <cache.json> --output <watch-screenshots>` を実行する。キャッシュをアプリ専用領域に配置し、Simulator限定Debug引数で各プロファイルを選択して撮影する。JPEGはSimulatorから直接取得する。
6. `scripts/verify-store-screenshots.swift` をSwiftでビルドし、`screenshots/` と `watch-screenshots/` を含む親ディレクトリを指定する。Apple VisionでQRを読み、vCard 3.0・架空の名前・プロフィールごとのフィールドを確認する。

Watchのキャッシュ投入は表示検証用。実機のWatchConnectivity同期・権限取消・オフライン動作の検証とは区別する。

## App Store Connectへの登録

- 各言語のiPhone画像は「設定 → 仕事 → 私用 → 双方」、Watch画像は「仕事 → 私用 → 双方」。
- Watchの副言語は、既定では日本語画像を継承する。「編集」からその言語専用の画像に切り替える。
- ファイル選択直後の枚数だけでは完了としない。画像サムネイルが表示され、再読み込み後もAppleの画像配信URLから読み込まれることを確認する。
- 一括登録の順序は入力順と一致しないことがある。ドラッグで整え、移動を確定してから他の言語へ切り替える。

## 今回の検証

- iPhone 48枚、Watch 36枚、合計84枚。
- Apple Vision: QR画像72枚をすべて読み取り、初期設定12枚にはQRがないことを確認。
- FacetCore 20テスト成功。
- iPhone + 同梱WatchのReleaseビルド成功（署名なし）。両アプリの12言語・86 UI文字列・権限説明・書式指定子を検証。
- App Storeへの配布ビルドのアップロードおよび実機の通信テストは別途必要。

参考: [Appleのスクリーンショット仕様](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
