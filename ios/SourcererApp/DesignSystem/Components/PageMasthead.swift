import SwiftUI

/// Orb + ledger date row + italic display masthead.
struct PageMasthead: View {
    let title: String
    var dayOfWeek: String? = nil
    var inboundCount: Int? = nil
    var orbSize: CGFloat = 30

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            OrbView(size: orbSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(ledgerLine)
                    .font(Theme.Typography.meta(10))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Color.stone300)
                Text(title)
                    .font(Theme.Typography.display(24))
                    .kerning(-0.4)
                    .foregroundStyle(Theme.Color.ink)
                    .lineLimit(1)
            }
        }
    }

    private var ledgerLine: String {
        let day = dayOfWeek ?? Self.currentDayName()
        if let n = inboundCount, n > 0 {
            return "\(day) · FROM \(n)"
        }
        return day.uppercased()
    }

    private static func currentDayName() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: Date()).uppercased()
    }
}
