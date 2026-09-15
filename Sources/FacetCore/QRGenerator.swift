#if canImport(CoreImage) && !os(watchOS)
import CoreImage
import CoreImage.CIFilterBuiltins

// Core Image is intentionally confined to the iPhone target.
public enum QRGenerator {
    public static func make(_ data: Data) throws -> QRMatrix {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"
        guard let image = filter.outputImage else { throw FacetError.tooDense }
        // CIQRCodeGenerator includes a one-module white border. Store only the symbol;
        // QRView supplies the full four-module quiet zone on every device.
        let bounds = image.extent.insetBy(dx: 1, dy: 1)
        let width = Int(bounds.width)
        guard width <= 89 else { throw FacetError.tooDense }
        let context = CIContext(options: [.useSoftwareRenderer: true])
        var pixels = [UInt8](repeating: 255, count: width * width)
        context.render(image, toBitmap: &pixels, rowBytes: width, bounds: bounds,
                       format: .L8, colorSpace: CGColorSpaceCreateDeviceGray())
        return try QRMatrix(width: width, modules: Data(pixels.map { $0 < 128 ? 1 : 0 }))
    }
}

#endif
