import Foundation

struct ArticleInteraction: Codable, Hashable {
    let userId: UUID
    let articleId: Int64
    var passedAt: Date?
    var starredAt: Date?
    var savedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case articleId = "article_id"
        case passedAt = "passed_at"
        case starredAt = "starred_at"
        case savedAt = "saved_at"
    }

    var isPassed: Bool { passedAt != nil }
    var isStarred: Bool { starredAt != nil }
    var isSaved: Bool { savedAt != nil }
    var isUnseen: Bool { passedAt == nil && starredAt == nil && savedAt == nil }
}

/// A reaction to a piece: a three-level thumbs `verdict` + an optional
/// open-form `note` (the comment). Persisted to `article_ratings`. The verdict
/// is the quick signal; the comment is the rich feedback we collect to
/// personalize the feed. `stars` is legacy (pre-thumbs ratings), read-only.
struct ArticleRating: Codable, Hashable {
    let articleId: Int64
    var verdict: String?
    var note: String?
    var stars: Int?

    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case verdict
        case note
        case stars
    }

    /// The typed verdict, if set and recognized.
    var verdictValue: Verdict? { verdict.flatMap(Verdict.init(rawValue:)) }
}

/// Three-level reaction: 👎 · 👍 · 👍👍. Raw values match the DB check
/// constraint on `article_ratings.verdict`.
enum Verdict: String, CaseIterable, Codable {
    case down = "down"
    case up = "up"
    case upUp = "up_up"

    /// Short phrase shown when a verdict is selected.
    var phrase: String {
        switch self {
        case .down: return "not for me"
        case .up:   return "worth it"
        case .upUp: return "loved it"
        }
    }
}
