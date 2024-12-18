import Foundation
import SwiftUI

struct Book: Identifiable {
    let id: String
    var title: String
    var author: String?
    var filePath: String
    var lastReadDate: Date?
    var coverColor: String?
    var chapters: [Chapter]
    var readingProgress: ReadingProgress?
    
    static let availableColors = [
        "blue": Color.blue,
        "green": Color.green,
        "red": Color.red,
        "purple": Color.purple,
        "orange": Color.orange
    ]
    
    var color: Color {
        if let colorName = coverColor,
           let color = Book.availableColors[colorName] {
            return color
        }
        return .gray
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         author: String? = nil,
         filePath: String,
         lastReadDate: Date? = Date(),
         coverColor: String? = nil,
         chapters: [Chapter] = [],
         readingProgress: ReadingProgress? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.filePath = filePath
        self.lastReadDate = lastReadDate
        self.coverColor = coverColor ?? Book.availableColors.keys.randomElement()
        self.chapters = chapters
        self.readingProgress = readingProgress
    }
} 
