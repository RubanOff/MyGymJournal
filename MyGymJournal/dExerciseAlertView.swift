import SwiftUI

struct AddExerciseAlertView: View {
    @Binding var isPresented: Bool
    @State private var exerciseName = ""
    var onSave: (String) -> Void
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.2
    @State private var blur: CGFloat = 10
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardShowing = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон с плавным появлением
            Color.black
                .opacity(0.3 * opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAlert()
                }
            
            // Карточка алерта с идеальной анимацией
            alertCard
                .offset(y: isKeyboardShowing ? -keyboardHeight * 0.25 : 0)
                .scaleEffect(scale)
                .opacity(opacity)
                .blur(radius: blur)
        }
        .ignoresSafeArea()
        .onAppear {
            // Шаг 1: Мгновенно устанавливаем начальные значения
            opacity = 0
            scale = 1.2
            blur = 10
            
            // Шаг 2: Плавное появление с правильной кривой анимации
            withAnimation(.easeOut(duration: 0.35)) {
                opacity = 1
                blur = 0
            }
            
            // Шаг 3: Масштаб с пружинистым эффектом чуть позже
            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 300, damping: 25, initialVelocity: 0)) {
                scale = 1.0
            }
            
            // Шаг 4: Фокус на поле ввода после анимации
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTextFieldFocused = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
               let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                
                withAnimation(.easeOut(duration: animationDuration)) {
                    keyboardHeight = keyboardFrame.height
                    isKeyboardShowing = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                
                withAnimation(.easeOut(duration: animationDuration)) {
                    keyboardHeight = 0
                    isKeyboardShowing = false
                }
            }
        }
    }
    
    // Основная карточка
    private var alertCard: some View {
        VStack(spacing: 24) {
            headerSection
            inputSection
            buttonSection
        }
        .padding(24)
        .background(backgroundCard)
        .padding(.horizontal, 20)
    }
    
    // Верхняя секция с иконкой и заголовками
    private var headerSection: some View {
        VStack(spacing: 16) {
            iconCircle
                .scaleEffect(opacity) // Иконка тоже плавно появляется
            titleText
            subtitleText
        }
    }
    
    // Кружок с иконкой
    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(iconGradient)
                .frame(width: 70, height: 70)
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 30))
                .foregroundColor(.white)
        }
    }
    
    // Градиент для иконки
    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Заголовок
    private var titleText: some View {
        Text("Новое упражнение")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    // Подзаголовок
    private var subtitleText: some View {
        Text("Введите название упражнения")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    // Секция ввода
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("НАЗВАНИЕ")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            customTextField
        }
    }
    
    // Кастомное поле ввода
    private var customTextField: some View {
        TextField("", text: $exerciseName)
            .focused($isTextFieldFocused)
            .placeholder(when: exerciseName.isEmpty) {
                Text("Например: Жим лежа")
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding()
            .background(textFieldBackground)
            .foregroundColor(.white)
            .autocapitalization(.sentences)
            .submitLabel(.done)
            .onSubmit {
                if !exerciseName.isEmpty {
                    onSave(exerciseName)
                    dismissAlert()
                }
            }
    }
    
    // Фон для текстового поля
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6).opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTextFieldFocused ? Color.green : Color.clear, lineWidth: 2)
            )
    }
    
    // Секция с кнопками
    private var buttonSection: some View {
        HStack(spacing: 16) {
            cancelButton
            createButton
        }
    }
    
    // Кнопка отмены
    private var cancelButton: some View {
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
    }
    
    // Кнопка создания
    private var createButton: some View {
        Button(action: {
            if !exerciseName.isEmpty {
                onSave(exerciseName)
                dismissAlert()
            }
        }) {
            Text("Добавить")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(createButtonBackground)
        }
        .disabled(exerciseName.isEmpty)
    }
    
    // Фон кнопки создания (градиент или серый)
    private var createButtonBackground: some View {
        Group {
            if exerciseName.isEmpty {
                Color.green.opacity(0.5)
            } else {
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // Фон карточки
    private var backgroundCard: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color(.systemGray6).opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.5), .blue.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
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
