import SwiftUI

struct PlanView: View {
    @EnvironmentObject var model: AppModel
    var goToList: () -> Void
    var goToDiscover: () -> Void
    @State var confirmClear = false

    var body: some View {
        NavigationStack {
            Group {
                if model.planned.isEmpty {
                    ContentUnavailableView {
                        Label("No meals planned", systemImage: "calendar.badge.plus")
                    } description: {
                        Text("Pick this week's dinners in Discover. Your shopping list builds itself.")
                    } actions: {
                        Button("Browse meals", action: goToDiscover)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        Section {
                            ForEach(model.planned) { plan in
                                if let meal = model.meal(for: plan) {
                                    PlannedRow(meal: meal, plan: plan)
                                }
                            }
                            .onDelete(perform: model.removePlanned)
                            .onMove(perform: model.movePlanned)
                        } header: {
                            Text("\(model.planned.count) dinners")
                        } footer: {
                            Text("Change servings to scale ingredient amounts on the list.")
                        }

                        Section {
                            Button(action: goToList) {
                                Label("View shopping list (\(model.remainingCount) to buy)", systemImage: "cart.fill")
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("This Week")
            .toolbar {
                if !model.planned.isEmpty {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear", role: .destructive) { confirmClear = true }
                    }
                }
            }
            .confirmationDialog("Clear this week's meals and check-offs?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Clear week", role: .destructive) { withAnimation { model.clearWeek() } }
            }
        }
    }
}

private struct PlannedRow: View {
    @EnvironmentObject var model: AppModel
    let meal: Meal
    let plan: PlannedMeal

    var body: some View {
        HStack(spacing: 12) {
            Text(meal.emoji).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name).font(.headline)
                Text("\(meal.minutes) min").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Stepper(
                value: Binding(
                    get: { plan.servings },
                    set: { model.setServings($0, for: plan.mealID) }
                ),
                in: 1...16
            ) {
                Text("\(plan.servings)")
                    .monospacedDigit()
                    .font(.subheadline.weight(.semibold))
            }
            .fixedSize()
            .accessibilityLabel("Servings")
        }
    }
}
