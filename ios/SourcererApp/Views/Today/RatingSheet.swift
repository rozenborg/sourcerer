import SwiftUI

/// Capture a reaction to a piece: a thumbs verdict + an optional comment.
/// The comment is the point — it's how Sourcerer learns what to show you — so
/// the sheet leads with the prompt. Persisted to `article_ratings`.
///
/// Opened from the deck card (with the tapped thumb pre-selected) and from the
/// detail view (no pre-selection). Either way, submitting writes the verdict
/// and comment via `RatingsRepository`.
struct FeedbackSheet: View {
    let article: Article
    var initialVerdict: Verdict? = nil
    var existingComment: String? = nil
    let onSubmit: (_ verdict: Verdict, _ comment: String?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var verdict: Verdict?
    @State private var comment: String = ""
    @State private var didSubmit = false

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    label("your take")
                    Text(article.title ?? "Untitled")
                        .font(Theme.Typography.display(20))
                        .kerning(-0.2)
                        .foregroundStyle(Theme.Color.ink)

                    verdictCard
                    commentBlock
                }
                .padding(EdgeInsets(top: 18, leading: 22, bottom: 120, trailing: 22))
            }

            VStack {
                Spacer()
                cta
                    .padding(.horizontal, 22)
                    .padding(.bottom, 14)
            }
        }
        .onAppear {
            verdict = initialVerdict
            comment = existingComment ?? ""
        }
        .onDisappear {
            // Drag-to-dismiss without tapping SAVE would otherwise drop a typed
            // comment. Flush it (once) if a verdict is set.
            if !didSubmit, let v = verdict {
                onSubmit(v, comment.isEmpty ? nil : comment)
            }
        }
    }

    private var verdictCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("reaction")
            HStack {
                VerdictPicker(selected: verdict, size: 28) { v in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { verdict = v }
                }
                Spacer()
                if let v = verdict {
                    Text(v.phrase)
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

    private var commentBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("comment · helps personalize your feed")
            ZStack(alignment: .topLeading) {
                if comment.isEmpty {
                    Text("What landed, what didn't, what you'd want more or less of…")
                        .font(Theme.Typography.serif(14).italic())
                        .foregroundStyle(Theme.Color.stone300)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $comment)
                    .font(Theme.Typography.serif(14).italic())
                    .foregroundStyle(Theme.Color.ink)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
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

    private var cta: some View {
        Button {
            if let v = verdict {
                didSubmit = true
                onSubmit(v, comment.isEmpty ? nil : comment)
            }
            dismiss()
        } label: {
            Text(verdict == nil ? "PICK A REACTION" : "SAVE")
                .font(Theme.Typography.meta(10, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    verdict == nil ? Theme.Color.stone300 : Theme.Color.accent,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
        }
        .disabled(verdict == nil)
    }

    private func label(_ s: String) -> some View {
        Text(s.uppercased())
            .font(Theme.Typography.meta(10))
            .tracking(1.2)
            .foregroundStyle(Theme.Color.stone300)
    }
}

/// The three-level thumbs control: 👎 · 👍 · 👍👍. Reused on the card footer
/// (small) and in the feedback sheet (large).
struct VerdictPicker: View {
    var selected: Verdict?
    var size: CGFloat = 22
    var onSelect: (Verdict) -> Void

    var body: some View {
        HStack(spacing: size * 0.6) {
            thumb(.down)
            thumb(.up)
            thumb(.upUp)
        }
    }

    @ViewBuilder
    private func thumb(_ v: Verdict) -> some View {
        let on = selected == v
        Button { onSelect(v) } label: {
            glyph(v)
                .font(.system(size: size, weight: on ? .semibold : .regular))
                .foregroundStyle(on ? tint(v) : Theme.Color.stone300)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    on ? tint(v).opacity(0.14) : .clear,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func glyph(_ v: Verdict) -> some View {
        switch v {
        case .down:
            Image(systemName: "hand.thumbsdown")
        case .up:
            Image(systemName: "hand.thumbsup")
        case .upUp:
            HStack(spacing: -size * 0.16) {
                Image(systemName: "hand.thumbsup")
                Image(systemName: "hand.thumbsup")
            }
        }
    }

    private func tint(_ v: Verdict) -> Color {
        switch v {
        case .down: return Theme.Color.ink
        case .up:   return Theme.Color.sage
        case .upUp: return Theme.Color.accent
        }
    }
}
