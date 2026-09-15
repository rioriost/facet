import Foundation
import Vision
let root = URL(fileURLWithPath: CommandLine.arguments[1])
let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)!.allObjects.compactMap { $0 as? URL }.filter {
    ($0.path.contains("/screenshots/") && $0.pathExtension == "png") || ($0.path.contains("/watch-screenshots/") && $0.pathExtension == "jpg")
}
var qrCount = 0, setupCount = 0
for file in files {
    let request = VNDetectBarcodesRequest()
    request.symbologies = [.qr]
    try VNImageRequestHandler(url: file).perform([request])
    let results = request.results ?? []
    if file.lastPathComponent.contains("settings") {
        precondition(results.isEmpty, "Unexpected QR on initial settings: \(file.path)")
        setupCount += 1
        continue
    }
    guard let text = results.first?.payloadStringValue, results.count == 1 else { fatalError("Unreadable QR: \(file.path)") }
    precondition(text.contains("VERSION:3.0") && text.contains("FN:Alex Morgan"), file.path)
    let personal = file.lastPathComponent.contains("personal")
    let work = file.lastPathComponent.contains("work")
    precondition(text.contains("alex@example.com") == !personal, file.path)
    precondition(text.contains("+1 202-555-0142") == !work, file.path)
    qrCount += 1
}
print("Verified \(qrCount) QR screenshots and \(setupCount) initial settings screenshots")
