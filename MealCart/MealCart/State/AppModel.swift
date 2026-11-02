import Foundation
import SwiftUI

/// All app state. Persisted as one JSON blob in UserDefaults — no accounts, no network.
final class AppModel: ObservableObject {
    private struct Snapshot: Codable {
        var planned: [PlannedMeal]
        var checked: Set<String>
        var pantry: Set<String>
        var store: StoreChoice
        var extras: [String]
        var notes: [FeedbackNote]
    }

    static let defaultPantry: Set<String> = ["salt", "black pepper", "olive oil", "vegetable oil"]
    private static let storageKey = "mealcart.state.v1"

    let meals: [Meal] = MealLibrary.all

    @Published var planned: [PlannedMeal] = [] { didSet { save() } }
    @Published var checked: Set<String> = [] { didSet { save() } }
    @Published var pantry: Set<String> = AppModel.defaultPantry { didSet { save() } }
    @Published var store: StoreChoice = .instacartAldi { didSet { save() } }
    @Published var extras: [String] = [] { didSet { save() } }
    @Published var notes: [FeedbackNote] = [] { didSet { save() } }

    private var isLoading = false
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: Plan

    func isPlanned(_ meal: Meal) -> Bool {
        planned.contains { $0.mealID == meal.id }
    }

    func togglePlanned(_ meal: Meal) {
        if let index = planned.firstIndex(where: { $0.mealID == meal.id }) {
            planned.remove(at: index)
        } else {
            planned.append(PlannedMeal(mealID: meal.id, servings: meal.servings))
        }
    }

    func setServings(_ servings: Int, for mealID: String) {
        guard let index = planned.firstIndex(where: { $0.mealID == mealID }) else { return }
        planned[index].servings = min(max(servings, 1), 16)
    }

    func removePlanned(at offsets: IndexSet) {
        planned.remove(atOffsets: offsets)
    }

    func movePlanned(from source: IndexSet, to destination: Int) {
        planned.move(fromOffsets: source, toOffset: destination)
    }

    func clearWeek() {
        planned = []
        checked = []
    }

    func meal(for plan: PlannedMeal) -> Meal? {
        meals.first { $0.id == plan.mealID }
    }

    // MARK: List

    var listItems: [ListItem] {
        ListBuilder.build(planned: planned, meals: meals, pantry: pantry)
    }

    var remainingCount: Int {
        let needed = listItems.filter { !$0.isPantry && !checked.contains($0.id) }.count
        let extrasLeft = extras.filter { !checked.contains(extraKey($0)) }.count
        return needed + extrasLeft
    }

    func toggleChecked(_ key: String) {
        if checked.contains(key) { checked.remove(key) } else { checked.insert(key) }
    }

    func uncheckAll() { checked = [] }

    func extraKey(_ extra: String) -> String { "extra:" + Ingredient.normalize(extra) }

    func addExtra(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !extras.contains(where: { Ingredient.normalize($0) == Ingredient.normalize(trimmed) })
        else { return }
        extras.append(trimmed)
    }

    func removeExtras(at offsets: IndexSet) {
        for index in offsets { checked.remove(extraKey(extras[index])) }
        extras.remove(atOffsets: offsets)
    }

    // MARK: Pantry

    func addToPantry(_ name: String) {
        let key = Ingredient.normalize(name)
        guard !key.isEmpty else { return }
        pantry.insert(key)
    }

    func removeFromPantry(_ name: String) {
        pantry.remove(Ingredient.normalize(name))
    }

    // MARK: Feedback

    func addNote(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        notes.insert(FeedbackNote(text: trimmed), at: 0)
    }

    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    var notesExport: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return notes.reversed()
            .map { "• [\(formatter.string(from: $0.date))] \($0.text)" }
            .joined(separator: "\n")
    }

    // MARK: Reset

    func resetAll() {
        isLoading = true
        planned = []
        checked = []
        pantry = AppModel.defaultPantry
        store = .instacartAldi
        extras = []
        notes = []
        isLoading = false
        save()
    }

    // MARK: Persistence

    private func load() {
        guard let data = defaults.data(forKey: Self.storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data)
        else { return }
        isLoading = true
        let validIDs = Set(meals.map(\.id))
        planned = snapshot.planned.filter { validIDs.contains($0.mealID) }
        checked = snapshot.checked
        pantry = snapshot.pantry
        store = snapshot.store
        extras = snapshot.extras
        notes = snapshot.notes
        isLoading = false
    }

    private func save() {
        guard !isLoading else { return }
        let snapshot = Snapshot(
            planned: planned, checked: checked, pantry: pantry,
            store: store, extras: extras, notes: notes
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}
