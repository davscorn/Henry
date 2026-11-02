import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var model: AppModel
    @State var query = ""
    @State var selectedTag: String?

    private var filtered: [Meal] {
        model.meals.filter { meal in
            let matchesTag = selectedTag.map { meal.tags.contains($0) } ?? true
            let q = query.trimmingCharacters(in: .whitespaces).lowercased()
            let matchesQuery = q.isEmpty
                || meal.name.lowercased().contains(q)
                || meal.ingredients.contains { $0.normalizedName.contains(q) }
            return matchesTag && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            TagChip(title: "All", isSelected: selectedTag == nil) { selectedTag = nil }
                            ForEach(MealLibrary.allTags, id: \.self) { tag in
                                TagChip(title: tag, isSelected: selectedTag == tag) {
                                    selectedTag = selectedTag == tag ? nil : tag
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }

                Section("\(filtered.count) meals") {
                    ForEach(filtered) { meal in
                        NavigationLink(value: meal) {
                            MealRow(meal: meal)
                        }
                    }
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $query, prompt: "Meals or ingredients")
            .navigationDestination(for: Meal.self) { meal in
                MealDetailView(meal: meal)
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
        }
    }
}

struct MealRow: View {
    @EnvironmentObject var model: AppModel
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            Text(meal.emoji)
                .font(.system(size: 34))
                .frame(width: 52, height: 52)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(meal.name).font(.headline)
                Text("\(meal.minutes) min · serves \(meal.servings) · \(meal.ingredients.count) ingredients")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button {
                withAnimation { model.togglePlanned(meal) }
            } label: {
                Image(systemName: model.isPlanned(meal) ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundStyle(model.isPlanned(meal) ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(model.isPlanned(meal) ? "Remove \(meal.name) from this week" : "Add \(meal.name) to this week")
        }
        .padding(.vertical, 2)
    }
}

struct TagChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}
