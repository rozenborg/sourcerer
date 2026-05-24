import SwiftUI

/// The article card — the unit of content in DECK mode.
/// Solid topic chip = personality. Indigo frame when `promoted` (saved).
struct DeckCard: View {
    let article: Article
    /// 1-based ordinal in today's deck (the "no. 04 / 18" plate number).
    let index: Int
    /// Total cards in today's deck.
    let total: Int
    var promoted: Bool = false

    private var parsed: ParsedSummary { ParsedSummary.parse(article.summary) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                TopicChip(topic: article.topic)
                if promoted {
                    Text("★ SAVED")
                        .font(Theme.Typography.meta(9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.Color.accent, in: Capsule())
                }
                Spacer()
                Text(plateNumber)
                    .font(Theme.Typography.meta(10))
                    .tracking(0.6)
                    .foregroundStyle(Theme.Color.stone300)
            }

            Text(article.title ?? "Untitled")
                .font(Theme.Typography.display(28))
                .kerning(-0.4)
                .lineSpacing(1)
                .foregroundStyle(Theme.Color.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            if !deckText.isEmpty {
                Text(deckText)
                    .font(Theme.Typography.body(14.5))
                    .foregroundStyle(Theme.Color.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(promoted ? 3 : 5)
            }

            if promoted {
                youSaidCallout
            }

            Spacer(minLength: 0)

            HStack(alignment: .center) {
                Text(metaLine)
                    .font(Theme.Typography.meta(10))
                    .tracking(0.4)
                    .foregroundStyle(Theme.Color.stone300)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                if let author = parsed.prefixTag, !author.isEmpty {
                    Text(author)
                        .font(Theme.Typography.serif(12).italic())
                        .foregroundStyle(Theme.Color.inkSoft)
                        .lineLimit(1)
                }
            }
            .padding(.top, 12)
            .overlay(alignment: .top) {
                Theme.Color.stone100.frame(height: 1)
            }
        }
        .padding(EdgeInsets(top: 22, leading: 22, bottom: 18, trailing: 22))
        .background(
            ZStack {
                Theme.Color.stone0
                MineralHatch()
                    .opacity(0.018)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(promoted ? Theme.Color.accent : Theme.Color.stone200, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .modifier(DeckCardShadow(promoted: promoted))
    }

    /// Concatenated deck text: headline first (if any), then the first body
    /// paragraph. Strips bullets so the deck reads as prose.
    private var deckText: String {
        var parts: [String] = []
        if let h = parsed.headline, !h.isEmpty { parts.append(h) }
        let firstPara = parsed.body
            .split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? ""
        let cleaned = firstPara.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleaned.isEmpty, !cleaned.hasPrefix("-"), !cleaned.hasPrefix("*") {
            parts.append(cleaned)
        }
        return parts.joined(separator: " ")
    }

    private var plateNumber: String {
        String(format: "no. %02d / %02d", index, total)
    }

    private var metaLine: String {
        let parts = [
            "\(article.kindGlyph) \(article.kindLabel)",
            article.sourceName ?? article.sourceId,
            "\(article.readMinutes)m"
        ]
        return parts.joined(separator: " · ")
    }

    private var youSaidCallout: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOU SAID")
                .font(Theme.Typography.meta(9, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.Color.accentDark)
            Text("\"Sharp — worth pairing with the long-context replay paper.\"")
                .font(Theme.Typography.serif(12.5).italic())
                .foregroundStyle(Theme.Color.ink)
            HStack {
                SparkStars(filled: 5, size: 14)
                Spacer()
                Text("saved · 2m ago")
                    .font(Theme.Typography.meta(9))
                    .tracking(0.4)
                    .foregroundStyle(Theme.Color.stone300)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.Color.accentTint, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.Color.stone200, lineWidth: 1)
        )
    }
}

private struct DeckCardShadow: ViewModifier {
    let promoted: Bool
    func body(content: Content) -> some View {
        if promoted {
            content
                .shadow(color: Theme.Color.accent.opacity(0.10), radius: 0)
                .shadow(color: Color.black.opacity(0.20), radius: 13, y: 6)
        } else {
            content
                .shadow(color: Color.black.opacity(0.20), radius: 13, y: 6)
        }
    }
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
