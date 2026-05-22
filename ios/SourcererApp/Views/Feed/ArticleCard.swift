import SwiftUI
import Inject

struct ArticleCard: View {
    @ObserveInjection var inject
    let article: Article

    private var parsed: ParsedSummary { ParsedSummary.parse(article.summary) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                SourceBadge(sourceType: article.sourceType)
                if let prefix = parsed.prefixTag {
                    Text(prefix)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let date = article.publishedAt ?? Optional(article.fetchedAt) {
                    Text(date, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let title = article.title, !title.isEmpty {
                Text(title)
                    .font(titleFont)
                    .lineLimit(3)
            }

            if let headline = parsed.headline, !headline.isEmpty {
                Text(headline)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
            }

            if !parsed.body.isEmpty {
                Text(parsed.body)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            if let sourceName = article.sourceName {
                Text(sourceName)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
        .enableInjection()
    }

    private var titleFont: Font {
        switch article.sourceType {
        case .rss, .sitemap:           .title3.weight(.semibold)
        case .podcast:                 .title3.weight(.semibold).italic()
        case .youtube:                 .title3.weight(.bold)
        case .scholarly, .scholarlyRSS, .scholarlyAuthors:
                                       .body.weight(.semibold)
        case .unknown:                 .body
        }
    }
}

struct SourceBadge: View {
    let sourceType: SourceType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(sourceType.displayName)
                .font(.caption2.weight(.medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(tint.opacity(0.15), in: .capsule)
        .foregroundStyle(tint)
    }

    private var icon: String {
        switch sourceType {
        case .rss, .sitemap:           "doc.text"
        case .podcast:                 "waveform"
        case .youtube:                 "play.rectangle"
        case .scholarly, .scholarlyRSS:"graduationcap"
        case .scholarlyAuthors:        "person.crop.circle.badge.checkmark"
        case .unknown:                 "questionmark.circle"
        }
    }

    private var tint: Color {
        switch sourceType {
        case .rss, .sitemap:           .blue
        case .podcast:                 .purple
        case .youtube:                 .red
        case .scholarly, .scholarlyRSS:.indigo
        case .scholarlyAuthors:        .teal
        case .unknown:                 .gray
        }
    }
}

#Preview {
    List {
        ForEach(MockData.articles) { article in
            ArticleCard(article: article)
        }
    }
    .listStyle(.plain)
}
