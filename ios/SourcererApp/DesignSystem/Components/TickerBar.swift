import SwiftUI

/// Slim dark band with a "LIVE" indigo block and an animated marquee of topic
/// prefix + headline pairs. No glow on LIVE — chrome, not magic.
struct TickerBar: View {
    let items: [(topic: Topic, headline: String)]

    @State private var offset: CGFloat = 0
    @State private var measuredWidth: CGFloat = 0

    var body: some View {
        ZStack(alignment: .leading) {
            Theme.Color.nightBg

            // LIVE block
            ZStack {
                Theme.Color.accent
                Text("LIVE")
                    .font(Theme.Typography.meta(9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.white)
            }
            .frame(width: 40)
            .zIndex(2)

            // Marquee — two copies of the lane, sliding left forever
            GeometryReader { _ in
                HStack(spacing: 24) {
                    laneCopy
                    laneCopy
                }
                .background(
                    GeometryReader { gp in
                        Color.clear.preference(key: TickerWidthKey.self, value: gp.size.width)
                    }
                )
                .offset(x: 52 + offset)
            }
            .clipped()
        }
        .frame(height: 26)
        .overlay(alignment: .bottom) {
            Theme.Color.stone200.frame(height: 1)
        }
        .onPreferenceChange(TickerWidthKey.self) { measuredWidth = $0 }
        .onAppear { startMarquee() }
    }

    private var laneCopy: some View {
        HStack(spacing: 24) {
            ForEach(items.indices, id: \.self) { i in
                HStack(spacing: 8) {
                    Text(items[i].topic.label)
                        .font(Theme.Typography.meta(9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(Theme.Color.chartreuse)
                    Text(items[i].headline)
                        .font(Theme.Typography.body(11))
                        .foregroundStyle(Theme.Color.nightInk)
                        .lineLimit(1)
                    Text("•").foregroundStyle(Theme.Color.nightMute)
                }
            }
        }
        .fixedSize()
    }

    private func startMarquee() {
        // Reset, then animate. Duration scales with content length.
        guard measuredWidth == 0 || offset == 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let halfWidth = measuredWidth / 2
            guard halfWidth > 0 else { return }
            withAnimation(.linear(duration: 38).repeatForever(autoreverses: false)) {
                offset = -halfWidth
            }
        }
    }
}

private struct TickerWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
