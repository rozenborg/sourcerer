import Foundation
import Supabase

/// Minimal client used solely for SwiftUI #Preview blocks; never makes network calls
/// in normal preview rendering paths because the previews use mock repositories.
enum PreviewSupabase {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://example.supabase.co")!,
        supabaseKey: "preview-anon-key"
    )
}

final class PreviewArticleRepository: ArticleRepository {
    var feed: [Article]
    var starred: [(Article, Date)]
    var saved: [(Article, Date)]

    init(
        feed: [Article] = MockData.articles,
        starred: [(Article, Date)] = MockData.articles.prefix(2).map { ($0, Date()) },
        saved: [(Article, Date)] = MockData.articles.suffix(2).map { ($0, Date()) }
    ) {
        self.feed = feed
        self.starred = starred
        self.saved = saved
    }

    func listFeed(beforeFetchedAt cursor: Date?, since: Date?, limit: Int) async throws -> [Article] { feed }
    func listStarred(limit: Int) async throws -> [(Article, Date)] { starred }
    func listSaved(limit: Int) async throws -> [(Article, Date)] { saved }
    func search(query: String, limit: Int) async throws -> [Article] {
        feed.filter { ($0.title ?? "").localizedCaseInsensitiveContains(query) }
    }
    func byId(_ id: Int64) async throws -> Article? { feed.first { $0.id == id } }
}

final class PreviewInteractionsRepository: InteractionsRepository {
    func setAction(_ action: InteractionAction, articleId: Int64, meta: [String: String]?) async throws {}
    func clearAction(_ action: InteractionAction, articleId: Int64) async throws {}
    func interaction(for articleId: Int64) async throws -> ArticleInteraction? { nil }
}

@MainActor
extension AppEnvironment {
    /// Construct an environment backed by in-memory fakes — for SwiftUI Previews.
    static func preview(
        articles: ArticleRepository = PreviewArticleRepository(),
        interactions: InteractionsRepository = PreviewInteractionsRepository()
    ) -> AppEnvironment {
        let client = PreviewSupabase.client
        return AppEnvironment(
            supabase: client,
            auth: AuthService(client: client),
            articles: articles,
            interactions: interactions
        )
    }
}

