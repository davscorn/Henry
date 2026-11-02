import SwiftUI

struct MealDetailView: View {
    @EnvironmentObject var model: AppModel
    let meal: Meal

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(meal.emoji).font(.system(size: 56))
                    Text(meal.summary).font(.body)
                    HStack(spacing: 16) {
                        Label("\(meal.minutes) min", systemImage: "clock")
                        Label("Serves \(meal.servings)", systemImage: "person.2")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    if !meal.tags.isEmpty {
                        Text(meal.tags.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                Button {
                    withAnimation { model.togglePlanned(meal) }
                } label: {
                    Label(
                        model.isPlanned(meal) ? "Remove from this week" : "Add to this week",
                        systemImage: model.isPlanned(meal) ? "minus.circle" : "plus.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
                .tint(model.isPlanned(meal) ? Color.red : Color.accentColor)
            }

            Section("Ingredients") {
                ForEach(meal.ingredients, id: \.self) { ingredient in
                    HStack {
                        Text(ingredient.name.prefix(1).uppercased() + ingredient.name.dropFirst())
                        Spacer()
                        Text(ingredient.amountText).foregroundStyle(.secondary)
                    }
                }
            }

            Section("Steps") {
                ForEach(Array(meal.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.accentColor)
                        Text(step)
                    }
                }
            }
        }
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
