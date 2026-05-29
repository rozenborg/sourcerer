import Foundation

struct ParsedSummary: Hashable {
    let prefixTag: String?
    let headline: String?
    let body: String
    /// Mollick-likeness score (0–20) when the source ran through the scholarly
    /// filter. Stripped out of headline/body so it doesn't displace real content.
    let mollickScore: Int?

    static func parse(_ raw: String?) -> ParsedSummary {
        guard let raw, !raw.isEmpty else {
            return ParsedSummary(prefixTag: nil, headline: nil, body: "", mollickScore: nil)
        }

        var working = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip the scholarly-fetcher Mollick-likeness prefix. The fetcher
        // prepends `_Mollick-likeness: NN/20 — reason_\n\n…` to scholarly
        // summaries (fetchers.py); without removing it the parser would
        // treat the rationale as the headline.
        let mollickScore = extractMollickScore(&working)

        var prefixTag: String? = nil
        if working.hasPrefix("[") {
            if let close = working.firstIndex(of: "]") {
                let tag = String(working[working.index(after: working.startIndex)..<close])
                    .trimmingCharacters(in: .whitespaces)
                prefixTag = tag.isEmpty ? nil : tag
                let after = working.index(after: close)
                working = String(working[after...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        var headline: String? = nil
        var body = working
        if let firstNewline = working.firstIndex(of: "\n") {
            let firstLine = String(working[..<firstNewline]).trimmingCharacters(in: .whitespaces)
            if !firstLine.isEmpty,
               !firstLine.hasPrefix("-"),
               !firstLine.hasPrefix("*") {
                headline = firstLine
                body = String(working[working.index(after: firstNewline)...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return ParsedSummary(prefixTag: prefixTag, headline: headline, body: body, mollickScore: mollickScore)
    }

    private static func extractMollickScore(_ text: inout String) -> Int? {
        guard text.hasPrefix("_Mollick-likeness:") else { return nil }
        // The prefix is one line ending at the next newline (or the next `_` if no newline).
        let endIdx: String.Index
        if let nl = text.firstIndex(of: "\n") {
            endIdx = nl
        } else {
            endIdx = text.endIndex
        }
        let line = String(text[..<endIdx])
        let rest = endIdx < text.endIndex ? String(text[text.index(after: endIdx)...]) : ""
        text = rest.trimmingCharacters(in: .whitespacesAndNewlines)

        // Parse "NN/20" out of the line.
        let pattern = #"(\d{1,2})\s*/\s*20"#
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let digits = match.split(separator: "/").first.map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
            return Int(digits)
        }
        return nil
    }
}