enum MockData {
    static let articles: [Article] = [
        Article(
            id: 1, url: "https://arxiv.org/abs/2509.00001",
            title: "Mixture-of-Recursions beats depth scaling on long-horizon reasoning",
            sourceId: "arxiv", sourceName: "arXiv", sourceType: .scholarly,
            publishedAt: Date().addingTimeInterval(-3600 * 6), fetchedAt: Date().addingTimeInterval(-3600),
            summary: """
            [Sato, Wei, Lin et al.]
            A recursive transformer routes tokens through a shared block N times before emitting — matching a 2× deeper model at 0.6× the compute on GSM-Hard and ARC-AGI-v2.

            - Trained 1.4B params, evaluated against a 2.8B baseline
            - Routing learned end-to-end, no MoE-style aux loss
            - Wall-clock advantage holds out to 32k context
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 2, url: "https://anthropic.com/blog/long-horizon-agents",
            title: "On the surprising stability of long-horizon agents",
            sourceId: "anthropic", sourceName: "Anthropic", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 8), fetchedAt: Date().addingTimeInterval(-3600 * 2),
            summary: """
            Alignment team
            Six-hour coding agents diverge less than expected. The mechanism appears to be self-correction at task transitions, not in-step reasoning. Reframes where to invest agent-eval effort.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 3, url: "https://reuters.com/eu-ai-act-phase-2",
            title: "EU AI Act enters second phase — GPAI obligations land Friday",
            sourceId: "reuters", sourceName: "Reuters", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 14), fetchedAt: Date().addingTimeInterval(-3600 * 3),
            summary: """
            M. Bertrand
            Foundation-model providers must publish training-data summaries and standardized red-team reports. Enforcement begins in 90 days. Compliance teams will feel this.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 4, url: "https://dwarkesh.com/protein-design",
            title: "A two-hour conversation on the next decade of protein design",
            sourceId: "dwarkesh", sourceName: "Dwarkesh Podcast", sourceType: .podcast,
            publishedAt: Date().addingTimeInterval(-3600 * 30), fetchedAt: Date().addingTimeInterval(-3600 * 5),
            summary: """
            Wide-ranging interview covering structure prediction, generative design, wet-lab feedback loops, and what comes after AlphaFold.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 5, url: "https://arxiv.org/abs/2509.00002",
            title: "Sparse-autoencoder features as a debugging tool for jailbreaks",
            sourceId: "arxiv", sourceName: "arXiv", sourceType: .scholarly,
            publishedAt: Date().addingTimeInterval(-3600 * 34), fetchedAt: Date().addingTimeInterval(-3600 * 6),
            summary: """
            Park, Okafor, Reddy
            The authors localize jailbreak success to a small set of polysemantic features. Ablating ~40 features removes ~70% of attacks with minimal capability loss.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 6, url: "https://stratechery.com/copilot-pricing",
            title: "Why the Copilot pricing pivot matters more than the feature list",
            sourceId: "stratechery", sourceName: "Stratechery", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 12), fetchedAt: Date().addingTimeInterval(-3600 * 7),
            summary: """
            Ben Thompson
            Unbundling Copilot from per-seat into consumption tiers is the real story this week — and the canary for how every enterprise SaaS will price AI.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 7, url: "https://twitter.com/karpathy/status/1",
            title: "Re-reading 'The Bitter Lesson' in 2026",
            sourceId: "x", sourceName: "X", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 16), fetchedAt: Date().addingTimeInterval(-3600 * 8),
            summary: """
            @karpathy
            A short thread on what scaling-pilled and scaling-skeptical readers each get wrong about Sutton's essay a decade later.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 8, url: "https://youtube.com/watch?v=ab",
            title: "Diffusion models are designing antibodies now — and it works",
            sourceId: "two-minute-papers", sourceName: "Two Minute Papers", sourceType: .youtube,
            publishedAt: Date().addingTimeInterval(-3600 * 22), fetchedAt: Date().addingTimeInterval(-3600 * 9),
            summary: """
            Walkthrough of a Nature paper using a small diffusion model to propose binders. Wet-lab validation rate ~3× the rational-design baseline.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 9, url: "https://theverge.com/apple-pcc-eu",
            title: "Apple Intelligence ships private-cloud-compute in the EU",
            sourceId: "verge", sourceName: "The Verge", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 18), fetchedAt: Date().addingTimeInterval(-3600 * 10),
            summary: """
            A. Robertson
            The on-device-plus-PCC architecture lands 14 months after US launch. Auditability tooling for security researchers ships in the same update.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 10, url: "https://arxiv.org/abs/2509.00003",
            title: "Long-context retrieval without RAG via hidden-state replay",
            sourceId: "arxiv", sourceName: "arXiv", sourceType: .scholarly,
            publishedAt: Date().addingTimeInterval(-3600 * 36), fetchedAt: Date().addingTimeInterval(-3600 * 11),
            summary: """
            Iyer, Brennan, Lu
            Instead of retrieving text chunks, the model caches and replays the hidden states of prior context. Matches RAG at 200k tokens with simpler infra.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 11, url: "https://thezvi.substack.com/p/ai-74",
            title: "AI #74: Quiet drift in capability evals",
            sourceId: "thezvi", sourceName: "Don't Worry About the Vase", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 24), fetchedAt: Date().addingTimeInterval(-3600 * 12),
            summary: """
            Zvi Mowshowitz
            Weekly roundup. This week's through-line: capability evals are quietly drifting upward across labs and the public reporting hasn't caught up.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        ),
        Article(
            id: 12, url: "https://reddit.com/r/ML/scaling-laws",
            title: "[D] Are scaling laws dead? A 2026 retrospective",
            sourceId: "reddit-ml", sourceName: "r/MachineLearning", sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 38), fetchedAt: Date().addingTimeInterval(-3600 * 13),
            summary: """
            u/grad_descent
            Thoughtful discussion thread with several authors of original scaling-law papers chiming in. Verdict: not dead, but mis-stated for years.
            """,
            cardTeaser: nil,
            storedReadMinutes: nil,
            imageUrl: nil
        )
    ]
}
