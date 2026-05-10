import Foundation
import Supabase

protocol ArticleRepository {
    func listFeed(beforeFetchedAt cursor: Date?, limit: Int) async throws -> [Article]
    func listStarred(limit: Int) async throws -> [(Article, Date)]
    func listSaved(limit: Int) async throws -> [(Article, Date)]
    func search(query: String, limit: Int) async throws -> [Article]
    func byId(_ id: Int64) async throws -> Article?
}

final class SupabaseArticleRepository: ArticleRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) { self.client = client }

    /// Articles the current user has not yet acted on, ordered by fetched_at desc.
    /// Keyset pagination via fetched_at cursor.
    ///
    /// Reads from the `feed_articles` view (created in the iOS migration) which
    /// hides any article the current user already passed/starred/saved. The view
    /// is `security_invoker = true`, so `auth.uid()` resolves per request.
    func listFeed(beforeFetchedAt cursor: Date?, limit: Int) async throws -> [Article] {
        var query = client
            .from("feed_articles")
            .select()

        if let cursor {
            query = query.lt("fetched_at", value: cursor.iso8601)
        }

        let articles: [Article] = try await query
            .order("fetched_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return articles
    }

    func listStarred(limit: Int) async throws -> [(Article, Date)] {
        try await listByAction(column: "starred_at", limit: limit)
    }

    func listSaved(limit: Int) async throws -> [(Article, Date)] {
        try await listByAction(column: "saved_at", limit: limit)
    }

    private func listByAction(column: String, limit: Int) async throws -> [(Article, Date)] {
        struct Row: Decodable {
            let starred_at: Date?
            let saved_at: Date?
            let articles: Article
        }
        let rows: [Row] = try await client
            .from("article_interactions")
            .select("starred_at, saved_at, articles!inner(*)")
            .not(column, operator: .is, value: "null")
            .order(column, ascending: false)
            .limit(limit)
            .execute()
            .value

        return rows.compactMap { row in
            let date: Date? = (column == "starred_at") ? row.starred_at : row.saved_at
            guard let date else { return nil }
            return (row.articles, date)
        }
    }

    func search(query: String, limit: Int) async throws -> [Article] {
        let needle = "%\(query)%"
        let rows: [Article] = try await client
            .from("articles")
            .select()
            .or("title.ilike.\(needle),summary.ilike.\(needle)")
            .order("fetched_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return rows
    }

    func byId(_ id: Int64) async throws -> Article? {
        let rows: [Article] = try await client
            .from("articles")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return rows.first
    }
}

private extension Date {
    var iso8601: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: self)
    }
}
