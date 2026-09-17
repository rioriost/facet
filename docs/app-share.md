# App Storeへの共有QR

2026-09-17: iPhoneとApple Watchで、仕事用 → プライベート用 → 双方 → **Facet - Contact QRを共有** の順に横スワイプできる画面を追加。Watchの同期・消去画面はその次に配置する。タイトルは12言語・地域に対応。

QRの内容は `https://apps.apple.com/jp/app/facet-contact-qr/id6812192295` のみ。相手がカメラ等で読むとApp StoreのFacetページを開ける。QR表示自体には通信も連絡先の選択も不要。アプリのインストールには相手側の通信が必要。

## 実装

- `ProfileID` の3つの共有設定とWatchの同期形式は変更しない。アプリ紹介を連絡先プロファイルとして扱わない。
- `AppShare` に検証済みQRモジュールを同梱する。watchOSでCore Imageを使わず、初回同期前や連絡先消去後も表示できる。
- 共通の `AppShareView` と既存 `QRView` を使用し、4モジュールのquiet zoneと整数ピクセル描画を保つ。Watchはタイトルと白い余白を含めて画面に収まる最大の正方形で表示。非アクティブ時やWatchの低輝度時はQRを隠す。
- URLを変更する場合、`scripts/generate-app-share-qr.swift` で再生成し、定数と実際の読取結果が一致することを共通テストで確認する。

## 確認

- 共通テストで同梱QRをWatch相当のサイズに描画し、Visionで指定URLと一致することを確認。
- iPhone UIテストで、連絡先あり／未選択の両状態で4画面目への移動・タイトル・実画面からのQR読取・双方への戻りを確認。
- 実施結果は `docs/test-status.md` に記録する。

この変更のApp Storeへのアップロード・審査提出は別途実施する。現在提出済みの1.0.0 (4)は変更しない。
