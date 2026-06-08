import SwiftUI

/// Rate a piece you've engaged with: stars + an open-form note. Persisted to
/// `article_ratings`.
///
/// Preset reason chips were intentionally removed — the old set was guessed up
/// front and didn't match how the user actually thinks. The plan is to let
/// reason chips *emerge* from real notes later (the "unlock"); until then the
/// note field is where the signal lives.
struct RatingSheet: View {
    let article: Article
    /// Existing rating, if the user has rated this before (pre-fills the sheet).
    var existing: ArticleRating? = nil
    /// Caller persists the rating.
    let onSubmit: (_ stars: Int, _ note: String?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var stars: Int = 0
    @State private var note: String = ""

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    label("rate this")
                    Text(article.title ?? "Untitled")
                        .font(Theme.Typography.display(20))
                        .kerning(-0.2)
                        .foregroundStyle(Theme.Color.ink)

                    starsCard
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
        .onAppear {
            if let existing {
                stars = existing.stars
                note = existing.note ?? ""
            }
        }
    }

    private var starsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("stars")
            HStack {
                SparkStars(filled: stars, size: 30) { tapped in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        stars = tapped == stars ? 0 : tapped
                    }
                }
                Spacer()
                if stars > 0 {
                    Text(starsPhrase)
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

    private var starsPhrase: String {
        switch stars {
        case 1: return "skip"
        case 2: return "meh"
        case 3: return "decent"
        case 4: return "worth it"
        case 5: return "essential"
        default: return ""
        }
    }

    private var noteBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("note · optional")
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("What stood out? Why this rating? Write it however you think about it.")
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
                    .frame(minHeight: 100)
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
        Button {
            onSubmit(stars, note.isEmpty ? nil : note)
            dismiss()
        } label: {
            Text(stars > 0 ? "SAVE RATING" : "CLOSE")
                .font(Theme.Typography.meta(10, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(stars > 0 ? Theme.Color.accent : Theme.Color.stone300,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .modifier(CtaGlow(active: stars > 0))
        }
        .disabled(stars == 0 && note.isEmpty)
    }

    private func label(_ s: String) -> some View {
        Text(s.uppercased())
            .font(Theme.Typography.meta(10))
            .tracking(1.2)
            .foregroundStyle(Theme.Color.stone300)
    }
}

private struct CtaGlow: ViewModifier {
    var active: Bool = true
    func body(content: Content) -> some View {
        if active {
            content
                .shadow(color: Theme.Color.accent.opacity(0.32), radius: 12)
                .shadow(color: Color.black.opacity(0.18), radius: 7, y: 4)
        } else {
            content
        }
    }
}
