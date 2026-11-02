import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: AppModel
    @State var newStaple = ""
    @State var noteDraft = ""
    @State var confirmReset = false
    @FocusState var noteFocused: Bool

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Preferred store", selection: $model.store) {
                        ForEach(StoreChoice.allCases) { Text($0.name).tag($0) }
                    }
                } header: {
                    Text("Shopping")
                } footer: {
                    Text("Search buttons on the list open this store's results page.")
                }

                Section {
                    ForEach(model.pantry.sorted(), id: \.self) { staple in
                        Text(staple.prefix(1).uppercased() + staple.dropFirst())
                    }
                    .onDelete { offsets in
                        let sorted = model.pantry.sorted()
                        for index in offsets { model.removeFromPantry(sorted[index]) }
                    }
                    HStack {
                        TextField("Add a staple (e.g. flour)", text: $newStaple)
                            .onSubmit(addStaple)
                        Button("Add", action: addStaple)
                            .disabled(newStaple.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Pantry staples")
                } footer: {
                    Text("Things you always have. They're kept off your shopping list. Names must match the ingredient name.")
                }

                Section {
                    TextField("What broke, confused you, or was missing?", text: $noteDraft, axis: .vertical)
                        .lineLimit(2...6)
                        .focused($noteFocused)
                    Button("Save note") {
                        model.addNote(noteDraft)
                        noteDraft = ""
                        noteFocused = false
                    }
                    .disabled(noteDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    ForEach(model.notes) { note in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.text)
                            Text(note.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: model.deleteNotes)

                    if !model.notes.isEmpty {
                        ShareLink(item: model.notesExport) {
                            Label("Share all notes", systemImage: "square.and.arrow.up")
                        }
                    }
                } header: {
                    Text("Feedback notes")
                } footer: {
                    Text("Your V2 list. Notes stay on this phone until you share them.")
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Meals in library", value: "\(model.meals.count)")
                    Button("Reset all data", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Erase your plan, list, pantry and notes?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset everything", role: .destructive) { model.resetAll() }
            }
        }
    }

    private func addStaple() {
        model.addToPantry(newStaple)
        newStaple = ""
    }
}
