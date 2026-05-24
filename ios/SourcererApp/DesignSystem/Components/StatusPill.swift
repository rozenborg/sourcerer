import SwiftUI

enum RowStatus {
    case unread
    case saved
    case read
    case sparked
}

/// Per-row status indicator for the list view: unread dot, SAVED tag, or read check.
struct StatusPill: View {
    let status: RowStatus

    var body: some View {
        switch status {
        case .saved:
            Text("SAVED")
                .font(Theme.Typography.meta(9, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Theme.Color.accent, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        case .sparked:
            Image(systemName: "star.fill")
                .font(.system(size: 11))
                .foregroundStyle(Theme.Color.accent)
        case .read:
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.Color.stone300)
        case .unread:
            Circle()
                .fill(Theme.Color.accent)
                .frame(width: 9, height: 9)
        }
    }
}
