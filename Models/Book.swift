import Foundation
import SwiftUI

struct Book: Identifiable, Codable {
    let id: UUID
    let title: String
    let filePath: String
    
    init(title: String, filePath: String) {
        self.id = UUID()
        self.title = title
        self.filePath = filePath
    }
}

extension Book {
    static var preview: Book {
        Book(title: "测试书籍", filePath: "test.txt")
    }
}
