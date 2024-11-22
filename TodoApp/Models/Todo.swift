import SwiftUI

struct Todo: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var priority: Priority
    var isCompleted: Bool
    var reminder: Date?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        priority: Priority = .orta,
        isCompleted: Bool = false,
        reminder: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.isCompleted = isCompleted
        self.reminder = reminder
        self.createdAt = createdAt
    }
}

enum Priority: String, CaseIterable {
    case dusuk = "Düşük"
    case orta = "Orta"
    case yuksek = "Yüksek"
    
    var title: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .dusuk:
            return .blue
        case .orta:
            return .orange
        case .yuksek:
            return .red
        }
    }
}

extension Todo: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, description, priority, isCompleted, reminder, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        priority = try container.decode(Priority.self, forKey: .priority)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        reminder = try container.decodeIfPresent(Date.self, forKey: .reminder)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(priority, forKey: .priority)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(reminder, forKey: .reminder)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

extension Priority: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Priority(rawValue: rawValue) ?? .orta
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
