import Foundation

enum Aisle: String, Codable, CaseIterable, Identifiable {
    case produce, meat, dairy, bakery, pantry, spices, frozen, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .produce: return "Produce"
        case .meat: return "Meat & Seafood"
        case .dairy: return "Dairy & Eggs"
        case .bakery: return "Bakery & Tortillas"
        case .pantry: return "Pantry"
        case .spices: return "Spices, Oils & Sauces"
        case .frozen: return "Frozen"
        case .other: return "Other"
        }
    }

    var symbol: String {
        switch self {
        case .produce: return "carrot"
        case .meat: return "fish"
        case .dairy: return "cup.and.saucer"
        case .bakery: return "birthday.cake"
        case .pantry: return "takeoutbag.and.cup.and.straw"
        case .spices: return "flame"
        case .frozen: return "snowflake"
        case .other: return "bag"
        }
    }
}

struct Ingredient: Codable, Hashable {
    var name: String
    var quantity: Double
    var unit: MeasureUnit
    var aisle: Aisle
    /// Optional override for what to type into a store's search box.
    var searchTerm: String? = nil

    var normalizedName: String { Ingredient.normalize(name) }

    static func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var amountText: String {
        QuantityFormatter.describe(base: quantity * unit.baseFactor, kind: unit.kind, countUnit: unit)
    }
}

struct Meal: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let summary: String
    let minutes: Int
    let servings: Int
    let tags: [String]
    let ingredients: [Ingredient]
    let steps: [String]
}

struct PlannedMeal: Identifiable, Codable, Hashable {
    var id: String { mealID }
    let mealID: String
    var servings: Int
}

struct FeedbackNote: Identifiable, Codable, Hashable {
    var id = UUID()
    var date = Date()
    var text: String
}
