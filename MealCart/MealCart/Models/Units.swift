import Foundation

/// How a unit can be combined with other units.
enum UnitKind: String, Codable {
    case volume   // base: teaspoons
    case weight   // base: ounces
    case count    // only combines with the exact same unit
}

enum MeasureUnit: String, Codable, CaseIterable {
    case tsp, tbsp, cup
    case oz, lb
    case each, clove, can, jar, package, bunch, slice

    var kind: UnitKind {
        switch self {
        case .tsp, .tbsp, .cup: return .volume
        case .oz, .lb: return .weight
        default: return .count
        }
    }

    /// Multiplier to convert this unit into its kind's base unit.
    var baseFactor: Double {
        switch self {
        case .tsp: return 1
        case .tbsp: return 3
        case .cup: return 48
        case .oz: return 1
        case .lb: return 16
        default: return 1
        }
    }

    func label(for amount: Double) -> String {
        let plural = amount > 1.0001
        switch self {
        case .tsp: return "tsp"
        case .tbsp: return "tbsp"
        case .cup: return plural ? "cups" : "cup"
        case .oz: return "oz"
        case .lb: return "lb"
        case .each: return ""
        case .clove: return plural ? "cloves" : "clove"
        case .can: return plural ? "cans" : "can"
        case .jar: return plural ? "jars" : "jar"
        case .package: return plural ? "packages" : "package"
        case .bunch: return plural ? "bunches" : "bunch"
        case .slice: return plural ? "slices" : "slice"
        }
    }
}

enum QuantityFormatter {
    private static let fractions: [(Double, String)] = [
        (0, ""), (1.0 / 8, "⅛"), (1.0 / 4, "¼"), (1.0 / 3, "⅓"),
        (1.0 / 2, "½"), (2.0 / 3, "⅔"), (3.0 / 4, "¾"), (1, "")
    ]

    /// Formats a quantity using kitchen-friendly fractions, e.g. 1.5 -> "1½".
    static func format(_ value: Double) -> String {
        guard value > 0 else { return "0" }
        var whole = Int(value.rounded(.down))
        let remainder = value - Double(whole)
        let nearest = fractions.min { abs($0.0 - remainder) < abs($1.0 - remainder) }!
        if nearest.0 == 1 { whole += 1 }
        let symbol = nearest.0 == 1 ? "" : nearest.1
        if whole == 0 { return symbol.isEmpty ? "⅛" : symbol }
        return "\(whole)\(symbol)"
    }

    /// Formats an amount stored in the base unit of `kind` into a readable string.
    static func describe(base: Double, kind: UnitKind, countUnit: MeasureUnit) -> String {
        switch kind {
        case .volume:
            if base >= 12 { return join(base / MeasureUnit.cup.baseFactor, .cup) }
            if base >= 3 { return join(base / MeasureUnit.tbsp.baseFactor, .tbsp) }
            return join(base, .tsp)
        case .weight:
            if base >= 16 { return join(base / MeasureUnit.lb.baseFactor, .lb) }
            return join(base, .oz)
        case .count:
            return join(base, countUnit)
        }
    }

    private static func join(_ amount: Double, _ unit: MeasureUnit) -> String {
        let label = unit.label(for: amount)
        let number = format(amount)
        return label.isEmpty ? number : "\(number) \(label)"
    }
}
