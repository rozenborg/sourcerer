import SwiftUI

/// Streak + day-progress bar — the only glow in default view lives on the
/// progress fill (motion forward through the day).
struct StreakRibbon: View {
    let streak: Int
    let cleared: Int
    let total: Int

    private var dayProgress: Double {
        total == 0 ? 0 : Double(cleared) / Double(total)
    }

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                Triangle()
                    .fill(Theme.Color.accent)
                    .frame(width: 9, height: 9)
                Text("\(streak)")
                    .font(Theme.Typography.meta(11, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.Color.ink)
            }

            Text("day streak")
                .font(Theme.Typography.meta(10))
                .tracking(0.4)
                .foregroundStyle(Theme.Color.stone300)

            // Progress track + glowing fill
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.Color.stone200)
                    .frame(height: 3)

                GeometryReader { geo in
                    Capsule()
                        .fill(Theme.Color.accent)
                        .frame(width: max(0, geo.size.width * dayProgress), height: 3)
                        .modifier(GlowProgress())
                }
                .frame(height: 3)
            }

            HStack(spacing: 4) {
                Text("\(cleared)")
                    .font(Theme.Typography.meta(10))
                    .monospacedDigit()
                    .foregroundStyle(Theme.Color.inkSoft)
                Text("/ \(total)")
                    .font(Theme.Typography.meta(10))
                    .monospacedDigit()
                    .foregroundStyle(Theme.Color.stone300)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 7)
        .background(Theme.Color.stone100)
        .overlay(alignment: .bottom) {
            Theme.Color.stone200.frame(height: 1)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

private struct GlowProgress: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Theme.Color.accent.opacity(0.70), radius: 5)
    }
}
