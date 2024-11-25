import SwiftUI

@main
struct TodoAppApp: App {
    @StateObject private var store = TodoStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
