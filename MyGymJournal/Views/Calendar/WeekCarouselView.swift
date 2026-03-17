import SwiftUI

struct WeekCarouselView: View {
    let currentWeekDays: [Date]
    let nextWeekDays: [Date]
    let previousWeekDays: [Date]
    @Binding var selectedDate: Date
    let hasWorkout: (Date) -> Bool
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    let onSwipeComplete: (DragDirection) -> Void
    
    @State private var dragDirection: DragDirection = .none
    
    var body: some View {
        GeometryReader { geometry in
            let dayWidth = geometry.size.width / 7
            
            ZStack {
                if dragOffset > 0 {
                    WeekRowView(
                        weekDays: previousWeekDays,
                        selectedDate: $selectedDate,
                        hasWorkout: hasWorkout,
                        dayWidth: dayWidth,
                        offset: dragOffset - geometry.size.width
                    )
                }
                
                WeekRowView(
                    weekDays: currentWeekDays,
                    selectedDate: $selectedDate,
                    hasWorkout: hasWorkout,
                    dayWidth: dayWidth,
                    offset: dragOffset
                )
                .zIndex(1)
                
                if dragOffset < 0 {
                    WeekRowView(
                        weekDays: nextWeekDays,
                        selectedDate: $selectedDate,
                        hasWorkout: hasWorkout,
                        dayWidth: dayWidth,
                        offset: dragOffset + geometry.size.width
                    )
                }
            }
            .frame(width: geometry.size.width, height: 80)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            dragOffset = value.translation.width
                            isDragging = true
                            
                            if value.translation.width > 0 {
                                dragDirection = .right
                            } else if value.translation.width < 0 {
                                dragDirection = .left
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            let threshold = geometry.size.width / 3
                            
                            if value.translation.width < -threshold {
                                dragOffset = -geometry.size.width
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onSwipeComplete(.left)
                                    isDragging = false
                                }
                            } else if value.translation.width > threshold {
                                dragOffset = geometry.size.width
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onSwipeComplete(.right)
                                    isDragging = false
                                }
                            } else {
                                dragOffset = 0
                                isDragging = false
                            }
                        }
                    }
            )
        }
    }
}
