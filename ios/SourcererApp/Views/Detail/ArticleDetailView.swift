import SwiftUI
import MarkdownUI

/// Article detail — the new design language. Topic chip + italic display
/// title + serif body. Action row maps to existing interactions (pass/star/
/// save) until full rating + deep-mode tables ship.
struct ArticleDetailView: View {
    let article: Article
    @Environment(AppEnvironment.self) private var env
    @Environment(\.openURL) private var openURL

    @State private var interaction: ArticleInteraction?
    @State private var rating: ArticleRating?
    @State private var actionError: String?
    @State private var showRatingSheet = false

    private var parsed: ParsedSummary { ParsedSummary.parse(article.summary) }

    /// Rated if there's a thumbs verdict OR a legacy star rating (the migration
    /// preserves pre-thumbs stars; treat them as "rated" so they're not hidden).
    private var isRated: Bool { rating?.verdict != nil || rating?.stars != nil }

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        TopicChip(topic: article.topic)
                        if let prefix = parsed.prefixTag {
                            Text(prefix.uppercased())
                                .font(Theme.Typography.meta(9, weight: .bold))
                                .tracking(0.6)
                                .foregroundStyle(Theme.Color.stone300)
                        }
                        Spacer()
                        Text(metaSourceLine)
                            .font(Theme.Typography.meta(10))
                            .tracking(0.4)
                            .foregroundStyle(Theme.Color.stone300)
                            .lineLimit(1)
                    }

                    if let title = article.title, !title.isEmpty {
                        Text(title)
                            .font(Theme.Typography.display(34))
                            .kerning(-0.6)
                            .foregroundStyle(Theme.Color.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let headline = parsed.headline {
                        Text(headline)
                            .font(Theme.Typography.serif(18, weight: .medium))
                            .foregroundStyle(Theme.Color.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Theme.Color.stone200.frame(height: 1)

                    if !parsed.body.isEmpty {
                        Markdown(parsed.body)
                            .markdownTheme(.basic)
                            .markdownTextStyle {
                                ForegroundColor(Theme.Color.ink)
                            }
                            .tint(Theme.Color.accent)
                    }

                    if let score = parsed.mollickScore {
                        Text("MOLLICK-LIKENESS · \(score)/20")
                            .font(Theme.Typography.meta(9, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(Theme.Color.stone300)
                            .padding(.top, 4)
                    }

                    actionRow
                        .padding(.top, 8)

                    Button {
                        if let url = URL(string: article.url) { openURL(url) }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Open original")
                                .font(Theme.Typography.meta(11, weight: .bold))
                                .tracking(0.6)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Color.accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: Theme.Color.accent.opacity(0.32), radius: 12)
                        .shadow(color: Color.black.opacity(0.18), radius: 7, y: 4)
                    }
                    .buttonStyle(.plain)

                    // Hand off to an LLM app (Claude, etc.) via the system
                    // share sheet, pre-loaded with a framing line + the URL.
                    // No backend, no stored text — the receiving app fetches
                    // the piece itself.
                    ShareLink(item: "I'm going to ask you questions about this content: \(article.url)") {
                        HStack {
                            Image(systemName: "text.bubble")
                            Text("Discuss in Claude")
                                .font(Theme.Typography.meta(11, weight: .bold))
                                .tracking(0.6)
                        }
                        .foregroundStyle(Theme.Color.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Theme.Color.ink, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)

                    if let actionError {
                        Text(actionError)
                            .font(Theme.Typography.body(12))
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadState() }
        .sheet(isPresented: $showRatingSheet) {
            FeedbackSheet(article: article, initialVerdict: rating?.verdictValue, existingComment: rating?.note) { verdict, comment in
                Task { await applyVerdict(verdict, comment) }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var metaSourceLine: String {
        var parts: [String] = []
        if let s = article.sourceName ?? Optional(article.sourceId) { parts.append(s.uppercased()) }
        parts.append("\(article.readMinutes)M")
        return parts.joined(separator: " · ")
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            actionButton("Skip", icon: "xmark", on: interaction?.isPassed == true, tint: Theme.Color.stone300) {
                Task { await toggle(.pass) }
            }
            actionButton(isRated ? "Rated" : "Rate", icon: "hand.thumbsup", on: isRated, tint: Theme.Color.accent) {
                showRatingSheet = true
            }
            actionButton("Save", icon: "bookmark", on: interaction?.isSaved == true, tint: Theme.Color.sage) {
                Task { await toggle(.save) }
            }
        }
    }

    @ViewBuilder
    private func actionButton(_ label: String, icon: String, on: Bool, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: on ? "\(icon).fill" : icon)
                    .font(.system(size: 16))
                Text(label.uppercased())
                    .font(Theme.Typography.meta(10, weight: .bold))
                    .tracking(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(on ? tint.opacity(0.18) : Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(on ? tint : Theme.Color.stone200, lineWidth: on ? 1.5 : 1)
            )
            .foregroundStyle(on ? tint : Theme.Color.inkSoft)
        }
        .buttonStyle(.plain)
    }

    private func loadState() async {
        do {
            interaction = try await env.interactions.interaction(for: article.id)
            rating = try await env.ratings.rating(for: article.id)
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func toggle(_ action: InteractionAction) async {
        let alreadyActive: Bool
        switch action {
        case .pass: alreadyActive = interaction?.isPassed == true
        case .star: alreadyActive = interaction?.isStarred == true
        case .save: alreadyActive = interaction?.isSaved == true
        }
        do {
            if alreadyActive {
                try await env.interactions.clearAction(action, articleId: article.id)
            } else {
                try await env.interactions.setAction(action, articleId: article.id)
            }
            await loadState()
        } catch {
            actionError = error.localizedDescription
        }
    }

    /// Persist a verdict + comment to `article_ratings` — the considered
    /// signal. Pure feed-tuning data; it doesn't touch the triage interactions
    /// (skip/save) or clear the piece from anywhere.
    private func applyVerdict(_ verdict: Verdict, _ comment: String?) async {
        do {
            try await env.ratings.setFeedback(articleId: article.id, verdict: verdict.rawValue, comment: comment)
            await loadState()
        } catch {
            actionError = error.localizedDescription
        }
    }
}
