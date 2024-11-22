import SwiftUI

struct EditTodoView: View {
    @Environment(\.dismiss) private var dismiss
    let todo: Todo
    let onUpdate: (Todo) -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var priority: Priority
    @State private var isReminderEnabled: Bool
    @State private var reminderDate: Date
    
    init(todo: Todo, onUpdate: @escaping (Todo) -> Void) {
        self.todo = todo
        self.onUpdate = onUpdate
        
        // State değişkenlerini başlat
        _title = State(initialValue: todo.title)
        _description = State(initialValue: todo.description)
        _priority = State(initialValue: todo.priority)
        _isReminderEnabled = State(initialValue: todo.reminder != nil)
        _reminderDate = State(initialValue: todo.reminder ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Görev Detayları")) {
                    TextField("Başlık", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Öncelik")) {
                    Picker("Öncelik", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Hatırlatma")) {
                    Toggle("Hatırlatma Ekle", isOn: $isReminderEnabled)
                    
                    if isReminderEnabled {
                        DatePicker("Zaman",
                                 selection: $reminderDate,
                                 displayedComponents: [.date, .hourAndMinute])
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                    }
                }
            }
            .navigationTitle("Görevi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let updatedTodo = Todo(
                            id: todo.id,
                            title: title,
                            description: description,
                            priority: priority,
                            isCompleted: todo.isCompleted,
                            reminder: isReminderEnabled ? reminderDate : nil,
                            createdAt: todo.createdAt
                        )
                        onUpdate(updatedTodo)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
