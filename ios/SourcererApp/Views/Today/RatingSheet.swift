import SwiftUI

/// Quick (one tap rates) but expressive (reasons + note). Until the ratings
/// table ships (PRODUCT_SPEC §3) we project sparks → existing interactions:
///   1–2 → pass · 3 → spark · 4–5 → spark + save.
struct RatingSheet: View {
    let article: Article
    /// Caller persists the rating. Reasons + note are captured but not yet
    /// persisted server-side (no schema for them yet).
    let onSubmit: (_ sparks: Int, _ note: String?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var sparks: Int = 0
    @State private var note: String = ""
    @State private var selectedReasons: Set<String> = []

    /// Allowed reasons taxonomy (PRODUCT_SPEC §3 initial set).
    private let reasons: [String] = [
        "SHARP", "SURPRISED ME", "AGREE", "DISAGREE",
        "REREAD", "BORING", "TOO SHALLOW", "JUNK", "NEW TOPIC"
    ]

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    label("quick rate · trains your deck")
                    Text(article.title ?? "Untitled")
                        .font(Theme.Typography.display(20))
                        .kerning(-0.2)
                        .foregroundStyle(Theme.Color.ink)

                    sparkCard
                    reasonsBlock
                    noteBlock
                }
                .padding(EdgeInsets(top: 18, leading: 22, bottom: 24, trailing: 22))
            }

            VStack {
                Spacer()
                ctaBar
                    .padding(.horizontal, 22)
                    .padding(.bottom, 14)
            }
        }
    }

    private var sparkCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("sparks")
            HStack {
                SparkStars(filled: sparks, size: 30) { tapped in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        sparks = tapped == sparks ? 0 : tapped
                    }
                }
                Spacer()
                if sparks > 0 {
                    Text(sparkPhrase)
                        .font(Theme.Typography.serif(16).italic())
                        .foregroundStyle(Theme.Color.accent)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.Color.stone200, lineWidth: 1)
        )
    }

    private var sparkPhrase: String {
        switch sparks {
        case 1: return "skip"
        case 2: return "meh"
        case 3: return "decent"
        case 4: return "worth it"
        case 5: return "essential"
        default: return ""
        }
    }

    private var reasonsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            label("why · tap any")
            FlowLayout(spacing: 6) {
                ForEach(reasons, id: \.self) { reason in
                    let on = selectedReasons.contains(reason)
                    Button {
                        if on { selectedReasons.remove(reason) } else { selectedReasons.insert(reason) }
                    } label: {
                        Text(reason)
                            .font(Theme.Typography.meta(10, weight: on ? .bold : .medium))
                            .tracking(0.6)
                            .foregroundStyle(on ? .white : Theme.Color.inkSoft)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(on ? Theme.Color.ink : .clear, in: Capsule())
                            .overlay(Capsule().stroke(on ? Theme.Color.ink : Theme.Color.stone200, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var noteBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("note · optional")
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("Add a few words — pair this with the SAE jailbreak paper, etc.")
                        .font(Theme.Typography.serif(14).italic())
                        .foregroundStyle(Theme.Color.stone300)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $note)
                    .font(Theme.Typography.serif(14).italic())
                    .foregroundStyle(Theme.Color.ink)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 84)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.Color.stone200, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
    }

    private var ctaBar: some View {
        HStack(spacing: 10) {
            Button {
                onSubmit(max(sparks, 4), note.isEmpty ? nil : note)
                dismiss()
            } label: {
                Text("+ TOMORROW")
                    .font(Theme.Typography.meta(10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Theme.Color.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.Color.ink, lineWidth: 1.5)
                    )
            }

            Button {
                onSubmit(sparks, note.isEmpty ? nil : note)
                dismiss()
            } label: {
                Text(sparks > 0 ? "NEXT CARD →" : "SKIP →")
                    .font(Theme.Typography.meta(10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.Color.accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .modifier(CtaGlow())
            }
        }
    }

    private func label(_ s: String) -> some View {
        Text(s.uppercased())
            .font(Theme.Typography.meta(10))
            .tracking(1.2)
            .foregroundStyle(Theme.Color.stone300)
    }
}

private struct CtaGlow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Theme.Color.accent.opacity(0.32), radius: 12)
            .shadow(color: Color.black.opacity(0.18), radius: 7, y: 4)
    }
}

/// Simple left-to-right wrapping flow layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxWidth {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            x += s.width + spacing
            lineHeight = max(lineHeight, s.height)
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            lineHeight = max(lineHeight, s.height)
        }
    }
}
