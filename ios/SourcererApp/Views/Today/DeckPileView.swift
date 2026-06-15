import SwiftUI

/// The visible card pile — top 3 cards rendered, top card swipeable. The
/// cards are now self-contained readers (see DeckCard), so the gesture model
/// splits by axis:
///   • horizontal pan on the card → ← skip / → save  (handled here)
///   • vertical pan inside the card → scroll the summary (handled by DeckCard)
///   • postpone / rate / share → footer controls on the card
///
/// The horizontal swipe is a `simultaneousGesture` that only reacts when the
/// pan is horizontally dominant, so it coexists with the inner ScrollView's
/// vertical scrolling.
struct DeckPileView: View {
    let articles: [Article]
    /// Total cards in today's deck (for the "no. 04 / NN" plate number).
    let total: Int

    let onSkip: (Article) -> Void            // ← not for me
    let onSave: (Article) -> Void            // → keep it
    let onPostpone: (Article) -> Void        // top-right "Later" (reshuffle deeper)
    let onOpen: (Article) -> Void            // tap title → focused detail
    let onVerdict: (Article, Verdict) -> Void   // footer thumbs → feedback
    let verdictFor: (Article) -> Verdict?    // persisted verdict for the card

    @State private var dragOffset: CGSize = .zero
    @State private var dragRotation: Double = 0
    /// Axis latched on the first significant move of a drag, so a curving pan
    /// can't flip between scrolling and swiping mid-gesture. nil = undecided.
    @State private var dragIsHorizontal: Bool? = nil

    private let flickX: CGFloat = 110

    var body: some View {
        if articles.isEmpty {
            emptyDoneState
        } else {
            pile
                .padding(.horizontal, 26)
                .padding(.top, 14)
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
                    selectedVerdict: verdictFor(article),
                    onOpen: { onOpen(article) },
                    onPostpone: { triggerPostpone(article: article) },
                    onVerdict: { v in onVerdict(article, v) }
                )
                .scaleEffect(scale(forDepth: depth))
                .rotationEffect(rotation(forDepth: depth, isTop: isTop), anchor: .bottom)
                .offset(isTop ? dragOffset : offset(forDepth: depth))
                .opacity(opacity(forDepth: depth))
                .overlay(swipeIntentOverlay(isTop: isTop, dragNorm: dragNorm))
                .zIndex(Double(visible.count - depth))
                .allowsHitTesting(isTop)
                .simultaneousGesture(isTop ? horizontalSwipe(article: article) : nil)
                .animation(.interactiveSpring(response: 0.32, dampingFraction: 0.78), value: dragOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 520)
    }

    /// Horizontal-dominant pan only — vertical pans fall through to the card's
    /// inner ScrollView. `simultaneousGesture` lets both observe the drag; this
    /// one simply ignores anything that isn't mostly sideways.
    private func horizontalSwipe(article: Article) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { v in
                // Latch the axis on the first significant sample; keep it for
                // the rest of the gesture so a curving pan can't switch modes.
                if dragIsHorizontal == nil {
                    dragIsHorizontal = abs(v.translation.width) > abs(v.translation.height)
                }
                guard dragIsHorizontal == true else { return }
                dragOffset = CGSize(width: v.translation.width, height: 0)
                dragRotation = Double(v.translation.width / 14)
            }
            .onEnded { v in
                let wasHorizontal = dragIsHorizontal == true
                dragIsHorizontal = nil
                guard wasHorizontal else { return }
                handleDragEnd(v, article: article)
            }
    }

    private var emptyDoneState: some View {
        VStack(spacing: 18) {
            OrbView(size: 72, halo: true)
            Text("today's deck is clear.")
                .font(Theme.Typography.display(30))
                .kerning(-0.6)
                .foregroundStyle(Theme.Color.ink)
            Text("You're caught up. Pull to refresh, or come back as new pieces land.")
                .font(Theme.Typography.serif(15).italic())
                .foregroundStyle(Theme.Color.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 60)
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

    // MARK: - Swipe intent overlay

    @ViewBuilder
    private func swipeIntentOverlay(isTop: Bool, dragNorm: Double) -> some View {
        if isTop && dragNorm > 0.08 {
            ZStack {
                if dragOffset.width < -20 {
                    intentBadge("SKIP", color: Theme.Color.stone300, side: .leading)
                } else if dragOffset.width > 20 {
                    intentBadge("SAVE", color: Theme.Color.sage, side: .trailing)
                }
            }
            .opacity(dragNorm)
        }
    }

    private enum SwipeSide { case leading, trailing }

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
        }
    }

    private func handleDragEnd(_ value: DragGesture.Value, article: Article) {
        let dx = value.translation.width
        if dx > flickX {
            triggerSave(article: article)
            return
        }
        if dx < -flickX {
            triggerSkip(article: article)
            return
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            dragOffset = .zero
            dragRotation = 0
        }
    }

    private func triggerSkip(article: Article) {
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: -600, height: 0)
            dragRotation = -12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onSkip(article)
            resetDrag()
        }
    }

    private func triggerSave(article: Article) {
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: 600, height: 0)
            dragRotation = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onSave(article)
            resetDrag()
        }
    }

    private func triggerPostpone(article: Article) {
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = CGSize(width: 0, height: -600)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onPostpone(article)
            resetDrag()
        }
    }

    private func resetDrag() {
        dragOffset = .zero
        dragRotation = 0
    }
}
