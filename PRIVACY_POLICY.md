# Facet – Contact QR Privacy Policy

Last updated: September 17, 2026. Developer: Ryo Fujita.

## What Facet does

Facet creates QR codes from contact fields you explicitly select on your iPhone. Apple Contacts remains the source of your contact information. Facet does not edit your address book. The app is free, with no advertisements, in-app purchases, accounts, analytics SDKs, or developer-operated servers.

## Access and processing

You choose your own single contact using the iOS contact picker. Facet receives only that selected contact, without requesting ongoing access to your address book. It saves a local copy of the supported fields on your iPhone. After editing the contact in Contacts, select the same contact again in Facet to update it. Contact edits, deletion in Contacts, or changes to Contacts permissions do not automatically change this saved copy. Processing occurs on your device. For each of the Work, Personal, and Combined profiles, you choose individual fields to disclose. Combined is a separate selection, not an automatic union. All fields are initially off. Photos, notes, and birthdays are not included.

The developer does not receive or collect your contact information, generated QR codes, usage history, or device identifiers through the app. Facet does not include a QR scanner or request camera access.

## Apple Watch

The iPhone sends only QR patterns generated from your selected fields, profile identifiers, a snapshot identifier, an explicit-restore identifier, and its creation time to your paired Apple Watch using Apple's WatchConnectivity service. The Watch app does not access Contacts. QR patterns contain readable contact information; they are not anonymized or encrypted vCards.

The Watch stores the latest QR patterns locally for offline display. If you reselect a contact in Facet, change the fields you share, or reset Facet on iPhone, the Watch receives the resulting QR update when synchronization becomes possible. **An offline Watch can continue showing an older QR until it reconnects or you erase its saved QR codes on the Watch.** Facet does not monitor changes in Contacts.

## Local storage and deletion

The iPhone stores one selected contact’s identifier and supported fields (name, company, department, job title, phone numbers, email addresses, postal addresses, and URLs), including fields you have not enabled in a QR, plus your profile settings. It does not store the rest of your address book. Only explicitly enabled fields enter a QR or are sent to Watch. The Watch stores the latest permitted QR patterns. These files use the operating system's app sandbox and file protection and are excluded from device backup by Facet.

To remove the saved contact copy, all selections, and iPhone QR codes, use Settings → “設定とQRをすべて消去” on iPhone. On Watch, swipe past the three QR pages and choose “保存したQRを消去”. Watch erasure removes QR patterns and retains only an empty snapshot, synchronization identifiers, and timestamps. Ordinary synchronization and an iPhone app restart do not undo that local erasure. To restore QR display afterward, use “Watchに再同期” on iPhone. Uninstalling the iPhone app does not guarantee deletion of a separately installed, offline Watch app's data; remove or clear the Watch app too.

Changing Contacts access in iOS Settings does not erase a contact already shared through the picker; use Facet’s reset to erase its saved copy. When upgrading from version 1.0.0 build 1, Facet may read the previously selected contact once using already granted access to migrate your existing settings. It does not request additional access. If migration is unavailable, choose your contact again. There is no developer-held contact database from which to request deletion.

## Sharing and external links

The Share Facet screen shows a fixed public link to Facet on the App Store. This QR code contains no contact fields or personal identifiers and requires no developer server or Watch synchronization. When someone scans the code and opens the link, Apple handles access to the App Store under its own privacy policy.

Anyone who can see and scan a QR code can obtain and retain its included fields. Review your choices before showing a QR. Facet cannot revoke information another person has already scanned or saved.

Opening the optional GitHub privacy/support links connects your browser to GitHub, whose own privacy policy applies. If you choose to post an issue, that information is handled by GitHub and may be public. Do not include contact information or QR codes in public issues. Apple may separately process platform diagnostics under your Apple settings and its own policies.

## Contact and changes

Support and privacy questions: [Facet support](https://github.com/rioriost/facet/blob/main/SUPPORT.md). Material changes will be reflected in this document with an updated date.

---

## 日本語要約

Facetでは自分の連絡先1件を選択します。その連絡先の対応項目をiPhone内に保存し、共有を許可した項目のQRのみをApple Watchへ同期します。連絡先を編集した後は、Facetで同じ連絡先を選び直して更新してください。連絡先アプリでの編集・削除やアクセス権の変更は、保存済みの情報に自動反映されません。開発者による連絡先の収集、広告、解析、課金はありません。仕事用・私用・双方の項目はそれぞれ明示的に選択します。

Watchはオフライン表示のためQRを保存します。iPhone側で削除しても通信できるまでは旧QRが残るため、必要に応じてWatch上で消去してください。読み取った相手が保存した情報は取り消せません。保存した連絡先と設定はFacetのリセットで、WatchのQRはWatch上の消去で削除できます。お問い合わせの公開Issueには個人情報やQRを添付しないでください。
