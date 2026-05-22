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

    func listFeed(beforeFetchedAt cursor: Date?, limit: Int) async throws -> [Article] { feed }
    func listStarred(limit: Int) async throws -> [(Article, Date)] { starred }
    func listSaved(limit: Int) async throws -> [(Article, Date)] { saved }
    func search(query: String, limit: Int) async throws -> [Article] {
        feed.filter { ($0.title ?? "").localizedCaseInsensitiveContains(query) }
    }
    func byId(_ id: Int64) async throws -> Article? { feed.first { $0.id == id } }
}

final class PreviewInteractionsRepository: InteractionsRepository {
    func setAction(_ action: InteractionAction, articleId: Int64) async throws {}
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
            id: 1,
            url: "https://example.com/post-1",
            title: "Why context windows are the new instruction sets",
            sourceId: "oneusefulthing",
            sourceName: "One Useful Thing",
            sourceType: .rss,
            publishedAt: Date().addingTimeInterval(-3600 * 6),
            fetchedAt: Date().addingTimeInterval(-3600),
            summary: """
            A short headline that sits above the bullets.

            - Context windows of 1M+ tokens change what you put *in* the prompt.
            - Most teams haven't updated their retrieval pipelines accordingly.
            - The bottleneck is moving from retrieval to ranking.
            """,
            imageUrl: nil
        ),
        Article(
            id: 2,
            url: "https://example.com/podcast-3",
            title: "Hard Fork — The agentic web is here",
            sourceId: "hardfork",
            sourceName: "Hard Fork",
            sourceType: .podcast,
            publishedAt: Date().addingTimeInterval(-3600 * 24),
            fetchedAt: Date().addingTimeInterval(-3600 * 2),
            summary: """
            Casey and Kevin debate where the agentic web is succeeding.

            - Real adoption is in narrow verticals (legal, support).
            - General-purpose browsing agents are still flaky.
            - The economics favor agents that own their own data plane.
            """,
            imageUrl: nil
        ),
        Article(
            id: 3,
            url: "https://www.youtube.com/watch?v=abc123",
            title: "Andrej Karpathy — How LLMs really learn",
            sourceId: "karpathy",
            sourceName: "Andrej Karpathy",
            sourceType: .youtube,
            publishedAt: Date().addingTimeInterval(-3600 * 36),
            fetchedAt: Date().addingTimeInterval(-3600 * 3),
            summary: """
            A lecture-style walkthrough of the training pipeline.

            - Data quality dominates architecture choice at scale.
            - Synthetic data has a sharp ceiling without verifier signals.
            - "RLHF is a coping mechanism for bad pretraining data."
            """,
            imageUrl: nil
        ),
        Article(
            id: 4,
            url: "https://arxiv.org/abs/2501.00001",
            title: "Mollick et al. — How students actually use ChatGPT for homework",
            sourceId: "arxiv-cs-cy",
            sourceName: "arXiv cs.CY",
            sourceType: .scholarlyRSS,
            publishedAt: Date().addingTimeInterval(-3600 * 48),
            fetchedAt: Date().addingTimeInterval(-3600 * 4),
            summary: """
            [Mollick-likeness 16/20] Field study of 312 undergrads using ChatGPT across a semester.

            - Students with structured prompts learn more, not less.
            - Verbatim copying drops sharply when teachers use AI in class.
            - The "AI will erode learning" framing isn't supported by the data.
            """,
            imageUrl: nil
        )
    ]
}
