import Foundation

extension Article {
    /// Best-guess Topic for this article until the ingest pipeline tags articles
    /// (PRODUCT_SPEC §12). Uses obvious source/type heuristics first, then a
    /// stable hash of `sourceId` so each source falls into one consistent topic.
    var topic: Topic {
        // High-signal overrides
        if let name = sourceName?.lowercased() {
            if name.contains("anthropic") { return .safety }
            if name.contains("openai") { return .industry }
            if name.contains("lesswrong") || name.contains("worry about the vase") { return .safety }
            if name.contains("dwarkesh") || name.contains("hard fork") || name.contains("lex") { return .opinion }
            if name.contains("stratechery") || name.contains("ben thompson") { return .industry }
            if name.contains("verge") || name.contains("reuters") || name.contains("bloomberg") { return .industry }
            if name.contains("two minute papers") || name.contains("karpathy") { return .opinion }
            if name.contains("arxiv") {
                if name.contains("cs.cy") { return .policy }
                if name.contains("cs.hc") { return .product }
                return .research
            }
            if name.contains("nber") { return .policy }
            if name.contains("nature") || name.contains("biorxiv") || name.contains("protein") { return .biology }
        }

        switch sourceType {
        case .scholarly, .scholarlyAuthors:
            return .research
        case .scholarlyRSS:
            return .research
        case .podcast:
            return .opinion
        case .youtube:
            return .opinion
        case .rss, .sitemap, .unknown:
            // Stable per-source fallback so the same feed always carries the
            // same color. FNV-1a is small, deterministic, and good enough.
            let topics = Topic.allCases
            var h: UInt64 = 0xcbf29ce484222325
            for byte in sourceId.utf8 {
                h ^= UInt64(byte)
                h = h &* 0x100000001b3
            }
            return topics[Int(h % UInt64(topics.count))]
        }
    }

    /// Estimated read time in minutes — used in the meta row + ribbon math.
    /// Falls back to a per-kind sane default when summary is missing.
    var readMinutes: Int {
        if let body = summary, !body.isEmpty {
            let words = body.split { $0.isWhitespace }.count
            return max(1, words / 220)
        }
        switch sourceType {
        case .podcast:  return 35
        case .youtube:  return 8
        case .scholarly, .scholarlyRSS, .scholarlyAuthors: return 12
        default:        return 4
        }
    }

    /// One-glyph kind marker (mirrors `sxKindGlyph` in the design tokens).
    var kindGlyph: String {
        switch sourceType {
        case .scholarly, .scholarlyRSS, .scholarlyAuthors: return "§"
        case .podcast: return "♪"
        case .youtube: return "▶"
        case .rss, .sitemap: return "¶"
        case .unknown: return "◆"
        }
    }

    /// Short ledger label for the kind (PAPER · BLOG · etc).
    var kindLabel: String {
        switch sourceType {
        case .scholarly, .scholarlyAuthors: return "PAPER"
        case .scholarlyRSS: return "PAPER"
        case .podcast: return "PODCAST"
        case .youtube: return "VIDEO"
        case .rss, .sitemap: return "BLOG"
        case .unknown: return "POST"
        }
    }
}
