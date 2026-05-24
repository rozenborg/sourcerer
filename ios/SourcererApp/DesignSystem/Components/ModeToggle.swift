import SwiftUI

enum HomeMode: String, CaseIterable {
    case deck = "DECK"
    case list = "LIST"
}

/// DECK / LIST segmented control in the home header.
struct ModeToggle: View {
    @Binding var mode: HomeMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeMode.allCases, id: \.self) { m in
                let on = m == mode
                Button {
                    withAnimation(.easeInOut(duration: 0.12)) { mode = m }
                } label: {
                    Text(m.rawValue)
                        .font(Theme.Typography.meta(10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(on ? Theme.Color.stone50 : Theme.Color.inkSoft)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(on ? Theme.Color.ink : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Theme.Color.stone100, in: Capsule())
        .overlay(Capsule().stroke(Theme.Color.stone200, lineWidth: 1))
    }
}
