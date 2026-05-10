import Foundation

struct Deck: Identifiable, Codable, Hashable {
    let id: Int64
    let userId: UUID
    var name: String
    var description: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case createdAt = "created_at"
    }
}
