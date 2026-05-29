import SwiftUI

/// The visible card pile — top 3 cards rendered, top card draggable. The
/// rotations communicate "tactile card pile"; the design says match the
/// *feel*, not the exact transforms.
struct DeckPileView: View {
    let articles: [Article]
    let sparkedIds: Set<Int64>
    let savedIds: Set<Int64>
    /// Total cards in today's deck (for the "no. 04 / 18" plate number).
    let total: Int

    let onPass: (Article) -> Void
    let onSpark: (Article) -> Void
    let onSave: (Article) -> Void
    let onOpen: (Article) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var dragRotation: Double = 0

    private let flickX: CGFloat = 110
    private let flickY: CGFloat = 110

    var body: some View {
        if articles.isEmpty {
            emptyDoneState
        } else {
            VStack(spacing: 0) {
                pile
                Spacer(minLength: 18)
                gestureHints
                    .padding(.horizontal, 26)
                    .padding(.bottom, 18)
            }
            .padding(.horizontal, 26)
            .padding(.top, 18)
        }
    }

    private var pile: some View {
        let visible = Array(articles.prefix(3))
        return ZStack {
            ForEach(Array(visible.enumerated().reversed()), id: \.element.id) { tuple in
                let depth = tuple.offset
                let article = tuple.element
                let isTop = depth == 0
                let dragNorm = isTop ? min(1, abs(dragOffset.width) / 220) : 0

                DeckCard(
                    article: article,
                    index: indexInDeck(article),
                    total: total,
                    promoted: savedIds.contains(article.id) || sparkedIds.contains(article.id)
                )
                .scaleEffect(scale(forDepth: depth))
                .rotationEffect(rotation(forDepth: depth, isTop: isTop), anchor: .bottom)
                .offset(isTop ? dragOffset : offset(forDepth: depth))
                .opacity(opacity(forDepth: depth))
                .overlay(swipeIntentOverlay(article: article, isTop: isTop, dragNorm: dragNorm))
                .zIndex(Double(visible.count - depth))
                .contentShape(Rectangle())
                .onTapGesture {
                    if isTop { onOpen(article) }
                }
                .gesture(
                    isTop ?
                    DragGesture()
                        .onChanged { v in
                            dragOffset = v.translation
                            dragRotation = Double(v.translation.width / 14)
                        }
                        .onEnded { v in handleDragEnd(v, article: article) }
                    : nil
                )
                .animation(.interactiveSpring(response: 0.32, dampingFraction: 0.78), value: dragOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 480)
    }

    private var emptyDoneState: some View {
        VStack(spacing: 18) {
            BriefingOrb(diameter: 140)
            Text("today is done.")
                .font(Theme.Typography.display(34))
                .kerning(-0.6)
                .foregroundStyle(Theme.Color.ink)
            Text("You cleared the deck. Come back tomorrow at 06:30 for a fresh one.")
                .font(Theme.Typography.serif(15).italic())
                .foregroundStyle(Theme.Color.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pile geometry

    private func scale(forDepth d: Int) -> CGFloat {
        switch d {
        case 0: return 1.0
        case 1: return 0.96
        default: return 0.93
        }
    }

    private func rotation(forDepth d: Int, isTop: Bool) -> Angle {
        if isTop { return .degrees(dragRotation + 0.3) }
        switch d {
        case 1: return .degrees(-1.2)
        case 2: return .degrees(2)
        default: return .zero
        }
    }

    private func offset(forDepth d: Int) -> CGSize {
        switch d {
        case 1: return CGSize(width: 0, height: 12)
        case 2: return CGSize(width: 0, height: 24)
        default: return .zero
        }
    }

    private func opacity(forDepth d: Int) -> Double {
        switch d {
        case 0: return 1.0
        case 1: return 0.85
        default: return 0.55
        }
    }

    private func indexInDeck(_ article: Article) -> Int {
        // Position in the original deck order — best-effort. Without per-deck
        // state we just show the position among remaining cards.
        (articles.firstIndex(where: { $0.id == article.id }) ?? 0) + 1
    }

    // MARK: - Swipe intent overlay

    @ViewBuilder
    private func swipeIntentOverlay(article: Article, isTop: Bool, dragNorm: Double) -> some View {
        if isTop && dragNorm > 0.08 {
            let direction = swipeDirection
            ZStack {
                switch direction {
                case .left:
                    intentBadge("SKIP", color: Theme.Color.stone300, side: .leading)
                case .right:
                    intentBadge("SAVE", color: Theme.Color.sage, side: .trailing)
                case .up:
                    intentBadge("DEEP", color: Theme.Color.accent, side: .top)
                case .none:
                    EmptyView()
                }
            }
            .opacity(dragNorm)
        }
    }

    private enum SwipeSide { case leading, trailing, top }

    @ViewBuilder
    private func intentBadge(_ text: String, color: Color, side: SwipeSide) -> some View {
        let label = Text(text)
            .font(Theme.Typography.meta(14, weight: .bold))
            .tracking(1.6)
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(color, lineWidth: 1.8)
            )

        switch side {
        case .leading:
            label.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                 .padding(20).rotationEffect(.degrees(-8))
        case .trailing:
            label.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                 .padding(20).rotationEffect(.degrees(8))
        case .top:
            label.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                 .padding(20)
        }
    }

    private enum SwipeDirection { case left, right, up, none }

    private var swipeDirection: SwipeDirection {
        let dx = dragOffset.width
        let dy = dragOffset.height
        if abs(dy) > abs(dx), dy < -20 { return .up }
        if dx < -20 { return .left }
        if dx > 20  { return .right }
        return .none
    }

    private func handleDragEnd(_ value: DragGesture.Value, article: Article) {
        let dx = value.translation.width
        let dy = value.translation.height

        // Vertical flick → deep / spark
        if dy < -flickY, abs(dy) > abs(dx) {
            triggerSpark(article: article)
            return
        }
        // Right flick → save
        if dx > flickX {
            triggerSave(article: article)
            return
        }
        // Left flick → skip
        if dx < -flickX {
            triggerSkip(article: article)
            return
        }
        // Snap back
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            dragOffset = .zero
            dragRotation = 0
        }
    }

    private func triggerSkip(article: Article) {
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: -600, height: dragOffset.height)
            dragRotation = -12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onPass(article)
            resetDrag()
        }
    }

    private func triggerSave(article: Article) {
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: 600, height: dragOffset.height)
            dragRotation = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onSave(article)
            resetDrag()
        }
    }

    private func triggerSpark(article: Article) {
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = CGSize(width: dragOffset.width, height: -600)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onSpark(article)
            resetDrag()
        }
    }

    private func resetDrag() {
        dragOffset = .zero
        dragRotation = 0
    }

    // MARK: - Gesture hints

    private var gestureHints: some View {
        HStack {
            Label {
                Text("skip").tracking(0.6)
            } icon: {
                Image(systemName: "arrow.left")
            }
            .font(Theme.Typography.meta(10))
            .foregroundStyle(Theme.Color.stone300)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                Text("tap · read").tracking(0.6)
            }
            .font(Theme.Typography.meta(10, weight: .bold))
            .foregroundStyle(Theme.Color.accent)

            Spacer()

            HStack(spacing: 6) {
                Text("save").tracking(0.6)
                Image(systemName: "arrow.right")
            }
            .font(Theme.Typography.meta(10, weight: .bold))
            .foregroundStyle(Theme.Color.sage)
        }
    }
}
