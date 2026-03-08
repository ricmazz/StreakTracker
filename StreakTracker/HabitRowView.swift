import SwiftUI
import SwiftData

struct HabitRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var habit: Habit

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)

                Text("Streak atual: \(habit.currentStreak) dia(s)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                guard !habit.isCompletedToday else { return }

                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.impactOccurred()

                habit.markCompletedTodayIfNeeded()
                try? modelContext.save()
            } label: {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isCompletedToday ? .green : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(habit.isCompletedToday ? "Concluído hoje" : "Marcar como concluído")
        }
        .padding(.vertical, 4)
    }
}
