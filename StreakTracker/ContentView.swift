import SwiftUI
import SwiftData
import Charts

struct DailyCompletion: Identifiable {
    let date: Date
    let count: Int

    var id: Date { date }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]

    @State private var showingAddHabit = false

    private var weeklyData: [DailyCompletion] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let count = habits.filter { habit in
                habit.completionDates.contains { calendar.isDate($0, inSameDayAs: day) }
            }.count

            return DailyCompletion(date: day, count: count)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Desempenho Semanal") {
                    Chart(weeklyData) { item in
                        BarMark(
                            x: .value("Dia", item.date, unit: .day),
                            y: .value("Hábitos", item.count)
                        )
                        .foregroundStyle(.blue.gradient)
                        .cornerRadius(5)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                        }
                    }
                    .frame(height: 180)
                }

                Section("Hábitos") {
                    if habits.isEmpty {
                        ContentUnavailableView(
                            "Nenhum hábito ainda",
                            systemImage: "checkmark.circle",
                            description: Text("Toque em + para adicionar seu primeiro hábito.")
                        )
                    } else {
                        ForEach(habits) { habit in
                            HabitRowView(habit: habit)
                        }
                        .onDelete(perform: deleteHabits)
                    }
                }
            }
            .navigationTitle("Streak Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Adicionar hábito")
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(habits[index])
        }

        try? modelContext.save()
    }
}
