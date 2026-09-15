import SwiftUI
import FacetCore

struct QRView: View {
    let matrix: QRMatrix
    @Environment(\.displayScale) private var scale
    var body: some View {
        Canvas { context, size in
            let modules = matrix.width + 8 // Four white modules on each edge.
            let pixelSize = floor(min(size.width, size.height) * scale / CGFloat(modules))
            guard pixelSize >= 1 else { return }
            let unit = pixelSize / scale
            let side = unit * CGFloat(modules)
            let origin = CGPoint(x: floor((size.width - side) * scale / 2) / scale,
                                 y: floor((size.height - side) * scale / 2) / scale)
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))
            var path = Path()
            for y in 0..<matrix.width {
                for x in 0..<matrix.width where matrix.modules[y * matrix.width + x] == 1 {
                    path.addRect(CGRect(x: origin.x + CGFloat(x + 4) * unit,
                                        y: origin.y + CGFloat(y + 4) * unit, width: unit, height: unit))
                }
            }
            context.fill(path, with: .color(.black), style: FillStyle(antialiased: false))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(L10n.text("qr.accessibility"))
    }
}
