import SwiftUI

/// Full-screen page background: cool-stone base + faint mineral hatch +
/// per-screen atmospheric radial wash (the orb's interior light).
struct PageBackground: View {
    var atmosphere: Theme.Atmosphere = .calm

    var body: some View {
        ZStack {
            Theme.Color.stone50
                .ignoresSafeArea()

            // Hatch texture — diagonal mineral grain at very low alpha.
            HatchPattern()
                .opacity(0.018)
                .ignoresSafeArea()

            atmosphericTint
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var atmosphericTint: some View {
        switch atmosphere {
        case .calm:
            ZStack {
                RadialGradient(
                    colors: [Theme.Color.accent.opacity(0.10), .clear],
                    center: UnitPoint(x: 0.18, y: -0.10), startRadius: 0, endRadius: 380
                )
                RadialGradient(
                    colors: [Theme.Color.chartreuse.opacity(0.05), .clear],
                    center: UnitPoint(x: 1.0, y: 1.10), startRadius: 0, endRadius: 320
                )
            }
        case .dawn:
            ZStack {
                RadialGradient(
                    colors: [Theme.Color.accent.opacity(0.16), .clear],
                    center: UnitPoint(x: 0.5, y: -0.15), startRadius: 0, endRadius: 420
                )
                RadialGradient(
                    colors: [Theme.Color.chartreuse.opacity(0.08), .clear],
                    center: UnitPoint(x: 0.5, y: 1.10), startRadius: 0, endRadius: 340
                )
            }
        case .celebration:
            ZStack {
                RadialGradient(
                    colors: [Theme.Color.accent.opacity(0.18), .clear],
                    center: UnitPoint(x: 0.5, y: -0.10), startRadius: 0, endRadius: 460
                )
                RadialGradient(
                    colors: [Theme.Color.chartreuse.opacity(0.10), .clear],
                    center: UnitPoint(x: 0.2, y: 1.0), startRadius: 0, endRadius: 320
                )
                RadialGradient(
                    colors: [Theme.Color.accent.opacity(0.08), .clear],
                    center: UnitPoint(x: 0.9, y: 0.5), startRadius: 0, endRadius: 280
                )
            }
        case .night:
            ZStack {
                Theme.Color.nightBg
                RadialGradient(
                    colors: [Theme.Color.accent.opacity(0.32), .clear],
                    center: UnitPoint(x: 0.12, y: -0.05), startRadius: 0, endRadius: 460
                )
            }
            .ignoresSafeArea()
        }
    }
}

private struct HatchPattern: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 5
            let angle: Double = 118 * .pi / 180
            let dx = cos(angle) * 800
            let dy = sin(angle) * 800
            var y: CGFloat = -size.height
            while y < size.height * 2 {
                var path = Path()
                path.move(to: CGPoint(x: -CGFloat(dx), y: y - CGFloat(dy)))
                path.addLine(to: CGPoint(x: CGFloat(dx), y: y + CGFloat(dy)))
                ctx.stroke(path,
                           with: .color(Theme.Color.ink),
                           lineWidth: 1)
                y += spacing
            }
        }
    }
}
