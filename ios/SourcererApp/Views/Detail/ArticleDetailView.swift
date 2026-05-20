import SwiftUI
import MarkdownUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(AppEnvironment.self) private var env
    @Environment(\.openURL) private var openURL

    @State private var interaction: ArticleInteraction?
    @State private var actionError: String?

    private var parsed: ParsedSummary { ParsedSummary.parse(article.summary) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SourceBadge(sourceType: article.sourceType)
                    if let prefix = parsed.prefixTag {
                        Text(prefix).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let sourceName = article.sourceName {
                        Text(sourceName).font(.caption).foregroundStyle(.secondary)
                    }
                }

                if let title = article.title, !title.isEmpty {
                    Text(title).font(.largeTitle.weight(.semibold))
                }

                if let headline = parsed.headline {
                    Text(headline).font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Divider()

                if !parsed.body.isEmpty {
                    Markdown(parsed.body)
                        .markdownTheme(.basic)
                }

                actionRow
                    .padding(.top, 8)

                Button {
                    if let url = URL(string: article.url) { openURL(url) }
                } label: {
                    Label("Open original", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadInteraction() }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            actionButton(.pass, label: "Pass", icon: "xmark.circle", tint: .gray,
                         active: interaction?.isPassed == true)
            actionButton(.star, label: "Star", icon: "star", tint: .yellow,
                         active: interaction?.isStarred == true)
            actionButton(.save, label: "Save", icon: "bookmark", tint: .blue,
                         active: interaction?.isSaved == true)
        }
    }

    @ViewBuilder
    private func actionButton(_ action: InteractionAction,
                              label: String,
                              icon: String,
                              tint: Color,
                              active: Bool) -> some View {
        Button {
            Task { await toggle(action) }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: active ? "\(icon).fill" : icon)
                    .font(.title3)
                Text(label).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(active ? tint.opacity(0.18) : Color.clear,
                        in: .rect(cornerRadius: 10))
            .foregroundStyle(active ? tint : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.tertiary, lineWidth: active ? 0 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func loadInteraction() async {
        do {
            interaction = try await env.interactions.interaction(for: article.id)
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func toggle(_ action: InteractionAction) async {
        let alreadyActive: Bool
        switch action {
        case .pass: alreadyActive = interaction?.isPassed  == true
        case .star: alreadyActive = interaction?.isStarred == true
        case .save: alreadyActive = interaction?.isSaved   == true
        }
        do {
            if alreadyActive {
                try await env.interactions.clearAction(action, articleId: article.id)
            } else {
                try await env.interactions.setAction(action, articleId: article.id)
            }
            await loadInteraction()
        } catch {
            actionError = error.localizedDescription
        }
    }
}
