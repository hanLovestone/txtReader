import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bookRepository: BookRepository
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BookshelfView()
                .tabItem {
                    Label("书架", systemImage: "books.vertical")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BookRepository.shared)
} 
