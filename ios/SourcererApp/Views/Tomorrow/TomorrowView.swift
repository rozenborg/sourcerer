import SwiftUI

/// Tomorrow's deck — staged for 06:30. Saved-but-unread items + 2 follow-ups
/// (PRODUCT_SPEC §6). Until the daily-build cron ships, this view surfaces
/// today's saves as a preview of tomorrow.
struct TomorrowView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var saved: [Article] = []
    @State private var loadError: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                PageBackground(atmosphere: .dawn)
                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .task { if saved.isEmpty { await load() } }
            .refreshable { await load() }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 22)
                .padding(.top, 8)

            etaCard
                .padding(.horizontal, 22)
                .padding(.top, 18)

            if let loadError {
                Text(loadError)
                    .font(Theme.Typography.body(13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 22)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionHeader("✓ your dive list · \(saved.count)", color: Theme.Color.sage)
                        .padding(.horizontal, 22)
                        .padding(.top, 18)
                        .padding(.bottom, 10)

                    if saved.isEmpty && !isLoading {
                        emptyState
                            .padding(.horizontal, 22)
                    } else {
                        ForEach(saved) { article in
                            NavigationLink(value: article) {
                                StagedRow(article: article, kind: .saved)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    sectionHeader("↪ follow-ups · staged at 06:30", color: Theme.Color.accent)
                        .padding(.horizontal, 22)
                        .padding(.top, 22)
                        .padding(.bottom, 10)
                    followUpsPlaceholder
                        .padding(.horizontal, 22)
                }
                .padding(.bottom, 30)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(tomorrowDayName()) · STAGED FOR 06:30")
                    .font(Theme.Typography.meta(10))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Color.stone300)
                Text("tomorrow's deck")
                    .font(Theme.Typography.display(28))
                    .kerning(-0.5)
                    .foregroundStyle(Theme.Color.ink)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("\(saved.count)")
                    .font(Theme.Typography.meta(22, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.Color.ink)
                Text("building")
                    .font(Theme.Typography.meta(11))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Color.stone300)
            }
        }
    }

    private var etaCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock")
                .font(.system(size: 16))
                .foregroundStyle(Theme.Color.inkSoft)
            Text("your dive list + items Sourcerer is watching · final pick at 06:30")
                .font(Theme.Typography.meta(10))
                .tracking(0.4)
                .foregroundStyle(Theme.Color.inkSoft)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.Color.stone100, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func sectionHeader(_ text: String, color: Color) -> some View {
        Text(text.uppercased())
            .font(Theme.Typography.meta(10, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(color)
    }

    private var emptyState: some View {
        Text("Swipe a card up to dive into it later and it'll appear here, staged with two follow-ups Sourcerer picks for you.")
            .font(Theme.Typography.serif(14).italic())
            .foregroundStyle(Theme.Color.inkSoft)
            .multilineTextAlignment(.leading)
            .padding(.vertical, 18)
    }

    private var followUpsPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sourcerer will pick two follow-ups overnight based on what you sparked today.")
                .font(Theme.Typography.serif(13).italic())
                .foregroundStyle(Theme.Color.stone300)
                .lineLimit(3)
            FlowLayout(spacing: 6) {
                ForEach(["AISI Q2 report", "Llama-4 update", "RLAIF survey", "Gemini eval refresh"], id: \.self) { t in
                    Text(t)
                        .font(Theme.Typography.meta(10))
                        .tracking(0.3)
                        .foregroundStyle(Theme.Color.stone300)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .overlay(
                            Capsule().stroke(Theme.Color.stone200, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                        )
                }
            }
        }
    }

    private func tomorrowDayName() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return f.string(from: date)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            saved = try await env.articles.listStarred(limit: 50).map { $0.0 }
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}

private struct StagedRow: View {
    enum Kind { case saved, followUp }
    let article: Article
    let kind: Kind

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .fill(article.topic.color)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(article.kindGlyph) \(article.sourceName?.uppercased() ?? article.sourceId.uppercased()) · \(article.readMinutes)m")
                    .font(Theme.Typography.meta(9))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Color.stone300)
                Text(article.title ?? "Untitled")
                    .font(Theme.Typography.body(13, weight: .medium))
                    .foregroundStyle(Theme.Color.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                if kind == .followUp {
                    Text("↪ because you sparked similar topics")
                        .font(Theme.Typography.meta(9).italic())
                        .tracking(0.4)
                        .foregroundStyle(Theme.Color.accentDark)
                }
            }
            Spacer()
            SparkStars(filled: 4, size: 11)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Theme.Color.stone100.frame(height: 1)
        }
    }
}
