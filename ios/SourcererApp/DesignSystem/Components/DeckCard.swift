import SwiftUI

/// The article card — now a self-contained reader. Header (topic + title) →
/// scrollable middle (lead + full in-depth summary) → footer (rate · later ·
/// share). Tapping the title opens the focused detail view, but it's optional:
/// everything you need to triage and engage lives on the card.
///
/// Gesture split (see DeckPileView): the middle ScrollView owns vertical pans
/// (reading); the card owns horizontal pans (← skip / → save). Postpone moved
/// off the swipe and onto the footer "Later" button.
struct DeckCard: View {
    let article: Article
    /// 1-based ordinal in today's deck (the "no. 04 / 18" plate number).
    let index: Int
    /// Total cards in today's deck.
    let total: Int

    var onOpen: () -> Void = {}        // tap title → focused detail
    var onPostpone: () -> Void = {}    // footer "Later"
    var onRate: (Int) -> Void = { _ in }   // footer stars → quick rate (persists)

    @State private var ratedStars: Int = 0

    private var parsed: ParsedSummary { ParsedSummary.parse(article.summary) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
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

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            TopicChip(topic: article.topic)
            Spacer()
            Text(plateNumber)
                .font(Theme.Typography.meta(10))
                .tracking(0.6)
                .foregroundStyle(Theme.Color.stone300)
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var titleBlock: some View {
        // Tappable title is the optional doorway to the focused detail view.
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
        .padding(.horizontal, 22)
        .padding(.bottom, 12)
    }

    // MARK: - Reader (scrollable middle)

    private var readerBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let lead = parsed.headline, !lead.isEmpty {
                    Text(lead)
                        .font(Theme.Typography.serif(16, weight: .medium))
                        .foregroundStyle(Theme.Color.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !readerText.isEmpty {
                    Text(readerText)
                        .font(Theme.Typography.body(14.5))
                        .foregroundStyle(Theme.Color.ink)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
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
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
        }
        .frame(maxHeight: .infinity)
    }

    /// The in-depth summary body, with sensible fallbacks if parsing yields no
    /// distinct body (e.g. a one-paragraph summary or the card_teaser window).
    private var readerText: String {
        let body = parsed.body.trimmingCharacters(in: .whitespacesAndNewlines)
        if !body.isEmpty { return body }
        if let s = article.summary?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            return s
        }
        return article.cardTeaser ?? ""
    }

    // MARK: - Footer (rate · later · share)

    private var footer: some View {
        HStack(spacing: 12) {
            SparkStars(filled: ratedStars, size: 20) { tapped in
                let newVal = tapped == ratedStars ? 0 : tapped
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    ratedStars = newVal
                }
                onRate(newVal)
            }

            Spacer()

            Button(action: onPostpone) {
                footerLabel("clock.arrow.circlepath", "Later")
            }
            .buttonStyle(.plain)

            ShareLink(item: "I'm going to ask you questions about this content: \(article.url)") {
                footerLabel("square.and.arrow.up", "Share")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private func footerLabel(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text).tracking(0.4)
        }
        .font(Theme.Typography.meta(11, weight: .medium))
        .foregroundStyle(Theme.Color.inkSoft)
    }

    private var plateNumber: String {
        String(format: "no. %02d / %02d", index, total)
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
