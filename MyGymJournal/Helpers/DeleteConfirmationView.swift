import SwiftUI

struct DeleteConfirmationView: View {
    @Binding var isPresented: Bool
    let itemName: String
    let itemType: String
    let onDelete: () -> Void
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.2
    @State private var blur: CGFloat = 10
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black
                .opacity(0.3 * opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAlert()
                }
            
            // Карточка алерта
            VStack(spacing: 24) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                // Заголовки
                VStack(spacing: 8) {
                    Text("Удалить \(itemType)?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(itemName)")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text("Это действие нельзя отменить")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Кнопки
                HStack(spacing: 16) {
                    // Кнопка отмены
                    Button(action: dismissAlert) {
                        Text("Отмена")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                            )
                    }
                    
                    // Кнопка удаления
                    Button(action: {
                        onDelete()
                        dismissAlert()
                    }) {
                        Text("Удалить")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemGray6).opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [.red.opacity(0.5), .orange.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .padding(.horizontal, 20)
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: blur)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                opacity = 1
                blur = 0
            }
            
            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 300, damping: 25, initialVelocity: 0)) {
                scale = 1.0
            }
        }
    }
    
    private func dismissAlert() {
        withAnimation(.easeIn(duration: 0.2)) {
            opacity = 0
            scale = 0.8
            blur = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}
