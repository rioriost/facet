#if os(iOS)
import SwiftUI

/// Keeps a complete, square QR clear of page controls and the display fold.
struct AdaptiveQRPage<Content: View>: View {
    @ViewBuilder let content: (CGFloat) -> Content

    var body: some View {
        GeometryReader { geometry in
            let region = readableRegion(in: geometry)
            let height = max(1, region.height - 52)
            let side = max(1, min(region.width - 32, height * 0.62))
            ScrollView {
                VStack(spacing: 20) { content(side) }
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: height)
            }
            .frame(width: region.width, height: height)
            .position(x: region.midX, y: region.minY + height / 2)
        }
    }

    private func readableRegion(in geometry: GeometryProxy) -> CGRect {
        var result = CGRect(origin: .zero, size: geometry.size)
        if #available(iOS 27.1, *) {
            for region in geometry.reservedRegions(kind: .division, layoutDirectionBehavior: .fixed)
                where region.isActive {
                let frame = region.frame
                let margins = region.margins
                let exclusion = CGRect(x: frame.minX - margins.leading,
                                       y: frame.minY - margins.top,
                                       width: frame.width + margins.leading + margins.trailing,
                                       height: frame.height + margins.top + margins.bottom)
                let cut = result.intersection(exclusion)
                guard !cut.isNull else { continue }
                let candidates = [
                    CGRect(x: result.minX, y: result.minY, width: max(0, cut.minX - result.minX), height: result.height),
                    CGRect(x: cut.maxX, y: result.minY, width: max(0, result.maxX - cut.maxX), height: result.height),
                    CGRect(x: result.minX, y: result.minY, width: result.width, height: max(0, cut.minY - result.minY)),
                    CGRect(x: result.minX, y: cut.maxY, width: result.width, height: max(0, result.maxY - cut.maxY))
                ]
                if let largest = candidates.max(by: { $0.width * $0.height < $1.width * $1.height }),
                   largest.width > 0, largest.height > 0 {
                    result = largest
                }
            }
        }
        return result
    }
}
#endif
