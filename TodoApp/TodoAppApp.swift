//
//  TodoAppApp.swift
//  TodoApp
//
//  Created by Olcay Güneş on 22.11.2024.
//

import SwiftUI

@main
struct TodoAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
