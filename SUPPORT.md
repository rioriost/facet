# Facet Support

Facet – Contact QR is a free iPhone app with an Apple Watch companion.

## Contact

Use [GitHub Issues](https://github.com/rioriost/facet/issues) for bug reports and support. Maintainer: [Ryo Fujita / rioriost](https://github.com/rioriost). Please keep public support requests free of personal information.

Include your iPhone/Watch model, OS version, Facet version, and steps to reproduce. **Do not post contact details, generated QR codes, address-book exports, or screenshots containing personal information.**

## Getting started

1. Open Facet and choose your own single contact using the system picker. If it is missing, create it in Apple's Contacts app first. Facet saves the supported fields on your iPhone; it does not request ongoing Contacts access.
2. Select Work / Personal / Combined and enable only fields you want to share. The name field is required to produce a valid contact QR.
3. Tap Done. Swipe between the three QR profiles. The other person uses their standard Camera app.
4. Install the companion app from the Watch app on iPhone, open Facet on Watch, and wait for synchronization. After sync, Watch can show QR codes offline.

## Troubleshooting

- **No QR:** select a contact and enable its name separately for each profile.
- **QR too dense:** disable long addresses, organization names, or extra URLs. Facet never silently truncates selected fields.
- **Watch shows an old QR:** open both apps and use “Watchに再同期” on iPhone. “Watchへの送信待ち” is not delivery confirmation.
- **Need to erase immediately:** on Watch, swipe to the information page and use “保存したQRを消去”. Offline Watch changes cannot arrive immediately. After local erasure, ordinary updates and iPhone app restarts keep the QR hidden; use “Watchに再同期” to restore it explicitly.
- **Contact edited:** select the same contact again in Facet to update its saved information. Your field selections are retained for the same contact.
- **Contact deleted or permission changed:** the saved copy and QR codes remain until you reselect a contact or reset Facet. To erase the saved contact and QR codes, use “設定とQRをすべて消去”.
- **Scan does not work:** wake Watch fully, face the display toward the camera, avoid glare, and reduce fields.

Minimum deployment targets: iOS 18 / watchOS 11. See [test status](docs/test-status.md) for OS/device versions actually verified.
