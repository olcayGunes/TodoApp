import Foundation

class TodoStore: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet {
            saveTodos()
        }
    }
    
    private let todosKey = "todos"
    
    init() {
        loadTodos()
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
}
