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
