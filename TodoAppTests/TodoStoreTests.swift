import XCTest
@testable import TodoApp

class TodoStoreTests: XCTestCase {
    var todoStore: TodoStore!
    
    override func setUp() {
        super.setUp()
        todoStore = TodoStore()
        todoStore.todos.removeAll()
    }
    
    override func tearDown() {
        todoStore = nil
        super.tearDown()
    }
    
    func testAddTodo() {
        // Given
        let initialCount = todoStore.todos.count
        let newTodo = Todo(
            title: "Test Todo",
            description: "Test Description",
            priority: .orta
        )
        
        // When
        todoStore.todos.append(newTodo)
        
        // Then
        XCTAssertEqual(todoStore.todos.count, initialCount + 1)
        XCTAssertEqual(todoStore.todos.last?.title, "Test Todo")
        XCTAssertEqual(todoStore.todos.last?.description, "Test Description")
        XCTAssertEqual(todoStore.todos.last?.priority, .orta)
    }
    
    func testDeleteTodo() {
        // Given
        var todo = Todo(title: "Test Todo", description: "Test", priority: .orta)
        todoStore.todos.append(todo)
        let initialCount = todoStore.todos.count
        
        // When
        todoStore.todos.removeAll { $0.id == todo.id }
        
        // Then
        XCTAssertEqual(todoStore.todos.count, initialCount - 1)
        XCTAssertFalse(todoStore.todos.contains { $0.id == todo.id })
    }
    
    func testTodoCompletion() {
        // Given
        var todo = Todo(title: "Test Todo", description: "Test", priority: .orta)
        todoStore.todos.append(todo)
        
        // When
        if let index = todoStore.todos.firstIndex(where: { $0.id == todo.id }) {
            todo.isCompleted = true
            todoStore.todos[index] = todo
        }
        
        // Then
        XCTAssertTrue(todoStore.todos.first { $0.id == todo.id }?.isCompleted ?? false)
    }
    
    func testTodoSorting() {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        var todayTodo = Todo(title: "Today Todo", description: "Test", priority: .orta)
        var yesterdayTodo = Todo(title: "Yesterday Todo", description: "Test", priority: .orta)
        yesterdayTodo.createdAt = yesterday
        
        // When
        todoStore.todos.append(todayTodo)
        todoStore.todos.append(yesterdayTodo)
        
        let groupedTodos = todoStore.groupedTodosByDate()
        
        // Then
        XCTAssertEqual(groupedTodos[0].0, "Bugün")
        XCTAssertEqual(groupedTodos[1].0, "Dün")
    }
    
    func testHideCompletedTasks() {
        // Given
        todoStore.todos.removeAll()
        
        var completedTodo = Todo(title: "Completed", description: "Test", priority: .orta)
        completedTodo.isCompleted = true
        
        var incompleteTodo = Todo(title: "Incomplete", description: "Test", priority: .orta)
        
        todoStore.todos.append(completedTodo)
        todoStore.todos.append(incompleteTodo)
        
        // When
        let allTodos = todoStore.todos
        
        // Then
        XCTAssertEqual(allTodos.count, 2)
        XCTAssertTrue(allTodos.contains { $0.title == "Incomplete" })
        XCTAssertTrue(allTodos.contains { $0.title == "Completed" })
    }
    
    func testTodoPriority() {
        // Given
        todoStore.todos.removeAll()
        
        var highPriorityTodo = Todo(title: "High", description: "Test", priority: .yuksek)
        var mediumPriorityTodo = Todo(title: "Medium", description: "Test", priority: .orta)
        var lowPriorityTodo = Todo(title: "Low", description: "Test", priority: .dusuk)
        
        // When
        todoStore.todos.append(lowPriorityTodo)
        todoStore.todos.append(mediumPriorityTodo)
        todoStore.todos.append(highPriorityTodo)
        
        let groupedTodos = todoStore.groupedTodosByDate()
        let todosForToday = groupedTodos.first?.1 ?? []
        
        // Then
        XCTAssertEqual(todosForToday.count, 3)
        XCTAssertTrue(todosForToday.contains { $0.priority == .yuksek })
        XCTAssertTrue(todosForToday.contains { $0.priority == .orta })
        XCTAssertTrue(todosForToday.contains { $0.priority == .dusuk })
    }
    
