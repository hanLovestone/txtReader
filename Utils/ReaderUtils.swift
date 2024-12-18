import Foundation

enum ReaderUtils {
    static func extractPage(from content: String, start: Int, length: Int) -> String {
        guard !content.isEmpty else { return "" }
        
        let startIndex = content.index(content.startIndex, offsetBy: min(start, content.count))
        let endIndex = content.index(startIndex, offsetBy: min(length, content.count - start))
        return String(content[startIndex..<endIndex])
    }
    
    static func calculatePageCount(contentLength: Int, charsPerPage: Int) -> Int {
        Int(ceil(Double(contentLength) / Double(charsPerPage)))
    }
    
    static func getNextPageLocation(currentLocation: Int, charsPerPage: Int, totalLength: Int) -> Int {
        min(currentLocation + charsPerPage, totalLength)
    }
    
    static func getPreviousPageLocation(currentLocation: Int, charsPerPage: Int) -> Int {
        max(0, currentLocation - charsPerPage)
    }
    
    static func calculateProgress(currentLocation: Int, totalLength: Int) -> Double {
        guard totalLength > 0 else { return 0 }
        return Double(currentLocation) / Double(totalLength)
    }
    
    static func formatFileSize(_ size: Int) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var size = Double(size)
        var unitIndex = 0
        
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.1f %@", size, units[unitIndex])
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    static func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 
