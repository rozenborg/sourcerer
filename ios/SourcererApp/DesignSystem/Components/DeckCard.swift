import SwiftUI
import MarkdownUI

/// The article card — a self-contained reader.
///
///   top:    source meta (left)  ·  Later / Share (right)
///   title:  tap → focused detail (optional)
///   middle: scrollable, markdown-formatted in-depth summary
///   footer: thumbs verdict (👎 👍 👍👍)  ·  ← skip / save → hints
///
/// Gesture split (see DeckPileView): the middle ScrollView owns vertical pans
/// (reading); the card owns horizontal pans (← skip / → save). The deck-order
/// "no. N / total" plate lives outside the card, above the pile.
struct DeckCard: View {
    let article: Article

    /// The persisted verdict for this article, supplied by the deck so the
    /// footer highlight reflects the source of truth (not write-only state).
    var selectedVerdict: Verdict? = nil
    var onOpen: () -> Void = {}            // tap title → focused detail
    var onPostpone: () -> Void = {}        // top-right "Later"
    var onVerdict: (Verdict) -> Void = { _ in }   // footer thumbs → feedback

    private var parsed: ParsedSummary { ParsedSummary.parse(article.summary) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar
            titleBlock
            Theme.Color.stone200.frame(height: 1)
            readerBody
            Theme.Color.stone200.frame(height: 1)
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            ZStack {
                Theme.Color.stone0
                MineralHatch().opacity(0.018)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Color.stone200, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.20), radius: 13, y: 6)
    }

    // MARK: - Top bar (source · later · share)

    private var topBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(sourceMeta)
                .font(Theme.Typography.meta(10))
                .tracking(0.4)
                .foregroundStyle(Theme.Color.stone300)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Button(action: onPostpone) {
                topIcon("clock.arrow.circlepath")
            }
            .buttonStyle(.plain)

            ShareLink(item: "I'm going to ask you questions about this content: \(article.url)") {
                topIcon("square.and.arrow.up")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 10)
    }

    private func topIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Theme.Color.inkSoft)
            .frame(width: 30, height: 26)
    }

    private var titleBlock: some View {
        Button(action: onOpen) {
            Text(article.title ?? "Untitled")
                .font(Theme.Typography.display(23))
                .kerning(-0.4)
                .lineSpacing(1)
                .foregroundStyle(Theme.Color.ink)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Reader (scrollable, markdown)

    private var readerBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let lead = parsed.headline, !lead.isEmpty {
                    Text(lead)
                        .font(Theme.Typography.serif(16, weight: .medium))
                        .foregroundStyle(Theme.Color.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !markdownBody.isEmpty {
                    Markdown(markdownBody)
                        .markdownTheme(.basic)
                        .markdownTextStyle { ForegroundColor(Theme.Color.ink) }
                        .tint(Theme.Color.accent)
                }
                if let score = parsed.mollickScore {
                    Text("MOLLICK-LIKENESS · \(score)/20")
                        .font(Theme.Typography.meta(9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Theme.Color.stone300)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(maxHeight: .infinity)
    }

    /// The in-depth summary body, markdown-formatted, with fallbacks if parsing
    /// yields no distinct body (one-paragraph summary, or the card_teaser window).
    private var markdownBody: String {
        let body = parsed.body.trimmingCharacters(in: .whitespacesAndNewlines)
        if !body.isEmpty { return body }
        if let s = article.summary?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            return s
        }
        return article.cardTeaser ?? ""
    }

    // MARK: - Footer (verdict · skip/save hints)

    private var footer: some View {
        HStack(spacing: 10) {
            VerdictPicker(selected: selectedVerdict, size: 19) { v in
                onVerdict(v)
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Image(systemName: "arrow.left")
                Text("skip").tracking(0.5)
            }
            .foregroundStyle(Theme.Color.stone300)

            HStack(spacing: 4) {
                Text("save").tracking(0.5)
                Image(systemName: "arrow.right")
            }
            .foregroundStyle(Theme.Color.sage)
        }
        .font(Theme.Typography.meta(10))
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var sourceMeta: String {
        var parts: [String] = ["\(article.kindGlyph) \(article.sourceName ?? article.sourceId)"]
        parts.append("\(article.readMinutes)m")
        if let date = article.publishedAt {
            parts.append(Self.relativeFormatter.localizedString(for: date, relativeTo: Date()))
        }
        return parts.joined(separator: " · ")
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()
}

private struct MineralHatch: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 5
            let angle: Double = 118 * Double.pi / 180
            let dx = cos(angle) * 800
            let dy = sin(angle) * 800
            var y: CGFloat = -size.height
            while y < size.height * 2 {
                var path = Path()
                path.move(to: CGPoint(x: -CGFloat(dx), y: y - CGFloat(dy)))
                path.addLine(to: CGPoint(x: CGFloat(dx), y: y + CGFloat(dy)))
                ctx.stroke(path, with: .color(Theme.Color.ink), lineWidth: 1)
                y += spacing
            }
        }
    }
}
