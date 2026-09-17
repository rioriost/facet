// Usage: swift scripts/generate-app-share-qr.swift <App Store URL>
// Outputs the static QR modules for AppShare.swift (no Core Image on watchOS).
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

let filter = CIFilter.qrCodeGenerator()
filter.message = Data(CommandLine.arguments[1].utf8)
filter.correctionLevel = "M"
let image = filter.outputImage!
let bounds = image.extent.insetBy(dx: 1, dy: 1)
let width = Int(bounds.width)
var pixels = [UInt8](repeating: 255, count: width * width)
CIContext(options: [.useSoftwareRenderer: true]).render(
    image, toBitmap: &pixels, rowBytes: width, bounds: bounds,
    format: .L8, colorSpace: CGColorSpaceCreateDeviceGray())
for y in 0..<width {
    print(pixels[(y * width)..<((y + 1) * width)].map { $0 < 128 ? "1" : "0" }.joined())
}
