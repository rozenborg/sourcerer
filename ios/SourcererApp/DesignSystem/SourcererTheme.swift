import SwiftUI

/// Sourcerer design system — the visual language ported from the locked HTML/JSX
/// design (`window.SOURCERER`). Cool-stone surfaces, one primary accent
/// (deep indigo), jewel-tone topic chips for content personality, and glow
/// reserved for motion / milestone / magic moments only.
enum Theme {
    enum Color {
        // Cool-stone surfaces (the world)
        static let stone0   = SwiftUI.Color(red: 0.957, green: 0.965, blue: 0.980)  // #f4f6fa raised cards
        static let stone50  = SwiftUI.Color(red: 0.910, green: 0.925, blue: 0.949)  // #e8ecf2 page bg
        static let stone100 = SwiftUI.Color(red: 0.867, green: 0.886, blue: 0.922)  // #dde2eb raised
        static let stone200 = SwiftUI.Color(red: 0.769, green: 0.796, blue: 0.851)  // #c4cbd9 rule
        static let stone300 = SwiftUI.Color(red: 0.604, green: 0.639, blue: 0.710)  // #9aa3b5 mute
        static let inkSoft  = SwiftUI.Color(red: 0.247, green: 0.278, blue: 0.353)  // #3f475a
        static let ink      = SwiftUI.Color(red: 0.059, green: 0.078, blue: 0.149)  // #0f1426

        // Accent — deep indigo. The user's intention.
        static let accentTint = SwiftUI.Color(red: 0.894, green: 0.910, blue: 0.961)  // #e4e8f5
        static let accent     = SwiftUI.Color(red: 0.122, green: 0.165, blue: 0.369)  // #1f2a5e
        static let accentDark = SwiftUI.Color(red: 0.055, green: 0.086, blue: 0.290)  // #0e164a

        // Magic — chartreuse (only for system-acting moments on dark surfaces).
        static let chartreuse = SwiftUI.Color(red: 0.831, green: 1.000, blue: 0.078)  // #d4ff14

        // Positive
        static let sage = SwiftUI.Color(red: 0.290, green: 0.478, blue: 0.369)  // #4a7a5e

        // Dark surface family (deep mode, ticker, "Sourcerer noticed" cards)
        static let nightBg   = SwiftUI.Color(red: 0.039, green: 0.063, blue: 0.141)  // #0a1024
        static let nightSurf = SwiftUI.Color(red: 0.078, green: 0.102, blue: 0.180)  // #141a2e
        static let nightInk  = SwiftUI.Color(red: 0.902, green: 0.925, blue: 0.961)  // #e6ecf5
        static let nightSoft = SwiftUI.Color(red: 0.604, green: 0.651, blue: 0.761)  // #9aa6c2
        static let nightMute = SwiftUI.Color(red: 0.345, green: 0.384, blue: 0.471)  // #586278
        static let nightRule = SwiftUI.Color(red: 0.145, green: 0.169, blue: 0.247)  // #252b3f
    }

    /// Per-screen atmospheric tints — the orb's interior light leaking onto the page.
    enum Atmosphere {
        case calm        // utility screens (home, list, library, profile, recap)
        case dawn        // anticipatory (tomorrow, briefing, almost-done, onboarding)
        case celebration // trophies (today is done)
        case night       // deep mode
    }

    enum Typography {
        /// Editorial italic display — Fraunces analog via SwiftUI's serif design.
        static func display(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
            .system(size: size, weight: weight, design: .serif).italic()
        }

        /// Upright serif (for body in deep mode / pull-quotes).
        static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .serif)
        }

        /// Body — sans (Inter analog → SF).
        static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .default)
        }

        /// Ledger / meta — monospace, uppercase typically.
        static func meta(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .system(size: size, weight: weight, design: .monospaced)
        }
    }

    /// Shadow recipes — single cool-cast language. Never colored except the orb.
    enum Shadow {
        static func sm<V: View>(_ v: V) -> some View {
            v.shadow(color: SwiftUI.Color(red: 0.059, green: 0.078, blue: 0.149, opacity: 0.06),
                     radius: 4, x: 0, y: 2)
        }

        static func md<V: View>(_ v: V) -> some View {
            v.shadow(color: SwiftUI.Color(red: 0.059, green: 0.078, blue: 0.149, opacity: 0.20),
                     radius: 13, x: 0, y: 6)
        }

        static func lg<V: View>(_ v: V) -> some View {
            v.shadow(color: SwiftUI.Color(red: 0.059, green: 0.078, blue: 0.149, opacity: 0.28),
                     radius: 21, x: 0, y: 8)
        }
    }

    /// Glow recipes — used in four places only.
    /// Each is a SwiftUI shadow + color combo.
    enum Glow {
        /// Progress fill / active tab indicator. Cobalt-indigo motion light.
        static func progress<V: View>(_ v: V) -> some View {
            v.shadow(color: Color.accent.opacity(0.70), radius: 5)
        }

        /// Pulse dot on milestone toasts. Chartreuse system-acting light.
        static func pulseDot<V: View>(_ v: V) -> some View {
            v.shadow(color: Color.chartreuse.opacity(0.85), radius: 5)
        }

        /// Primary CTA halo. One per screen.
        static func cta<V: View>(_ v: V) -> some View {
            v.shadow(color: Color.accent.opacity(0.32), radius: 12)
                .shadow(color: SwiftUI.Color(red: 0.059, green: 0.078, blue: 0.149, opacity: 0.18),
                        radius: 7, y: 4)
        }

        /// Cursor in note input (micro-motion).
        static func cursor<V: View>(_ v: V) -> some View {
            v.shadow(color: Color.accent.opacity(0.95), radius: 4)
        }
    }
}
