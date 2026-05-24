import SwiftUI

/// 1–5 spark rating. Indigo fill, no glow. Legibility first.
/// `onTap` makes the stars interactive; omit for display-only.
struct SparkStars: View {
    let filled: Int
    var size: CGFloat = 14
    var onTap: ((Int) -> Void)? = nil

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { i in
                Button {
                    onTap?(i)
                } label: {
                    StarShape()
                        .fill(i <= filled ? Theme.Color.accent : .clear)
                        .overlay(
                            StarShape()
                                .stroke(i <= filled ? Theme.Color.accent : Theme.Color.stone300,
                                        lineWidth: 1.5)
                        )
                        .frame(width: size, height: size)
                }
                .buttonStyle(.plain)
                .disabled(onTap == nil)
            }
        }
    }
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r1 = min(rect.width, rect.height) / 2
        let r2 = r1 * 0.42
        for i in 0..<10 {
            let angle = -.pi / 2 + Double(i) * .pi / 5
            let r = i.isMultiple(of: 2) ? r1 : r2
            let x = cx + CGFloat(cos(angle)) * r
            let y = cy + CGFloat(sin(angle)) * r
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
            else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        p.closeSubpath()
        return p
    }
}

#Preview {
    VStack(spacing: 12) {
        SparkStars(filled: 0)
        SparkStars(filled: 3, size: 22)
        SparkStars(filled: 5, size: 30)
    }
    .padding()
    .background(Theme.Color.stone50)
}
