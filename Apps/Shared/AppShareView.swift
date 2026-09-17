import SwiftUI
import FacetCore

/// A fixed App Store QR, independent of contact selections and Watch sync.
struct AppShareView: View {
    @Environment(\.scenePhase) private var phase
    #if os(watchOS)
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    #endif

    var body: some View {
        #if os(watchOS)
        GeometryReader { geometry in
            let side = max(1, min(geometry.size.width, geometry.size.height - 32))
            VStack(spacing: 2) {
                Text(L10n.text("app.share"))
                    .font(.caption2).multilineTextAlignment(.center)
                    .lineLimit(2).minimumScaleFactor(0.7)
                    .padding(.horizontal, 6).frame(height: 30)
                if phase == .active, !isLuminanceReduced {
                    code.frame(width: side, height: side)
                } else {
                    Color.clear.frame(width: side, height: side)
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
        #else
        VStack(spacing: 20) {
            Text(L10n.text("app.share"))
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center).padding(.horizontal)
            if phase == .active {
                code.padding(.horizontal, 26)
            } else {
                Color.clear.aspectRatio(1, contentMode: .fit).padding(.horizontal, 26)
            }
            Text(L10n.text("phone.scan")).font(.subheadline).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    private var code: some View {
        QRView(matrix: AppShare.matrix)
            .accessibilityLabel(L10n.text("app.share"))
            .accessibilityIdentifier("qr-app-share")
    }
}
