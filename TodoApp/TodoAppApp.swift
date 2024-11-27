import SwiftUI

@main
struct TodoAppApp: App {
    @StateObject private var store = TodoStore()
    
    var body: some Scene {
        WindowGroup {
            LaunchView() // Başlangıçta gösterilecek görünüm
                .environmentObject(store)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
