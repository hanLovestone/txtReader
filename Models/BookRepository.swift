import Foundation

class BookRepository: ObservableObject {
    static let shared = BookRepository()
    
    @Published private(set) var books: [Book] = []
    @Published var sortOption: BookSortOption = .addedDate
    @Published var sortAscending: Bool = false
    
    private let booksKey = "savedBooks"
    private let sortOptionKey = "bookSortOption"
    private let sortAscendingKey = "bookSortAscending"
    
    private init() {
        loadBooks()
        loadSortPreferences()
    }
    
    private func loadSortPreferences() {
        if let optionString = UserDefaults.standard.string(forKey: sortOptionKey),
           let option = BookSortOption(rawValue: optionString) {
            sortOption = option
        }
        sortAscending = UserDefaults.standard.bool(forKey: sortAscendingKey)
    }
    
    private func saveSortPreferences() {
        UserDefaults.standard.set(sortOption.rawValue, forKey: sortOptionKey)
        UserDefaults.standard.set(sortAscending, forKey: sortAscendingKey)
    }
    
    var sortedBooks: [Book] {
        books.sorted { book1, book2 in
            let result: Bool
            switch sortOption {
            case .title:
                result = book1.title.localizedCompare(book2.title) == .orderedAscending
            case .addedDate:
                result = book1.addedDate < book2.addedDate
            case .lastRead:
                switch (book1.lastReadDate, book2.lastReadDate) {
                case (nil, nil): result = false
                case (nil, _): result = false
                case (_, nil): result = true
                case (let date1?, let date2?): result = date1 > date2
                }
            case .fileSize:
                let size1 = book1.fileSize ?? 0
                let size2 = book2.fileSize ?? 0
                result = size1 < size2
            }
            return sortAscending ? result : !result
        }
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
    
    func filteredAndSortedBooks(searchText: String) -> [Book] {
        let filtered = searchText.isEmpty ? books : books.filter { book in
            book.title.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { book1, book2 in
            let result: Bool
            switch sortOption {
            case .title:
                result = book1.title.localizedCompare(book2.title) == .orderedAscending
            case .addedDate:
                result = book1.addedDate < book2.addedDate
            case .lastRead:
                switch (book1.lastReadDate, book2.lastReadDate) {
                case (nil, nil): result = false
                case (nil, _): result = false
                case (_, nil): result = true
                case (let date1?, let date2?): result = date1 > date2
                }
            case .fileSize:
                let size1 = book1.fileSize ?? 0
                let size2 = book2.fileSize ?? 0
                result = size1 < size2
            }
            return sortAscending ? result : !result
        }
    }
} 
