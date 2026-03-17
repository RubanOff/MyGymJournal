import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Нет тренировок")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Нажмите + чтобы добавить")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
