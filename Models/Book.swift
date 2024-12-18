import Foundation

struct Book: Codable, Identifiable {
    let id: UUID
    let title: String
    let filePath: String
    let addedDate: Date
    var lastReadLocation: Int
    var lastReadDate: Date?
    
    init(title: String, filePath: String) {
        self.id = UUID()
        self.title = title
        self.filePath = filePath
        self.addedDate = Date()
        self.lastReadLocation = 0
    }
    
    mutating func updateReadingProgress(location: Int) {
        self.lastReadLocation = location
        self.lastReadDate = Date()
    }
}

// 扩展 Book 以添加一些辅助方法
extension Book {
    var exists: Bool {
        FileManager.default.fileExists(atPath: filePath)
    }
    
    var fileSize: Int? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) else {
            return nil
        }
        return attributes[.size] as? Int
    }
    
    var formattedFileSize: String {
        guard let size = fileSize else { return "未知" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
    
    var formattedAddedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: addedDate)
    }
    
    var formattedLastReadDate: String {
        guard let date = lastReadDate else { return "未读" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 
