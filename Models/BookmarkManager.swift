import Foundation

struct Bookmark: Codable, Identifiable {
    let id: UUID
    let bookId: UUID
    let location: Int
    let content: String
    let createdAt: Date
    let note: String?
    
    init(bookId: UUID, location: Int, content: String, note: String? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.location = location
        self.content = content
        self.createdAt = Date()
        self.note = note
    }
}

class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published private(set) var bookmarks: [Bookmark] = []
    private let bookmarksKey = "savedBookmarks"
    
    private init() {
        loadBookmarks()
    }
    
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let savedBookmarks = try? JSONDecoder().decode([Bookmark].self, from: data) {
            self.bookmarks = savedBookmarks
        }
    }
    
    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        }
    }
    
    func addBookmark(bookId: UUID, location: Int, content: String, note: String? = nil) {
        let bookmark = Bookmark(bookId: bookId, location: location, content: content, note: note)
        bookmarks.append(bookmark)
        saveBookmarks()
    }
    
    func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        saveBookmarks()
    }
    
    func getBookmarks(for bookId: UUID) -> [Bookmark] {
        bookmarks.filter { $0.bookId == bookId }
            .sorted { $0.location < $1.location }
    }
} 
