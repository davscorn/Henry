import Foundation

/// One consolidated line on the shopping list.
struct ListItem: Identifiable, Hashable {
    /// Normalized ingredient name; stable across rebuilds so check-offs survive.
    let id: String
    let displayName: String
    let aisle: Aisle
    let amountText: String
    let mealNames: [String]
    let searchTerm: String
    let isPantry: Bool
}

/// Turns a week of planned meals into a de-duplicated, aisle-sorted shopping list.
///
/// Rules:
/// - Ingredients are merged by normalized name.
/// - Volumes (tsp/tbsp/cup) are summed together, as are weights (oz/lb).
/// - Count units (each, can, clove, …) only sum with the same unit.
/// - If one name ends up with incompatible units, they're shown joined: "1 cup + 1 can".
/// - Quantities are scaled by planned servings ÷ recipe servings.
/// - Anything in the pantry set is flagged `isPantry` instead of being dropped.
enum ListBuilder {
    private struct UnitKey: Hashable {
        let kind: UnitKind
        let countUnit: MeasureUnit?
    }

    private struct Accumulator {
        var displayName: String
        var aisle: Aisle
        var searchTerm: String
        var amounts: [UnitKey: Double] = [:]
        var unitOrder: [UnitKey] = []
        var meals: [String] = []
    }

    static func build(planned: [PlannedMeal], meals: [Meal], pantry: Set<String>) -> [ListItem] {
        let mealsByID = Dictionary(uniqueKeysWithValues: meals.map { ($0.id, $0) })
        var buckets: [String: Accumulator] = [:]
        var order: [String] = []

        for plan in planned {
            guard let meal = mealsByID[plan.mealID] else { continue }
            let scale = Double(max(plan.servings, 1)) / Double(max(meal.servings, 1))

            for ingredient in meal.ingredients {
                let key = ingredient.normalizedName
                var acc = buckets[key] ?? Accumulator(
                    displayName: ingredient.name.prefix(1).uppercased() + ingredient.name.dropFirst(),
                    aisle: ingredient.aisle,
                    searchTerm: ingredient.searchTerm ?? ingredient.name
                )
                if buckets[key] == nil { order.append(key) }

                let unitKey = UnitKey(
                    kind: ingredient.unit.kind,
                    countUnit: ingredient.unit.kind == .count ? ingredient.unit : nil
                )
                if acc.amounts[unitKey] == nil { acc.unitOrder.append(unitKey) }
                acc.amounts[unitKey, default: 0] += ingredient.quantity * ingredient.unit.baseFactor * scale
                if !acc.meals.contains(meal.name) { acc.meals.append(meal.name) }
                buckets[key] = acc
            }
        }

        let items = order.compactMap { key -> ListItem? in
            guard let acc = buckets[key] else { return nil }
            let amount = acc.unitOrder.map { unitKey in
                QuantityFormatter.describe(
                    base: acc.amounts[unitKey] ?? 0,
                    kind: unitKey.kind,
                    countUnit: unitKey.countUnit ?? .each
                )
            }.joined(separator: " + ")
            return ListItem(
                id: key,
                displayName: acc.displayName,
                aisle: acc.aisle,
                amountText: amount,
                mealNames: acc.meals,
                searchTerm: acc.searchTerm,
                isPantry: pantry.contains(key)
            )
        }

        let aisleOrder = Dictionary(uniqueKeysWithValues: Aisle.allCases.enumerated().map { ($0.element, $0.offset) })
        return items.sorted {
            let a = aisleOrder[$0.aisle] ?? 0, b = aisleOrder[$1.aisle] ?? 0
            return a != b ? a < b : $0.displayName < $1.displayName
        }
    }

    /// Plain-text version of the list for sharing / pasting into Notes.
    static func plainText(items: [ListItem], extras: [String]) -> String {
        var lines: [String] = ["MealCart shopping list", ""]
        let needed = items.filter { !$0.isPantry }
        for aisle in Aisle.allCases {
            let inAisle = needed.filter { $0.aisle == aisle }
            guard !inAisle.isEmpty else { continue }
            lines.append(aisle.title.uppercased())
            lines += inAisle.map { "☐ \($0.displayName) — \($0.amountText)" }
            lines.append("")
        }
        if !extras.isEmpty {
            lines.append("EXTRAS")
            lines += extras.map { "☐ \($0)" }
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
