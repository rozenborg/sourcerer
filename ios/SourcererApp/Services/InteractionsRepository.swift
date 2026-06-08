import Foundation
import Supabase

enum InteractionAction: String {
    case pass   = "passed_at"
    case star   = "starred_at"
    case save   = "saved_at"
}

protocol InteractionsRepository {
    /// Set an action's timestamp. `meta` is merged into the row's `meta` jsonb
    /// (e.g. a light up/down rating from a left/right swipe, or sparks + note
    /// from the rating sheet). Pass nil to leave existing meta untouched.
    func setAction(_ action: InteractionAction, articleId: Int64, meta: [String: String]?) async throws
    func clearAction(_ action: InteractionAction, articleId: Int64) async throws
    func interaction(for articleId: Int64) async throws -> ArticleInteraction?
}

extension InteractionsRepository {
    /// Convenience for callers that don't attach rating metadata.
    func setAction(_ action: InteractionAction, articleId: Int64) async throws {
        try await setAction(action, articleId: articleId, meta: nil)
    }
}

final class SupabaseInteractionsRepository: InteractionsRepository {
    private let client: SupabaseClient
    private let userId: () -> UUID?

    init(client: SupabaseClient, userId: @escaping () -> UUID?) {
        self.client = client
        self.userId = userId
    }

    func setAction(_ action: InteractionAction, articleId: Int64, meta: [String: String]?) async throws {
        guard let uid = userId() else { throw AuthRequired() }
        let now = ISO8601DateFormatter().string(from: Date())

        // Upsert: insert if missing, update the targeted timestamp if present.
        // We send the full row so the upsert can succeed on first action.
        // Optional fields encode via encodeIfPresent — a nil here is omitted
        // from the payload, so PostgREST leaves that column unchanged (and
        // `meta` keeps its '{}' default on first insert).
        struct Row: Encodable {
            let user_id: UUID
            let article_id: Int64
            let passed_at: String?
            let starred_at: String?
            let saved_at: String?
            let meta: [String: String]?
        }
        let row = Row(
            user_id: uid,
            article_id: articleId,
            passed_at:  action == .pass ? now : nil,
            starred_at: action == .star ? now : nil,
            saved_at:   action == .save ? now : nil,
            meta: meta
        )
        try await client
            .from("article_interactions")
            .upsert(row, onConflict: "user_id,article_id")
            .execute()
    }

    func clearAction(_ action: InteractionAction, articleId: Int64) async throws {
        guard let uid = userId() else { throw AuthRequired() }
        // Set the targeted column to null. JSONEncoder elides Optional.none keys
        // entirely (which PostgREST treats as "leave unchanged"), so we use a
        // custom Encodable that explicitly emits `null` for the chosen column.
        let patch = NullColumnPatch(column: action.rawValue)
        try await client
            .from("article_interactions")
            .update(patch)
            .eq("user_id", value: uid)
            .eq("article_id", value: Int(articleId))
            .execute()
    }

    func interaction(for articleId: Int64) async throws -> ArticleInteraction? {
        guard let uid = userId() else { return nil }
        let rows: [ArticleInteraction] = try await client
            .from("article_interactions")
            .select()
            .eq("user_id", value: uid)
            .eq("article_id", value: Int(articleId))
            .limit(1)
            .execute()
            .value
        return rows.first
    }
}

// MARK: - Ratings

/// The considered rating signal (stars + note), separate from the fast triage
/// interactions. Written from the detail view; persisted to `article_ratings`.
protocol RatingsRepository {
    /// Upsert the current user's rating for an article. Re-rating overwrites.
    func setRating(articleId: Int64, stars: Int, note: String?) async throws
    func rating(for articleId: Int64) async throws -> ArticleRating?
}

final class SupabaseRatingsRepository: RatingsRepository {
    private let client: SupabaseClient
    private let userId: () -> UUID?

    init(client: SupabaseClient, userId: @escaping () -> UUID?) {
        self.client = client
        self.userId = userId
    }

    func setRating(articleId: Int64, stars: Int, note: String?) async throws {
        guard let uid = userId() else { throw AuthRequired() }
        let now = ISO8601DateFormatter().string(from: Date())

        struct Row: Encodable {
            let user_id: UUID
            let article_id: Int64
            let stars: Int
            let note: String?
            let rated_at: String
        }
        // `reasons` is omitted so the column keeps its '{}' default (reserved
        // for the future unlock). encodeIfPresent leaves `note` nil → SQL NULL.
        let row = Row(user_id: uid, article_id: articleId, stars: stars, note: note, rated_at: now)
        try await client
            .from("article_ratings")
            .upsert(row, onConflict: "user_id,article_id")
            .execute()
    }

    func rating(for articleId: Int64) async throws -> ArticleRating? {
        guard let uid = userId() else { return nil }
        let rows: [ArticleRating] = try await client
            .from("article_ratings")
            .select("article_id, stars, note, reasons")
            .eq("user_id", value: uid)
            .eq("article_id", value: Int(articleId))
            .limit(1)
            .execute()
            .value
        return rows.first
    }
}

struct AuthRequired: Error {}

/// Encodes as `{ "<column>": null }` — used to set a single column to null
/// in a PostgREST PATCH. Plain `Optional<String>.none` would encode as a
/// missing key, which PostgREST treats as "leave the column alone".
private struct NullColumnPatch: Encodable {
    let column: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        let key = DynamicKey(stringValue: column)!
        try container.encodeNil(forKey: key)
    }

    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
}
