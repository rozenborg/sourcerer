import Foundation

enum SourceType: String, Codable, Hashable, CaseIterable {
    case rss
    case sitemap
    case podcast
    case youtube
    case scholarly
    case scholarlyRSS = "scholarly_rss"
    case scholarlyAuthors = "scholarly_authors"
    case unknown

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = SourceType(rawValue: raw) ?? .unknown
    }

    var displayName: String {
        switch self {
        case .rss, .sitemap: return "Article"
        case .podcast: return "Podcast"
        case .youtube: return "Video"
        case .scholarly, .scholarlyRSS: return "Scholarly"
        case .scholarlyAuthors: return "Watchlist"
        case .unknown: return "Source"
        }
    }
}
