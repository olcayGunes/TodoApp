import SwiftUI

struct StatisticsView: View {
    @ObservedObject var todoStore: TodoStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    private var totalTasks: Int {
        todoStore.todos.count
    }
    
    private var completedTasks: Int {
        todoStore.todos.filter { $0.isCompleted }.count
    }
    
    private var pendingTasks: Int {
        todoStore.todos.filter { !$0.isCompleted }.count
    }
    
    private var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }
    
    private var priorityDistribution: [(Priority, Int)] {
        Priority.allCases.map { priority in
            (priority, todoStore.todos.filter { $0.priority == priority }.count)
        }
    }
    
    private var pieChartData: [PieSliceData] {
        var startAngle: Double = 0
        var slices: [PieSliceData] = []
        
        for (priority, count) in priorityDistribution {
            let percentage = Double(count) / Double(totalTasks)
            let degrees = percentage * 360
            
            slices.append(PieSliceData(
                startAngle: startAngle,
                endAngle: startAngle + degrees,
                color: priority.color,
                value: count,
                title: priority.title
            ))
            
            startAngle += degrees
        }
        
        return slices
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Genel İstatistikler
                VStack(alignment: .leading, spacing: 16) {
                    Text("Genel İstatistikler")
                        .font(.title2)
                        .bold()
                        .accessibilityIdentifier("generalStatsTitle")
                    
                    StatCard(title: "Toplam Görev", value: "\(totalTasks)")
                        .accessibilityIdentifier("totalTasksCard")
                    StatCard(title: "Tamamlanan", value: "\(completedTasks)")
                        .accessibilityIdentifier("completedTasksCard")
                    StatCard(title: "Bekleyen", value: "\(pendingTasks)")
                        .accessibilityIdentifier("pendingTasksCard")
                    StatCard(title: "Tamamlanma Oranı", value: String(format: "%.1f%%", completionRate))
                        .accessibilityIdentifier("completionRateCard")
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // Öncelik Dağılımı
                VStack(alignment: .leading, spacing: 16) {
                    Text("Öncelik Dağılımı")
                        .font(.title2)
                        .bold()
                        .accessibilityIdentifier("priorityDistributionTitle")
                    
                    if totalTasks > 0 {
                        PieChartView(slices: pieChartData, totalValue: totalTasks)
                            .frame(height: 250)
                            .padding(.vertical)
                            .accessibilityIdentifier("priorityPieChart")
                        
                        VStack(spacing: 12) {
                            ForEach(priorityDistribution, id: \.0) { priority, count in
                                HStack {
                                    Circle()
                                        .fill(priority.color)
                                        .frame(width: 12, height: 12)
                                    Text(priority.title)
                                    Spacer()
                                    Text("\(count)")
                                        .bold()
                                    if totalTasks > 0 {
                                        Text("(\(Int(Double(count) / Double(totalTasks) * 100))%)")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .accessibilityIdentifier("priorityRow_\(priority)")
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .padding()
        }
        .navigationTitle("İstatistikler")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                            .bold()
                    }
                    .foregroundColor(.mainColor)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatisticsView(todoStore: TodoStore())
        }
        .preferredColorScheme(.dark)
    }
}
