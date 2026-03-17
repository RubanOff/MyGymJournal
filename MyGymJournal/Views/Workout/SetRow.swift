import SwiftUI

struct SetRow: View {
    let set: WorkoutSet
    let setIndex: Int
    let exercise: Exercise
    let workout: Workout
    @ObservedObject var dataManager: DataManager
    let onDelete: () -> Void  // 👈 Замыкание для удаления
    
    private func formattedWeight() -> String {
        if set.weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", set.weight)
        } else {
            return String(format: "%.1f", set.weight)
        }
    }
    
    var body: some View {
        HStack {
            Text("\(setIndex + 1)")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            HStack(spacing: 4) {
                Text(formattedWeight())
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("кг")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("×")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Text("\(set.repetitions)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("раз")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Menu {
                Button(role: .destructive) {
                    onDelete()  // 👈 Вызываем замыкание
                } label: {
                    Label("Удалить подход", systemImage: "trash")
                }
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray5).opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}
