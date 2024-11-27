import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var todoStore = TodoStore()
    @State private var newTodoTitle: String = ""
    @State private var newTodoDescription: String = ""
    @State private var selectedPriority: Priority = .orta
    @State private var isReminderEnabled: Bool = false
    @State private var selectedDate: Date = Date().addingTimeInterval(120)
    @State private var minimumDate: Date = Date()
    @State private var datePickerTimer: Timer?
    @AppStorage("hideCompletedTasks") private var hideCompletedTasks = false
    @State private var collapsedSections: Set<String> = []
    
    private var filteredAndGroupedTodos: [(String, [Todo])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: todoStore.todos) { todo in
            calendar.startOfDay(for: todo.createdAt)
        }
        
        return grouped.map { (date, todos) in
            let dateString = formatDate(date)
            var filteredTodos = todos
            
            if hideCompletedTasks {
                filteredTodos = todos.filter { !$0.isCompleted }
            }
            
            let sortedTodos = filteredTodos.sorted { first, second in
                if first.isCompleted == second.isCompleted {
                    return first.createdAt > second.createdAt
                }
                return !first.isCompleted
            }
            
            return (dateString, sortedTodos)
        }
        .sorted { first, second in
            if first.0 == "Bugün" { return true }
            if second.0 == "Bugün" { return false }
            if first.0 == "Dün" { return true }
            if second.0 == "Dün" { return false }
            return first.0 > second.0
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Başlık kısmı
                Text("Görevler")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.blue.opacity(0.1))
                    .accessibilityIdentifier("titleText")
                    .overlay(
                        NavigationLink(destination: StatisticsView(todoStore: todoStore)) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color.mainColor)
                                .padding()
                        }
                        .accessibilityIdentifier("statisticsButton")
                        , alignment: .trailing
                    )
                
                // Toggle
                Toggle(isOn: $hideCompletedTasks) {
                    Text("Yapılan görevleri gizle")
                }
                .tint(.mainColor)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .accessibilityIdentifier("hideCompletedToggle")
                
                // Görev ekleme formu
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Öncelik Seviyesi:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Picker("Öncelik", selection: $selectedPriority) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.title)
                                    .tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accessibilityIdentifier("priorityPicker")
                    }
                    
                    TextField("", text: $newTodoTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
                        )
                        .overlay(
                            Text("Görev")
                                .foregroundColor(.gray)
                                .padding(.leading, 12)
                                .opacity(newTodoTitle.isEmpty ? 1 : 0),
                            alignment: .leading
                        )
                        .accessibilityIdentifier("titleTextField")
                    
                    TextEditor(text: $newTodoDescription)
                        .frame(height: 80)
                        .padding(2)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Text("Açıklama")
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                                .padding(.top, 8)
                                .opacity(newTodoDescription.isEmpty ? 1 : 0),
                            alignment: .topLeading
                        )
                        .accessibilityIdentifier("descriptionTextEditor")
                    
                    HStack {
                        Toggle("Hatırlatma", isOn: $isReminderEnabled)
                            .tint(.mainColor)
                            .accessibilityIdentifier("reminderToggle")
                    }
                    
                    if isReminderEnabled {
                        VStack(alignment: .leading) {
                            Text("Hatırlatma Zamanı:")
                                .foregroundColor(.gray)
                            
                            DatePicker("",
                                selection: $selectedDate,
                                in: minimumDate...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .accessibilityIdentifier("reminderDatePicker")
                            .onAppear {
                                startDatePickerTimer()
                            }
                            .onDisappear {
                                datePickerTimer?.invalidate()
                            }
                        }
                    }
                    
                    Button(action: addTodo) {
                        Text("Ekle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mainColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .accessibilityIdentifier("addButton")
                }
                .padding()
                
                // Görev listesi
                List {
                    ForEach(filteredAndGroupedTodos, id: \.0) { date, todos in
                        Section {
                            if !collapsedSections.contains(date) || date == "Bugün" {
                                ForEach(todos) { todo in
                                    TodoRowView(todo: todo) { updatedTodo in
                                        if let index = todoStore.todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                                            todoStore.todos[index] = updatedTodo
                                        }
                                    }
                                    .accessibilityIdentifier("todoRow_\(todo.id)")
                                }
                                .onDelete { indexSet in
                                    deleteTodos(at: indexSet, in: todos)
                                }
                            }
                        } header: {
                            HStack {
                                Text(date)
                                    .accessibilityIdentifier("sectionHeader_\(date)")
                                Spacer()
                                if date != "Bugün" {
                                    Image(systemName: collapsedSections.contains(date) ? "chevron.right" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if date != "Bugün" {
                                    withAnimation {
                                        if collapsedSections.contains(date) {
                                            collapsedSections.remove(date)
                                        } else {
                                            collapsedSections.insert(date)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
        }
    }
    
    private func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        
        let todo = Todo(
            title: newTodoTitle,
            description: newTodoDescription,
            priority: selectedPriority,
            reminder: isReminderEnabled ? selectedDate : nil
        )
        todoStore.todos.append(todo)
        
        if isReminderEnabled {
            scheduleNotification(for: todo)
        }
        
        newTodoTitle = ""
        newTodoDescription = ""
        selectedPriority = .orta
        isReminderEnabled = false
        selectedDate = Date().addingTimeInterval(120)
    }
    
    private func deleteTodos(at offsets: IndexSet, in todosList: [Todo]) {
        let todosToDelete = offsets.map { todosList[$0] }
        todoStore.todos.removeAll(where: { todo in
            todosToDelete.contains(where: { $0.id == todo.id })
        })
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Bugün"
        } else if calendar.isDateInYesterday(date) {
            return "Dün"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: date)
        }
    }
    
    private func scheduleNotification(for todo: Todo) {
        guard let reminder = todo.reminder else { return }
        
        let content = UNMutableNotificationContent()
        content.title = todo.title
        content.body = todo.description
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: todo.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func startDatePickerTimer() {
        datePickerTimer?.invalidate()
        updateMinimumDate()
        
        datePickerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateMinimumDate()
        }
    }
    
    private func updateMinimumDate() {
        let calendar = Calendar.current
        let now = Date()
        
        if let nextMinute = calendar.date(byAdding: .minute, value: 1, to: now) {
            minimumDate = nextMinute
            
            if selectedDate < minimumDate {
                selectedDate = minimumDate
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
