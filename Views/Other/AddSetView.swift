import SwiftUI

struct AddSetView: View {
    let exercise: Exercise
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var weight = ""
    @State private var repetitions = ""
    
    var body: some View {
        Form {
            Section(header: Text("Новый подход")) {
                TextField("Вес (кг)", text: $weight)
                    .keyboardType(.decimalPad)
                
                TextField("Количество повторений", text: $repetitions)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button("Сохранить") {
                    if let weightValue = Double(weight),
                       let repsValue = Int(repetitions) {
                        dataManager.addSet(to: exercise, in: workout, weight: weightValue, reps: repsValue)
                        dismiss()
                    }
                }
                .disabled(weight.isEmpty || repetitions.isEmpty)
            }
        }
        .navigationTitle("Добавить подход")
    }
}
