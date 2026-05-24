import SwiftUI

/// Solid jewel-tone fill + white text. Carries the color personality of
/// the system. Same color for the same topic, always.
struct TopicChip: View {
    let topic: Topic

    var body: some View {
        Text(topic.label)
            .font(Theme.Typography.meta(9.5, weight: .bold))
            .tracking(1)
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(topic.color, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 6) {
        ForEach(Topic.allCases, id: \.self) { TopicChip(topic: $0) }
    }
    .padding()
    .background(Theme.Color.stone50)
}
