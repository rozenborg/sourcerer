import SwiftUI

/// Profile — the long record. 12-week activity grid + milestone progress.
/// Real `daily_session` aggregates land in PRODUCT_SPEC Phase 2; until then
/// the grid is sparse-but-honest (filled from saves/sparks across days).
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var cellValues: [Int] = Array(repeating: 0, count: 12 * 7)
    @State private var totalCleared: Int = 0
    @State private var totalSparked: Int = 0
    @State private var totalSaved: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                PageBackground(atmosphere: .calm)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        StreakRibbon(streak: max(1, totalCleared / 14), cleared: totalCleared, total: max(totalCleared, 18))
                            .padding(.horizontal, -22)  // bleed to edges

                        header
                        recordGrid
                        milestonesBlock
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.Color.ink)
                    }
                }
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            OrbView(size: 48, halo: true)
            VStack(alignment: .leading, spacing: 2) {
                Text("MEMBER SINCE · JAN 2026")
                    .font(Theme.Typography.meta(10))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Color.stone300)
                Text("you")
                    .font(Theme.Typography.display(26))
                    .kerning(-0.4)
                    .foregroundStyle(Theme.Color.ink)
            }
            Spacer()
        }
    }

    private var recordGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR RECORD · 12 WEEKS")
                .font(Theme.Typography.meta(10))
                .tracking(1.5)
                .foregroundStyle(Theme.Color.stone300)
            HStack(spacing: 3) {
                ForEach(0..<12, id: \.self) { w in
                    VStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { d in
                            let idx = w * 7 + d
                            let v = cellValues.indices.contains(idx) ? cellValues[idx] : 0
                            let isToday = (w == 11 && d == 6)
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(cellColor(v))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    isToday ?
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .stroke(Theme.Color.ink, lineWidth: 2)
                                    : nil
                                )
                        }
                    }
                }
            }
            HStack {
                Text("MAR 1")
                    .font(Theme.Typography.meta(9))
                    .tracking(0.4)
                    .foregroundStyle(Theme.Color.stone300)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cellColor(i))
                            .frame(width: 10, height: 10)
                    }
                }
                Spacer()
                Text("TODAY")
                    .font(Theme.Typography.meta(9))
                    .tracking(0.4)
                    .foregroundStyle(Theme.Color.stone300)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.Color.stone200, lineWidth: 1)
        )
    }

    private func cellColor(_ v: Int) -> Color {
        switch v {
        case 0: return Theme.Color.stone200
        case 1: return Theme.Color.accent.opacity(0.25)
        case 2: return Theme.Color.accent.opacity(0.5)
        case 3: return Theme.Color.accent.opacity(0.75)
        default: return Theme.Color.accent
        }
    }

    private var milestonesBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PROGRESS")
                .font(Theme.Typography.meta(10))
                .tracking(1.5)
                .foregroundStyle(Theme.Color.stone300)

            milestoneRow("30-day morning streak", value: min(30, totalCleared / 14), of: 30, near: totalCleared >= 14 * 25)
            milestoneRow("1,000 items cleared", value: totalCleared, of: 1000, near: totalCleared >= 900)
            milestoneRow("50 sparked", value: totalSparked, of: 50, near: totalSparked >= 40)
            milestoneRow("Topics rated 4+", value: min(10, totalSaved), of: 10, sub: "reach 10 to unlock cross-topic synth", near: totalSaved >= 8)
        }
    }

    @ViewBuilder
    private func milestoneRow(_ name: String, value: Int, of: Int, sub: String? = nil, near: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(name)
                    .font(Theme.Typography.body(13))
                    .foregroundStyle(Theme.Color.ink)
                Spacer()
                Text("\(value) / \(of)")
                    .font(Theme.Typography.meta(10, weight: near ? .bold : .medium))
                    .tracking(0.4)
                    .monospacedDigit()
                    .foregroundStyle(near ? Theme.Color.accent : Theme.Color.stone300)
            }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.Color.stone200)
                    .frame(height: 4)
                GeometryReader { g in
                    Capsule()
                        .fill(near ? Theme.Color.accent : Theme.Color.ink)
                        .frame(width: max(0, g.size.width * min(1, Double(value) / Double(of))), height: 4)
                        .shadow(color: near ? Theme.Color.accent.opacity(0.7) : .clear, radius: near ? 5 : 0)
                }
                .frame(height: 4)
            }
            if let sub {
                Text(sub)
                    .font(Theme.Typography.meta(9))
                    .tracking(0.3)
                    .foregroundStyle(Theme.Color.stone300)
            }
        }
    }

    private func load() async {
        do {
            async let savedRows = env.articles.listSaved(limit: 500)
            async let sparkRows = env.articles.listStarred(limit: 500)
            let s = try await savedRows
            let r = try await sparkRows
            totalSaved = s.count
            totalSparked = r.count
            totalCleared = s.count + r.count

            cellValues = buildGrid(saved: s, sparked: r)
        } catch {
            // Visual still renders with placeholder zeros.
        }
    }

    /// Maps interactions across the past 12 weeks into 0–4 density values.
    private func buildGrid(saved: [(Article, Date)], sparked: [(Article, Date)]) -> [Int] {
        var grid = Array(repeating: 0, count: 12 * 7)
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // We render columns left→right oldest→newest; the bottom-right cell
        // is today. Row 0 of each column is 6 days before that column's anchor.
        for offset in 0..<(12 * 7) {
            let dayOffset = (12 * 7 - 1) - offset  // 0 = today, 83 = oldest
            guard let day = cal.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let next = cal.date(byAdding: .day, value: 1, to: day) ?? day
            let count = saved.filter { $0.1 >= day && $0.1 < next }.count
                + sparked.filter { $0.1 >= day && $0.1 < next }.count
            grid[offset] = min(4, count)
        }
        return grid
    }
}
