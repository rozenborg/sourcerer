import SwiftUI

/// Briefing — the orb commands. Audio briefing ships in PRODUCT_SPEC Phase 4;
/// until then this is the "no briefing yet — give 4★ ratings to seed
/// tomorrow's brief" surface.
struct BriefingView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var sparkedToday: [Article] = []
    @State private var loadError: String?

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .dawn)
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 22)
                    .padding(.top, 8)

                header
                    .padding(.horizontal, 22)
                    .padding(.top, 8)

                Spacer(minLength: 6)
                BriefingOrb(diameter: 210)
                Text("TAP TO SCRY")
                    .font(Theme.Typography.meta(10))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Color.stone300)
                    .padding(.top, 14)
                Spacer(minLength: 0)

                threadCard
                    .padding(.horizontal, 22)
                    .padding(.bottom, 18)
            }
        }
        .task { await load() }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Text("\(timeNow()) · \(stateLabel)")
                .font(Theme.Typography.meta(10))
                .tracking(1.2)
                .foregroundStyle(Theme.Color.stone300)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR BRIEFING · \(estimateMinutes()) MIN")
                .font(Theme.Typography.meta(10, weight: .bold))
                .tracking(2)
                .foregroundStyle(Theme.Color.accent)
            Text(headlineCopy)
                .font(Theme.Typography.display(28, weight: .light))
                .kerning(-0.5)
                .foregroundStyle(Theme.Color.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headlineCopy: String {
        if sparkedToday.isEmpty {
            return "No briefing yet — spark 4★ on a few cards to seed tomorrow's brief."
        }
        return "\(estimateMinutes()) minutes on the \(sparkedToday.count) cards you sparked."
    }

    private var stateLabel: String {
        sparkedToday.isEmpty ? "WAITING" : "READY"
    }

    private var threadCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THREADED FROM YOUR ★ 4+")
                .font(Theme.Typography.meta(9, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Theme.Color.accentDark)

            if sparkedToday.isEmpty {
                Text("Once you spark a few cards, the briefing script threads them together overnight and a short audio rundown lands here at 06:30.")
                    .font(Theme.Typography.serif(13).italic())
                    .foregroundStyle(Theme.Color.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(sparkedToday.prefix(4)) { article in
                        HStack(spacing: 8) {
                            Circle().fill(article.topic.color).frame(width: 6, height: 6)
                            Text(article.title ?? "Untitled")
                                .font(Theme.Typography.body(12))
                                .foregroundStyle(Theme.Color.ink)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.Color.stone200, lineWidth: 1)
        )
    }

    private func timeNow() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }

    private func estimateMinutes() -> Int {
        max(4, min(8, sparkedToday.count + 4))
    }

    private func load() async {
        do {
            // Briefing seeds from sparked-today; we have all-time starred
            // available, take the most recent few.
            let rows = try await env.articles.listStarred(limit: 6)
            sparkedToday = rows.map { $0.0 }
        } catch {
            loadError = error.localizedDescription
        }
    }
}
