import SwiftUI
import UIKit

struct ShoppingListView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openURL) var openURL
    var goToDiscover: () -> Void

    @State var newExtra = ""
    @State var showPantry = false
    @State var copied = false

    var body: some View {
        let items = model.listItems
        let needed = items.filter { !$0.isPantry }
        let pantryItems = items.filter(\.isPantry)

        NavigationStack {
            Group {
                if items.isEmpty && model.extras.isEmpty {
                    ContentUnavailableView {
                        Label("Your list is empty", systemImage: "cart")
                    } description: {
                        Text("Add meals to this week and every ingredient lands here, combined and sorted by aisle.")
                    } actions: {
                        Button("Browse meals", action: goToDiscover)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        Section {
                            HStack {
                                Image(systemName: "storefront")
                                    .foregroundStyle(Color.accentColor)
                                Picker("Shop at", selection: $model.store) {
                                    ForEach(StoreChoice.allCases) { Text($0.name).tag($0) }
                                }
                            }
                        } footer: {
                            Text("Tap \(Image(systemName: "magnifyingglass")) on any item to search for it at \(model.store.name). Swipe left on an item you already have.")
                        }

                        ForEach(Aisle.allCases) { aisle in
                            let inAisle = needed.filter { $0.aisle == aisle }
                            if !inAisle.isEmpty {
                                Section {
                                    ForEach(inAisle) { item in
                                        ItemRow(item: item, store: model.store, onShop: shop)
                                            .swipeActions(edge: .trailing) {
                                                Button {
                                                    withAnimation { model.addToPantry(item.id) }
                                                } label: {
                                                    Label("Have it", systemImage: "house")
                                                }
                                                .tint(.orange)
                                            }
                                    }
                                } header: {
                                    Label(aisle.title, systemImage: aisle.symbol)
                                }
                            }
                        }

                        Section("Extras") {
                            ForEach(model.extras, id: \.self) { extra in
                                let key = model.extraKey(extra)
                                HStack {
                                    CheckButton(isOn: model.checked.contains(key)) {
                                        withAnimation { model.toggleChecked(key) }
                                    }
                                    Text(extra)
                                        .strikethrough(model.checked.contains(key))
                                        .foregroundStyle(model.checked.contains(key) ? .secondary : .primary)
                                    Spacer()
                                    ShopButton(store: model.store) { shop(extra) }
                                }
                            }
                            .onDelete(perform: model.removeExtras)

                            HStack {
                                TextField("Add an item (paper towels, milk…)", text: $newExtra)
                                    .submitLabel(.done)
                                    .onSubmit(addExtra)
                                Button("Add", action: addExtra)
                                    .disabled(newExtra.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }

                        if !pantryItems.isEmpty {
                            Section {
                                DisclosureGroup(isExpanded: $showPantry) {
                                    ForEach(pantryItems) { item in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(item.displayName)
                                                Text(item.amountText).font(.caption).foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Button("Need it") {
                                                withAnimation { model.removeFromPantry(item.id) }
                                            }
                                            .buttonStyle(.bordered)
                                            .controlSize(.small)
                                        }
                                    }
                                } label: {
                                    Label("Already in your pantry (\(pantryItems.count))", systemImage: "house")
                                }
                            } footer: {
                                Text("Pantry staples are hidden from the list. Manage them in Settings.")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !items.isEmpty || !model.extras.isEmpty {
                        Menu {
                            Button {
                                UIPasteboard.general.string = ListBuilder.plainText(items: items, extras: model.extras)
                                copied = true
                            } label: {
                                Label("Copy list", systemImage: "doc.on.doc")
                            }
                            Button {
                                withAnimation { model.uncheckAll() }
                            } label: {
                                Label("Uncheck all", systemImage: "arrow.uturn.backward")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        ShareLink(item: ListBuilder.plainText(items: items, extras: model.extras))
                    }
                }
            }
            .alert("List copied", isPresented: $copied) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Paste it into Notes, Messages or a store app's list.")
            }
        }
    }

    private func addExtra() {
        model.addExtra(newExtra)
        newExtra = ""
    }

    private func shop(_ term: String) {
        if let url = model.store.searchURL(for: term) {
            openURL(url)
        }
    }
}

private struct ItemRow: View {
    @EnvironmentObject var model: AppModel
    let item: ListItem
    let store: StoreChoice
    let onShop: (String) -> Void

    var body: some View {
        let isChecked = model.checked.contains(item.id)
        HStack(spacing: 12) {
            CheckButton(isOn: isChecked) {
                withAnimation { model.toggleChecked(item.id) }
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.displayName)
                        .strikethrough(isChecked)
                        .foregroundStyle(isChecked ? .secondary : .primary)
                    Spacer(minLength: 4)
                    Text(item.amountText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isChecked ? .secondary : .primary)
                }
                Text(item.mealNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            ShopButton(store: store) { onShop(item.searchTerm) }
        }
        .contentShape(Rectangle())
    }
}

private struct CheckButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isOn ? "In cart" : "Not in cart")
    }
}

private struct ShopButton: View {
    let store: StoreChoice
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.semibold))
                .padding(8)
                .background(Color.accentColor.opacity(0.12), in: Circle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("Search \(store.name)")
    }
}
