import SwiftUI

struct NotesEditorView: View {
    @Binding var notes: String
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $notes)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
            }
            .navigationTitle("Заметки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if let index = dataManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                            dataManager.workouts[index].notes = notes
                            dataManager.saveData()
                        }
                        isPresented = false
                    }
                    .bold()
                }
            }
        }
    }
}
