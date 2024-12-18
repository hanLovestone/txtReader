import Foundation

struct Chapter: Identifiable {
    let id: String
    var title: String?
    var startOffset: Int64
    var endOffset: Int64
    var bookId: String
    
    init(id: String = UUID().uuidString,
         title: String? = nil,
         startOffset: Int64,
         endOffset: Int64,
         bookId: String) {
        self.id = id
        self.title = title
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.bookId = bookId
    }
} 
