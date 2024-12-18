import SwiftUI

@main
struct txtReaderApp: App {
    @StateObject private var bookRepository = BookRepository.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookRepository)
        }
    }
}
