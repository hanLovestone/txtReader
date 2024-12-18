import Foundation

class BookRepository: ObservableObject {
    static let shared = BookRepository()
    
    @Published private(set) var books: [Book] = []
    private let booksKey = "savedBooks"
    
    private init() {
        loadBooks()
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: booksKey),
           let savedBooks = try? JSONDecoder().decode([Book].self, from: data) {
            self.books = savedBooks
        }
    }
    
    private func saveBooks() {
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: booksKey)
        }
    }
    
    func addBook(title: String, filePath: String) {
        let book = Book(title: title, filePath: filePath)
        books.append(book)
        saveBooks()
    }
    
    func removeBook(at indexSet: IndexSet) {
        // 删除文件
        for index in indexSet {
            let book = books[index]
            try? FileManager.default.removeItem(atPath: book.filePath)
        }
        
        books.remove(atOffsets: indexSet)
        saveBooks()
    }
    
    func updateReadingProgress(for book: Book, location: Int) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            var updatedBook = book
            updatedBook.updateReadingProgress(location: location)
            books[index] = updatedBook
            saveBooks()
        }
    }
    
    @MainActor
    func refreshBooks() async {
        // 检查文件是否存在，移除不存在的书籍
        books.removeAll { !$0.exists }
        saveBooks()
    }
} 
