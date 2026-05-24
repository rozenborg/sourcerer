import SwiftUI

/// The 10-topic taxonomy that drives chip color, list rails, today's-shape
/// peaks, and briefing thread dots. Defined by the design's locked palette.
///
/// Until the backend tags articles with a `topic` column (PRODUCT_SPEC §12),
/// we derive a topic per-article via stable heuristics in `Article+Topic.swift`.
enum Topic: String, CaseIterable, Hashable {
    case research = "Research"
    case safety = "Safety"
    case policy = "Policy"
    case industry = "Industry"
    case interpret = "Interpret"
    case robotics = "Robotics"
    case biology = "Biology"
    case opinion = "Opinion"
    case product = "Product"
    case eval = "Eval"

    var label: String { rawValue.uppercased() }

    /// Solid jewel-tone fill colors. Each topic is one stable color, used in
    /// 4 places: chip background, list-view rail, today's-shape peak bar,
    /// briefing thread leader dot.
    var color: Color {
        switch self {
        case .research:  return Color(red: 0.227, green: 0.227, blue: 0.447)  // #3a3a72 indigo
        case .safety:    return Color(red: 0.631, green: 0.227, blue: 0.165)  // #a13a2a vermillion
        case .policy:    return Color(red: 0.710, green: 0.541, blue: 0.102)  // #b58a1a saffron
        case .industry:  return Color(red: 0.290, green: 0.314, blue: 0.376)  // #4a5060 graphite
        case .interpret: return Color(red: 0.173, green: 0.376, blue: 0.388)  // #2c6063 verdigris
        case .robotics:  return Color(red: 0.627, green: 0.400, blue: 0.259)  // #a06642 terra
        case .biology:   return Color(red: 0.184, green: 0.353, blue: 0.227)  // #2f5a3a emerald
        case .opinion:   return Color(red: 0.420, green: 0.353, blue: 0.267)  // #6b5a44 sepia
        case .product:   return Color(red: 0.369, green: 0.227, blue: 0.447)  // #5e3a72 amethyst
        case .eval:      return Color(red: 0.243, green: 0.290, blue: 0.494)  // #3e4a7e ink-blue
        }
    }
}
