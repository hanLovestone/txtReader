import Foundation

class BookRepository: ObservableObject {
    static let shared = BookRepository()
    private let db = SQLiteManager.shared
    
    @Published private(set) var books: [Book] = []
    
    private init() {
        loadBooks()
    }
    
    private func loadBooks() {
        let sql = """
            SELECT * FROM books 
            ORDER BY lastReadDate DESC;
        """
        let results = db.query(sql)
        books = results.map { row in
            let id = row["id"] as? String ?? UUID().uuidString
            let title = row["title"] as? String ?? "未知书名"
            let filePath = row["filePath"] as? String ?? ""
            
            return Book(
                id: id,
                title: title,
                author: row["author"] as? String,
                filePath: filePath,
                lastReadDate: (row["lastReadDate"] as? Double).map { Date(timeIntervalSince1970: $0) },
                coverColor: row["coverColor"] as? String,
                chapters: loadChapters(for: id),
                readingProgress: loadReadingProgress(for: id)
            )
        }
    }
    
    private func loadChapters(for bookId: String) -> [Chapter] {
        let sql = """
            SELECT * FROM chapters 
            WHERE bookId = '\(bookId)' 
            ORDER BY startOffset;
        """
        let results = db.query(sql)
        return results.map { row in
            let id = row["id"] as? String ?? UUID().uuidString
            let startOffset = row["startOffset"] as? Int64 ?? 0
            let endOffset = row["endOffset"] as? Int64 ?? 0
            
            return Chapter(
                id: id,
                title: row["title"] as? String,
                startOffset: startOffset,
                endOffset: endOffset,
                bookId: bookId
            )
        }
    }
    
    private func loadReadingProgress(for bookId: String) -> ReadingProgress {
        let sql = """
            SELECT * FROM reading_progress 
            WHERE bookId = '\(bookId)';
        """
        let results = db.query(sql)
        if let row = results.first {
            let currentOffset = row["currentOffset"] as? Int64 ?? 0
            let currentChapterIndex = row["currentChapterIndex"] as? Int64 ?? 0
            
            return ReadingProgress(
                currentOffset: currentOffset,
                currentChapterIndex: Int16(currentChapterIndex),
                lastReadDate: (row["lastReadDate"] as? Double).map { Date(timeIntervalSince1970: $0) },
                bookId: bookId
            )
        } else {
            // 如果没有找到阅读进度，返回初始进度
            return ReadingProgress.createInitial(for: bookId)
        }
    }
    
    func addBook(_ book: Book) {
        let sql = """
            INSERT OR REPLACE INTO books (id, title, author, filePath, lastReadDate, coverColor)
            VALUES (
                '\(book.id)',
                '\(book.title)',
                '\(book.author ?? "")',
                '\(book.filePath)',
                \(book.lastReadDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970),
                '\(book.coverColor ?? "")'
            );
        """
        db.execute(sql)
        
        // 保存章节信息
        for chapter in book.chapters {
            let chapterSql = """
                INSERT OR REPLACE INTO chapters (id, bookId, title, startOffset, endOffset)
                VALUES (
                    '\(chapter.id)',
                    '\(book.id)',
                    '\(chapter.title ?? "")',
                    \(chapter.startOffset),
                    \(chapter.endOffset)
                );
            """
            db.execute(chapterSql)
        }
        
        // 保存阅读进度
        if let progress = book.readingProgress {
            let progressSql = """
                INSERT OR REPLACE INTO reading_progress (
                    bookId, currentOffset, currentChapterIndex, lastReadDate
                )
                VALUES (
                    '\(book.id)',
                    \(progress.currentOffset),
                    \(progress.currentChapterIndex),
                    \(progress.lastReadDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
                );
            """
            db.execute(progressSql)
        }
        
        loadBooks()
    }
    
    func deleteBook(_ book: Book) {
        let sql = "DELETE FROM books WHERE id = '\(book.id)';"
        db.execute(sql)
        loadBooks()
    }
    
    func updateReadingProgress(for bookId: String, progress: ReadingProgress) {
        let sql = """
            INSERT OR REPLACE INTO reading_progress (
                bookId, currentOffset, currentChapterIndex, lastReadDate
            )
            VALUES (
                '\(bookId)',
                \(progress.currentOffset),
                \(progress.currentChapterIndex),
                \(progress.lastReadDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
            );
        """
        db.execute(sql)
        loadBooks()
    }
} 
