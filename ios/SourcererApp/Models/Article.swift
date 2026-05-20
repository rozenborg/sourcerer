import Foundation

struct Article: Identifiable, Codable, Hashable {
    let id: Int64
    let url: String
    let title: String?
    let sourceId: String
    let sourceName: String?
    let sourceType: SourceType
    let publishedAt: Date?
    let fetchedAt: Date
    let summary: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case sourceId = "source_id"
        case sourceName = "source_name"
        case sourceType = "source_type"
        case publishedAt = "published_at"
        case fetchedAt = "fetched_at"
        case summary
        case imageUrl = "image_url"
    }
}
