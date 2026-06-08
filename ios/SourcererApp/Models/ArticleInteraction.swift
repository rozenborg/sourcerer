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

/// A considered rating: 1–5 stars + an optional open-form note. Captured from
/// the detail view and persisted to `article_ratings`. `reasons` is reserved
/// for the future "unlock" (notes → personalized chips) and stays empty today.
struct ArticleRating: Codable, Hashable {
    let articleId: Int64
    var stars: Int
    var note: String?
    var reasons: [String]

    init(articleId: Int64, stars: Int, note: String? = nil, reasons: [String] = []) {
        self.articleId = articleId
        self.stars = stars
        self.note = note
        self.reasons = reasons
    }

    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case stars
        case note
        case reasons
    }
}
