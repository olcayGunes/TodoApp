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
    @State private var minimumDate: Date = Date()
    @State private var datePickerTimer: Timer?
    
    init(todo: Todo, onUpdate: @escaping (Todo) -> Void) {
        self.todo = todo
        self.onUpdate = onUpdate
        
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
                        .accessibilityIdentifier("editTitleTextField")
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .accessibilityIdentifier("editDescriptionTextEditor")
                }
                
                Section(header: Text("Öncelik")) {
                    Picker("Öncelik", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("editPriorityPicker")
                }
                
                Section(header: Text("Hatırlatma")) {
                    Toggle("Hatırlatma Ekle", isOn: $isReminderEnabled)
                        .accessibilityIdentifier("editReminderToggle")
                    
                    if isReminderEnabled {
                        DatePicker("Zaman",
                                 selection: $reminderDate,
                                 in: minimumDate...,
                                 displayedComponents: [.date, .hourAndMinute])
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                            .accessibilityIdentifier("editReminderDatePicker")
                            .onAppear {
                                startDatePickerTimer()
                            }
                            .onDisappear {
                                datePickerTimer?.invalidate()
                            }
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
                    .accessibilityIdentifier("editCancelButton")
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
                    .accessibilityIdentifier("editSaveButton")
                }
            }
        }
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
            
            if reminderDate < minimumDate {
                reminderDate = minimumDate
            }
        }
    }
}

struct EditTodoView_Previews: PreviewProvider {
    static var previews: some View {
        EditTodoView(
            todo: Todo(
                title: "Örnek Görev",
                description: "Bu bir örnek görev açıklamasıdır",
                priority: .yuksek,
                reminder: Date()
            ),
            onUpdate: { _ in }
        )
    }
}
