import Foundation

enum ReaderUtils {
    static func calculateProgress(currentLocation: Int, totalLength: Int) -> Double {
        guard totalLength > 0 else { return 0 }
        return Double(currentLocation) / Double(totalLength)
    }
    
    static func formatProgress(_ progress: Double) -> String {
        return "\(Int(progress * 100))%"
    }
    
    static func calculatePageCount(contentLength: Int, charsPerPage: Int) -> Int {
        return (contentLength + charsPerPage - 1) / charsPerPage
    }
    
    static func getNextPageLocation(currentLocation: Int, charsPerPage: Int, totalLength: Int) -> Int {
        return min(currentLocation + charsPerPage, totalLength)
    }
    
    static func getPreviousPageLocation(currentLocation: Int, charsPerPage: Int) -> Int {
        return max(currentLocation - charsPerPage, 0)
    }
    
    static func extractPage(from content: String, start: Int, length: Int) -> String {
        guard !content.isEmpty else { return "" }
        let startIndex = content.index(content.startIndex, offsetBy: min(start, content.count))
        let endIndex = content.index(startIndex, offsetBy: min(length, content.count - start))
        return String(content[startIndex..<endIndex])
    }
} 
