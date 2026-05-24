import SwiftUI

/// The brand mark — a scrying sphere holding a library of sources.
/// Halo only at briefing scale; small everywhere else.
struct OrbView: View {
    var size: CGFloat = 28
    var halo: Bool = false

    var body: some View {
        // Asset catalog uses the literal filename "orb" (copied from the design bundle).
        Image("Orb")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: halo ? Theme.Color.accent.opacity(0.55) : Color.black.opacity(0.25),
                    radius: halo ? 12 : 2, y: halo ? 0 : 1)
    }
}

/// Big briefing-scale orb with the chartreuse pulsing dashed ring around it.
/// This is the ONE place we use the full brand-glow language.
struct BriefingOrb: View {
    var diameter: CGFloat = 210
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Soft indigo wash behind
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.Color.accent.opacity(0.42), Theme.Color.accent.opacity(0)],
                        center: .center, startRadius: 0, endRadius: diameter * 0.7
                    )
                )
                .frame(width: diameter + 50, height: diameter + 50)
                .blur(radius: 4)

            // Pulsing chartreuse dashed ring
            Circle()
                .strokeBorder(
                    Theme.Color.chartreuse.opacity(0.85),
                    style: StrokeStyle(lineWidth: 1.5, dash: [2, 9])
                )
                .frame(width: diameter + 30, height: diameter + 30)
                .shadow(color: Theme.Color.chartreuse.opacity(0.7), radius: 6)
                .opacity(pulse ? 1.0 : 0.55)
                .animation(.easeInOut(duration: 2.2).repeatForever(), value: pulse)

            // The orb itself, three stacked shadows = "lit from within"
            Image("Orb")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: diameter, height: diameter)
                .shadow(color: Theme.Color.accent.opacity(0.55), radius: 32)
                .shadow(color: Theme.Color.chartreuse.opacity(0.22), radius: 12)
                .shadow(color: Color.black.opacity(0.30), radius: 22, y: 8)
        }
        .onAppear { pulse = true }
    }
}
