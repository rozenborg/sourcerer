import SwiftUI

/// One row in LIST mode — number, topic chip, title, source meta, status pill.
/// Topic color renders as a vertical rail on the left.
struct ListRowCard: View {
    let article: Article
    let index: Int
    let status: RowStatus

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(String(format: "%02d", index))
                .font(Theme.Typography.meta(10))
                .tracking(0.3)
                .monospacedDigit()
                .foregroundStyle(Theme.Color.stone300)
                .frame(width: 22, alignment: .leading)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 5) {
                TopicChip(topic: article.topic)
                Text(article.title ?? "Untitled")
                    .font(Theme.Typography.body(14.5, weight: .medium))
                    .foregroundStyle(Theme.Color.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    Text("\(article.kindGlyph) \(article.sourceName ?? article.sourceId)")
                    Text("·")
                    Text("\(article.readMinutes)m")
                }
                .font(Theme.Typography.meta(10))
                .tracking(0.3)
                .foregroundStyle(Theme.Color.stone300)
                .lineLimit(1)
            }

            Spacer(minLength: 6)

            VStack(alignment: .trailing) {
                StatusPill(status: status)
                    .padding(.top, 6)
                Spacer(minLength: 0)
            }
            .frame(width: 60)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .opacity(status == .read ? 0.55 : 1)
        .background(alignment: .leading) {
            Rectangle()
                .fill(article.topic.color)
                .frame(width: 3)
        }
        .overlay(alignment: .bottom) {
            Theme.Color.stone100.frame(height: 1)
        }
    }
}
