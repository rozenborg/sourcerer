import Foundation

struct ParsedSummary: Hashable {
    let prefixTag: String?
    let headline: String?
    let body: String

    static func parse(_ raw: String?) -> ParsedSummary {
        guard let raw, !raw.isEmpty else {
            return ParsedSummary(prefixTag: nil, headline: nil, body: "")
        }

        var working = raw.trimmingCharacters(in: .whitespacesAndNewlines)

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

        return ParsedSummary(prefixTag: prefixTag, headline: headline, body: body)
    }
}
