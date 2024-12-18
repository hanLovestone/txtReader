import Foundation
import SwiftUI

class BookRepository: ObservableObject {
    static let shared = BookRepository()
    private let defaults = UserDefaults.standard
    private let booksKey = "savedBooks"
    
    @Published var books: [Book] = []
    
    private init() {
        loadBooks()
    }
    
    private func loadBooks() {
        if let data = defaults.data(forKey: booksKey),
           let loadedBooks = try? JSONDecoder().decode([Book].self, from: data) {
            self.books = loadedBooks
        }
    }
    
    private func saveBooks() {
        if let data = try? JSONEncoder().encode(books) {
            defaults.set(data, forKey: booksKey)
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
    
    @MainActor
    func refreshBooks() async {
        // 检查文件是否存在，移除不存在的书籍
        books.removeAll { book in
            !FileManager.default.fileExists(atPath: book.filePath)
        }
        saveBooks()
    }
} 
