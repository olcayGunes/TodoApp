import Foundation
import UserNotifications

class TodoStore: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet {
            saveTodos()
            updateNotifications()
        }
    }
    
    private let todosKey = "todos"
    
    init() {
        loadTodos()
        NotificationManager.shared.requestAuthorization()
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey) {
            if let decodedTodos = try? JSONDecoder().decode([Todo].self, from: data) {
                self.todos = decodedTodos
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
}
