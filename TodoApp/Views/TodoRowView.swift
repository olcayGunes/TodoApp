import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    let onUpdate: (Todo) -> Void
    @State private var showingEditSheet = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? Color.mainColor : .gray)
                    .onTapGesture {
                        var updatedTodo = todo
                        updatedTodo.isCompleted.toggle()
                        onUpdate(updatedTodo)
                    }
                    .accessibilityIdentifier("completeButton_\(todo.title)")  // Değişti
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .accessibilityIdentifier("todoTitle_\(todo.title)")
                    
                    if !todo.description.isEmpty {
                        Text(todo.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough(todo.isCompleted)
                            .accessibilityIdentifier("todoDescription_\(todo.description)")
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(Color.mainColor)
                }
                .accessibilityIdentifier("editButton_\(todo.title)")  // Değişti
                
                Circle()
                    .fill(todo.priority.color)
                    .frame(width: 12, height: 12)
                    .accessibilityIdentifier("priorityIndicator_\(todo.title)")  // Değişti
            }
            
            if let reminder = todo.reminder {
                HStack {
                    Spacer()
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(dateFormatter.string(from: reminder))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityIdentifier("reminderText_\(todo.title)")  // Değişti
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTodoView(todo: todo, onUpdate: onUpdate)
        }
    }
}

struct TodoRowView_Previews: PreviewProvider {
    static var previews: some View {
        TodoRowView(
            todo: Todo(
                title: "Örnek Görev",
                description: "Bu bir örnek görev açıklamasıdır",
                priority: .yuksek,
                reminder: Date()
            ),
            onUpdate: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
