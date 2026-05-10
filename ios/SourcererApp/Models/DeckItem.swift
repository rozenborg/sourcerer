import Foundation

struct DeckItem: Codable, Hashable {
    let deckId: Int64
    let articleId: Int64
    let addedAt: Date
    var position: Int?
    var note: String?

    enum CodingKeys: String, CodingKey {
        case deckId = "deck_id"
        case articleId = "article_id"
        case addedAt = "added_at"
        case position
        case note
    }
}
