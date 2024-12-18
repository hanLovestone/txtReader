import Foundation

struct ReadingProgress {
    var currentOffset: Int64
    var currentChapterIndex: Int16
    var lastReadDate: Date?
    var bookId: String
    
    init(currentOffset: Int64 = 0,
         currentChapterIndex: Int16 = 0,
         lastReadDate: Date? = Date(),
         bookId: String) {
        self.currentOffset = currentOffset
        self.currentChapterIndex = currentChapterIndex
        self.lastReadDate = lastReadDate
        self.bookId = bookId
    }
    
    // 添加一个便利初始化方法，用于创建新书的初始进度
    static func createInitial(for bookId: String) -> ReadingProgress {
        ReadingProgress(
            currentOffset: 0,
            currentChapterIndex: 0,
            lastReadDate: Date(),
            bookId: bookId
        )
    }
} 
