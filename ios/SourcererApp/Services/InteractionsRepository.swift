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

/// The considered reaction signal (verdict + comment), separate from the fast
/// triage interactions. Written from the deck card and the detail view;
/// persisted to `article_ratings`.
protocol RatingsRepository {
    /// Quick thumb-tap: upsert just the verdict. The `note` column is omitted
    /// from the payload, so a quick re-tap never erases a comment written
    /// earlier (PostgREST leaves omitted columns untouched on upsert-update).
    func setVerdict(articleId: Int64, verdict: String) async throws

    /// Full feedback from the sheet: upsert verdict AND the comment. The comment
    /// is always written (a cleared comment becomes an empty string), so the
    /// sheet can remove a comment the user no longer wants.
    func setFeedback(articleId: Int64, verdict: String, comment: String?) async throws

    func rating(for articleId: Int64) async throws -> ArticleRating?

    /// Batch-load existing verdicts for a set of articles, so the deck can
    /// reflect what the user already rated. Returns articleId → verdict raw.
    func verdicts(forArticleIds ids: [Int64]) async throws -> [Int64: String]
}

final class SupabaseRatingsRepository: RatingsRepository {
    private let client: SupabaseClient
    private let userId: () -> UUID?

    init(client: SupabaseClient, userId: @escaping () -> UUID?) {
        self.client = client
        self.userId = userId
    }

    func setVerdict(articleId: Int64, verdict: String) async throws {
        guard let uid = userId() else { throw AuthRequired() }
        let now = ISO8601DateFormatter().string(from: Date())

        // No `note` field at all → it's absent from the upsert body, so on
        // ON CONFLICT DO UPDATE PostgREST never touches the column (a quick
        // re-tap preserves any existing comment), and on insert it defaults to
        // NULL. `stars` is likewise untouched, preserving legacy ratings.
        struct Row: Encodable {
            let user_id: UUID
            let article_id: Int64
            let verdict: String
            let rated_at: String
        }
        let row = Row(user_id: uid, article_id: articleId, verdict: verdict, rated_at: now)
        try await client
            .from("article_ratings")
            .upsert(row, onConflict: "user_id,article_id")
            .execute()
    }

    func setFeedback(articleId: Int64, verdict: String, comment: String?) async throws {
        guard let uid = userId() else { throw AuthRequired() }
        let now = ISO8601DateFormatter().string(from: Date())

        // `note` is ALWAYS present here (a cleared comment becomes ""), so the
        // sheet can overwrite or remove a comment. This is the deliberate-edit
        // path; the quick-tap `setVerdict` above is the preserve path.
        struct Row: Encodable {
            let user_id: UUID
            let article_id: Int64
            let verdict: String
            let note: String
            let rated_at: String
        }
        let row = Row(user_id: uid, article_id: articleId, verdict: verdict, note: comment ?? "", rated_at: now)
        try await client
            .from("article_ratings")
            .upsert(row, onConflict: "user_id,article_id")
            .execute()
    }

    func rating(for articleId: Int64) async throws -> ArticleRating? {
        guard let uid = userId() else { return nil }
        let rows: [ArticleRating] = try await client
            .from("article_ratings")
            .select("article_id, verdict, note, stars")
            .eq("user_id", value: uid)
            .eq("article_id", value: Int(articleId))
            .limit(1)
            .execute()
            .value
        return rows.first
    }

    func verdicts(forArticleIds ids: [Int64]) async throws -> [Int64: String] {
        guard let uid = userId(), !ids.isEmpty else { return [:] }
        struct Row: Decodable { let article_id: Int64; let verdict: String? }
        let rows: [Row] = try await client
            .from("article_ratings")
            .select("article_id, verdict")
            .eq("user_id", value: uid)
            .in("article_id", values: ids.map { Int($0) })
            .execute()
            .value
        var map: [Int64: String] = [:]
        for row in rows {
            if let v = row.verdict { map[row.article_id] = v }
        }
        return map
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
