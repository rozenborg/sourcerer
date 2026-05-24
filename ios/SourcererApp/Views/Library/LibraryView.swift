import SwiftUI

/// Library — decks of saved/starred content. Until user-curated decks ship
/// (PRODUCT_SPEC §5 full), this shows two default decks built from existing
/// interactions: Saved and Sparked.
struct LibraryView: View {
    @Environment(AppEnvironment.self) private var env

    enum Tab: String, CaseIterable {
        case decks, queue, rated, archive
    }

    @State private var tab: Tab = .decks
    @State private var savedRows: [(Article, Date)] = []
    @State private var sparkedRows: [(Article, Date)] = []
    @State private var loadError: String?

    private var savedCount: Int { savedRows.count }
    private var sparkedCount: Int { sparkedRows.count }

    var body: some View {
        NavigationStack {
            ZStack {
                PageBackground(atmosphere: .calm)
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 22)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    tabStrip
                        .padding(.horizontal, 22)
                    Divider().overlay(Theme.Color.stone200)
                    contentForTab
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(savedCount + sparkedCount) SAVED · \(deckCount) DECKS")
                    .font(Theme.Typography.meta(10))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Color.stone300)
                Text("library")
                    .font(Theme.Typography.display(28))
                    .kerning(-0.5)
                    .foregroundStyle(Theme.Color.ink)
            }
            Spacer()
            Button {
                // PRODUCT_SPEC §5: creating named decks lands in Phase 2.
            } label: {
                Text("+ NEW DECK")
                    .font(Theme.Typography.meta(10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.Color.ink, in: Capsule())
            }
        }
    }

    private var tabStrip: some View {
        HStack(spacing: 18) {
            ForEach(Tab.allCases, id: \.self) { t in
                let on = t == tab
                Button {
                    withAnimation(.easeInOut(duration: 0.12)) { tab = t }
                } label: {
                    HStack(spacing: 4) {
                        Text(t.rawValue.uppercased())
                            .font(Theme.Typography.meta(11, weight: on ? .bold : .medium))
                            .tracking(1)
                        if let sub = subForTab(t) {
                            Text("· \(sub)")
                                .font(Theme.Typography.meta(11))
                        }
                    }
                    .foregroundStyle(on ? Theme.Color.ink : Theme.Color.stone300)
                    .padding(.bottom, 8)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(on ? Theme.Color.accent : .clear)
                            .frame(height: 2)
                            .offset(y: 1)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private func subForTab(_ t: Tab) -> String? {
        switch t {
        case .queue: return "\(savedCount)"
        case .rated: return "\(sparkedCount)"
        default: return nil
        }
    }

    private var deckCount: Int {
        (savedCount > 0 ? 1 : 0) + (sparkedCount > 0 ? 1 : 0)
    }

    @ViewBuilder
    private var contentForTab: some View {
        switch tab {
        case .decks:
            decksList
        case .queue:
            articleList(rows: savedRows)
        case .rated:
            articleList(rows: sparkedRows)
        case .archive:
            archivePlaceholder
        }
    }

    private var decksList: some View {
        ScrollView {
            VStack(spacing: 14) {
                if savedRows.isEmpty && sparkedRows.isEmpty {
                    emptyState
                        .padding(.top, 40)
                }

                if !savedRows.isEmpty {
                    NavigationLink(value: DeckLink.saved) {
                        DeckTile(
                            name: "Saved",
                            count: savedCount,
                            dotColor: Theme.Color.accent,
                            updated: savedRows.first.map(updateLabel) ?? "—"
                        )
                    }
                    .buttonStyle(.plain)
                }

                if !sparkedRows.isEmpty {
                    NavigationLink(value: DeckLink.sparked) {
                        DeckTile(
                            name: "Sparked",
                            count: sparkedCount,
                            dotColor: Topic.research.color,
                            updated: sparkedRows.first.map(updateLabel) ?? "—"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    // Phase 2: lets the user create a named deck.
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("NEW DECK")
                            .font(Theme.Typography.meta(11, weight: .medium))
                            .tracking(0.6)
                    }
                    .foregroundStyle(Theme.Color.stone300)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.Color.stone200, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
        .navigationDestination(for: DeckLink.self) { link in
            switch link {
            case .saved:   DeckListing(title: "Saved", rows: savedRows)
            case .sparked: DeckListing(title: "Sparked", rows: sparkedRows)
            }
        }
    }

    private func articleList(rows: [(Article, Date)]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.0.id) { i, row in
                    NavigationLink(value: row.0) {
                        ListRowCard(article: row.0, index: i + 1, status: .saved)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 6)
        }
    }

    private var archivePlaceholder: some View {
        VStack {
            Spacer()
            Text("Archive lives here once items roll off the deck.")
                .font(Theme.Typography.serif(14).italic())
                .foregroundStyle(Theme.Color.stone300)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            OrbView(size: 56, halo: true)
            Text("No saves yet")
                .font(Theme.Typography.display(20))
                .foregroundStyle(Theme.Color.ink)
            Text("Save or spark a card and it'll land here.")
                .font(Theme.Typography.serif(14).italic())
                .foregroundStyle(Theme.Color.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }

    private func updateLabel(_ row: (Article, Date)) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: row.1, relativeTo: Date())
    }

    private func load() async {
        do {
            async let s = env.articles.listSaved(limit: 200)
            async let r = env.articles.listStarred(limit: 200)
            savedRows = try await s
            sparkedRows = try await r
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}

private enum DeckLink: Hashable {
    case saved, sparked
}

/// One deck "card" with two back-card peeks underneath (the bookshelf feel).
private struct DeckTile: View {
    let name: String
    let count: Int
    let dotColor: Color
    let updated: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            Theme.Color.stone200.opacity(0.6)
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .offset(x: 8, y: 6)

            Theme.Color.stone100
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .offset(x: 4, y: 3)

            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Circle().fill(dotColor).frame(width: 10, height: 10)
                    Text(name)
                        .font(Theme.Typography.serif(18, weight: .medium))
                        .kerning(-0.2)
                        .foregroundStyle(Theme.Color.ink)
                }
                Spacer(minLength: 0)
                HStack {
                    Text("\(count) cards · updated \(updated)")
                        .font(Theme.Typography.meta(10))
                        .tracking(0.5)
                        .foregroundStyle(Theme.Color.stone300)
                    Spacer()
                    Text("open →")
                        .font(Theme.Typography.meta(11, weight: .bold))
                        .foregroundStyle(Theme.Color.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 100)
            .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.Color.stone200, lineWidth: 1)
            )
        }
        .frame(height: 110)
    }
}

private struct DeckListing: View {
    let title: String
    let rows: [(Article, Date)]

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .calm)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.0.id) { i, row in
                        NavigationLink(value: row.0) {
                            ListRowCard(article: row.0, index: i + 1, status: .saved)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 6)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
