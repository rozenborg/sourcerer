import Testing
@testable import SourcererApp

struct ParsedSummaryTests {

    // MARK: empty / nil inputs

    @Test func nilInputProducesEmpty() {
        let result = ParsedSummary.parse(nil)
        #expect(result.prefixTag == nil)
        #expect(result.headline == nil)
        #expect(result.body == "")
    }

    @Test func emptyStringProducesEmpty() {
        let result = ParsedSummary.parse("")
        #expect(result.prefixTag == nil)
        #expect(result.headline == nil)
        #expect(result.body == "")
    }

    @Test func whitespaceOnlyTrimsToEmpty() {
        let result = ParsedSummary.parse("   \n\n   ")
        #expect(result.prefixTag == nil)
        #expect(result.headline == nil)
        #expect(result.body == "")
    }

    // MARK: prefix tag extraction

    @Test(arguments: [
        ("[Paper] body", "Paper"),
        ("[  Paper  ] body", "Paper"),
        ("[Tag with spaces] body", "Tag with spaces"),
        ("[Lenny] interview with...", "Lenny"),
    ])
    func extractsAndTrimsPrefixTag(input: String, expectedTag: String) {
        let result = ParsedSummary.parse(input)
        #expect(result.prefixTag == expectedTag)
    }

    @Test func emptyBracketsProduceNoTag() {
        let result = ParsedSummary.parse("[] body")
        #expect(result.prefixTag == nil)
        #expect(result.body == "body")
    }

    @Test func whitespaceOnlyBracketsProduceNoTag() {
        let result = ParsedSummary.parse("[   ] body")
        #expect(result.prefixTag == nil)
        #expect(result.body == "body")
    }

    @Test func unclosedBracketLeavesInputAsBody() {
        let result = ParsedSummary.parse("[unclosed body text")
        #expect(result.prefixTag == nil)
        #expect(result.headline == nil)
        #expect(result.body == "[unclosed body text")
    }

    // MARK: headline / body split

    @Test func headlineAndBodyAcrossNewline() {
        let result = ParsedSummary.parse("Headline\nBody text")
        #expect(result.prefixTag == nil)
        #expect(result.headline == "Headline")
        #expect(result.body == "Body text")
    }

    @Test func singleLineWithNoNewlineIsBodyOnly() {
        let result = ParsedSummary.parse("Just one line.")
        #expect(result.prefixTag == nil)
        #expect(result.headline == nil)
        #expect(result.body == "Just one line.")
    }

    @Test func tagPlusHeadlinePlusBody() {
        let result = ParsedSummary.parse("[Paper] Title here\nBody text follows")
        #expect(result.prefixTag == "Paper")
        #expect(result.headline == "Title here")
        #expect(result.body == "Body text follows")
    }

    @Test func tagWithNewlineImmediatelyAfterHasNoHeadline() {
        // "[Tag]\nbody" — after stripping the tag the working string trims
        // to just "body" (no newline left), so headline stays nil.
        let result = ParsedSummary.parse("[Paper]\nBody only")
        #expect(result.prefixTag == "Paper")
        #expect(result.headline == nil)
        #expect(result.body == "Body only")
    }

    @Test func multiParagraphBodyPreservesInnerNewlines() {
        let result = ParsedSummary.parse("[Paper] Title\nParagraph one.\n\nParagraph two.")
        #expect(result.prefixTag == "Paper")
        #expect(result.headline == "Title")
        #expect(result.body == "Paragraph one.\n\nParagraph two.")
    }

    // MARK: list-marker guard — first line starting with - or * isn't a headline

    @Test(arguments: ["- list item\nmore", "* list item\nmore"])
    func listMarkerFirstLineIsNotHeadline(input: String) {
        let result = ParsedSummary.parse(input)
        #expect(result.prefixTag == nil)
        #expect(result.headline == nil)
        #expect(result.body == input)
    }

    @Test func tagThenListItemHasNoHeadline() {
        let result = ParsedSummary.parse("[Paper] - bullet one\n- bullet two")
        #expect(result.prefixTag == "Paper")
        #expect(result.headline == nil)
        #expect(result.body == "- bullet one\n- bullet two")
    }

    // MARK: leading whitespace handling

    @Test func leadingWhitespaceIsStrippedBeforeParsing() {
        let result = ParsedSummary.parse("   \n  [Paper] Title\nBody  ")
        #expect(result.prefixTag == "Paper")
        #expect(result.headline == "Title")
        #expect(result.body == "Body")
    }
}
