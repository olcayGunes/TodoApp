import Foundation
import SwiftUI
import UserNotifications
import Combine

class TodoStore: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet {
            saveTodos()
            updateNotifications()
        }
    }
    
    private let todosKey = "todos"
    @Published var collapsedSections: Set<String> = []
    
    init() {
        loadTodos()
        NotificationManager.shared.requestAuthorization()
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey) {
            if let decodedTodos = try? JSONDecoder().decode([Todo].self, from: data) {
                self.todos = decodedTodos.sorted { todo1, todo2 in
                    let calendar = Calendar.current
                    let date1 = calendar.startOfDay(for: todo1.createdAt)
                    let date2 = calendar.startOfDay(for: todo2.createdAt)
                    
                    if calendar.isDateInToday(date1) && !calendar.isDateInToday(date2) {
                        return true
                    }
                    if !calendar.isDateInToday(date1) && calendar.isDateInToday(date2) {
                        return false
                    }
                    
                    return date1 > date2
                }
            }
        }
    }
    
    private func saveTodos() {
        if let encodedData = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encodedData, forKey: todosKey)
        }
    }
    
    private func updateNotifications() {
        for todo in todos {
            if let reminder = todo.reminder, reminder > Date() {
                NotificationManager.shared.scheduleNotification(for: todo)
            }
        }
    }
    
    func toggleSection(_ date: String) {
        if date == "Bugün" { return }
        
        if collapsedSections.contains(date) {
            collapsedSections.remove(date)
        } else {
            collapsedSections.insert(date)
        }
    }
    
    func isSectionCollapsed(_ date: String) -> Bool {
        return date != "Bugün" && collapsedSections.contains(date)
    }
    
    func groupedTodosByDate() -> [(String, [Todo])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: todos) { todo in
            calendar.startOfDay(for: todo.createdAt)
        }
        
        return grouped.map { (date, todos) -> (String, [Todo]) in
            let dateString = formatDate(date)
            return (dateString, todos)
        }
        .sorted { group1, group2 in
            if group1.0 == "Bugün" { return true }
            if group2.0 == "Bugün" { return false }
            if group1.0 == "Dün" { return true }
            if group2.0 == "Dün" { return false }
            return group1.0 > group2.0
        }
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
}
