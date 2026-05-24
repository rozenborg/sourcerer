import SwiftUI

/// Dense scannable list mode — v1 Ticker's energy in the v2 paper palette.
struct TodayListMode: View {
    let articles: [Article]
    let statusFor: (Article) -> RowStatus
    let onTap: (Article) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(articles.enumerated()), id: \.element.id) { i, article in
                    Button {
                        onTap(article)
                    } label: {
                        ListRowCard(article: article, index: i + 1, status: statusFor(article))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 30)
        }
    }
}