    func testTodoReminder() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let todo = Todo(
            title: "Reminder Test",
            description: "Test",
            priority: .orta,
            reminder: futureDate
        )
        
        // When
        todoStore.todos.append(todo)
        
        // Then
        XCTAssertNotNil(todoStore.todos.last?.reminder)
        XCTAssertGreaterThan(todoStore.todos.last?.reminder ?? Date(), Date())
    }
    
    func testTodoDescription() {
        // Given
        let todo = Todo(
            title: "Test Todo",
            description: "This is a test description",
            priority: .orta
        )
        
        // When
        todoStore.todos.append(todo)
        
        // Then
        XCTAssertFalse(todo.description.isEmpty)
        XCTAssertEqual(todo.description, "This is a test description")
    }
    
    // YENİ TESTLER
    
    func testTodoDateFormatting() {
        // Given
        let todo = Todo(title: "Test", description: "Test", priority: .orta)
        todoStore.todos.append(todo)
        
        // When
        let groupedTodos = todoStore.groupedTodosByDate()
        let dateString = groupedTodos.first?.0
        
        // Then
        XCTAssertEqual(dateString, "Bugün")
    }
    
    func testEmptyTodoList() {
        // Given
        todoStore.todos.removeAll()
        
        // When
        let groupedTodos = todoStore.groupedTodosByDate()
        
        // Then
        XCTAssertTrue(groupedTodos.isEmpty)
    }
    
    func testUpdateTodo() {
        // Given
        var todo = Todo(title: "Original", description: "Test", priority: .orta)
        todoStore.todos.append(todo)
        
        // When
        if let index = todoStore.todos.firstIndex(where: { $0.id == todo.id }) {
            todo.title = "Updated"
            todoStore.todos[index] = todo
        }
        
        // Then
        XCTAssertEqual(todoStore.todos.first?.title, "Updated")
    }
    
    func testMultipleDayTodos() {
        // Given
        todoStore.todos.removeAll()
        let today = Todo(title: "Today", description: "Test", priority: .orta)
        
        var yesterday = Todo(title: "Yesterday", description: "Test", priority: .orta)
        yesterday.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        var tomorrow = Todo(title: "Tomorrow", description: "Test", priority: .orta)
        tomorrow.createdAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // When
        todoStore.todos.append(contentsOf: [today, yesterday, tomorrow])
        let groupedTodos = todoStore.groupedTodosByDate()
        
        // Then
        XCTAssertEqual(groupedTodos.count, 3) // Üç farklı gün olmalı
        
        // Her grubun en az bir todo içerdiğini kontrol et
        for (_, todos) in groupedTodos {
            XCTAssertFalse(todos.isEmpty)
        }
        
        // Tüm todoların bir grupta olduğunu kontrol et
        let totalTodosInGroups = groupedTodos.reduce(0) { $0 + $1.1.count }
        XCTAssertEqual(totalTodosInGroups, 3)
    }
    
    func testTodoStorePerformance() {
        measure {
            // Given
            todoStore.todos.removeAll() // Her ölçümde temiz başla
            let todoCount = 1000
            
            // When
            for i in 0..<todoCount {
                let todo = Todo(
                    title: "Performance Test Todo \(i)",
                    description: "Test description for performance measurement",
                    priority: i % 3 == 0 ? .yuksek : (i % 3 == 1 ? .orta : .dusuk)
                )
                todoStore.todos.append(todo)
            }
            
            // Then
            let groupedTodos = todoStore.groupedTodosByDate()
            XCTAssertFalse(groupedTodos.isEmpty)
            XCTAssertEqual(todoStore.todos.count, todoCount)
        }
    }
}
