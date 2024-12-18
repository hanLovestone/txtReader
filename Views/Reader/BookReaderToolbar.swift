import SwiftUI

struct BookReaderToolbar: View {
    let book: Book
    @Binding var showingSettings: Bool
    let onJumpToLocation: (Int) -> Void
    @StateObject private var appState = AppState.shared
    @State private var showingShareSheet = false
    @State private var showingBookmark = false
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                showingSettings.toggle()
            } label: {
                Image(systemName: "textformat.size")
                    .font(.title3)
            }
            
            Button {
                showingBookmark.toggle()
            } label: {
                Image(systemName: "bookmark")
                    .font(.title3)
            }
            
            Button {
                showingShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
            }
        }
        .foregroundColor(appState.readerSettings.textColor)
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: book.filePath) {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $showingBookmark) {
            BookmarkListView(
                book: book,
                onJumpToLocation: onJumpToLocation
            )
        }
    }
}

#Preview {
    BookReaderToolbar(
        book: Book(title: "测试书籍", filePath: "test.txt"),
        showingSettings: .constant(false),
        onJumpToLocation: { _ in }
    )
} 
