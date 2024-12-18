import Foundation
import SwiftUI

class TextContentManager: ObservableObject {
    private let fileURL: URL
    private var content: String = ""
    
    @Published var currentPage: String = ""
    @Published var currentLocation: Int = 0
    @Published var totalPages: Int = 0
    @Published var displayedContent: String = ""
    @Published var readingProgress: Double = 0
    @Published var isVerticalMode: Bool = false
    
    private let charsPerPage: Int = 2000
    private let initialLoadSize: Int = 3000  // 初始加载较小的内容
    private let batchSize: Int = 2000        // 每次增量加载的大小
    private var lastUpdateTime: TimeInterval = 0
    private let minimumUpdateInterval: TimeInterval = 0.3
    private var isLoadingMore = false
    
    init(filePath: String) throws {
        print("初始化TextContentManager: \(filePath)")
        self.fileURL = URL(fileURLWithPath: filePath)
        
        do {
            self.content = try String(contentsOf: fileURL, encoding: .utf8)
            print("文件内容长度: \(self.content.count)")
            self.totalPages = (content.count + charsPerPage - 1) / charsPerPage
            loadInitialContent()
        } catch {
            print("读取文件失败: \(error)")
            self.content = "无法读取文件内容"
            self.displayedContent = self.content
            self.totalPages = 1
        }
    }
    
    private func loadInitialContent() {
        let endIndex = min(content.count, initialLoadSize)
        displayedContent = String(content.prefix(endIndex))
        loadCurrentPage()
    }
    
    private func appendContent() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let currentLength = self.displayedContent.count
            guard currentLength < self.content.count else {
                DispatchQueue.main.async {
                    self.isLoadingMore = false
                }
                return
            }
            
            let nextEndIndex = min(self.content.count, currentLength + self.batchSize)
            let startIndex = self.content.index(self.content.startIndex, offsetBy: currentLength)
            let endIndex = self.content.index(self.content.startIndex, offsetBy: nextEndIndex)
            let newContent = String(self.content[startIndex..<endIndex])
            
            DispatchQueue.main.async {
                self.displayedContent += newContent
                self.isLoadingMore = false
            }
        }
    }
    
    func loadCurrentPage() {
        guard !content.isEmpty else {
            currentPage = "文件为空"
            return
        }
        
        let start = content.index(content.startIndex, offsetBy: min(currentLocation, content.count))
        let end = content.index(start, offsetBy: min(charsPerPage, content.count - currentLocation))
        currentPage = String(content[start..<end])
    }
    
    func updateContent(for scrollOffset: CGFloat, viewportHeight: CGFloat) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastUpdateTime >= minimumUpdateInterval else { return }
        lastUpdateTime = currentTime
        
        let progress = max(0, min(1, -scrollOffset / max(1, viewportHeight)))
        readingProgress = progress
        
        // 当滚动到接近末尾时加载更多内容
        if progress > 0.7 {
            appendContent()
        }
    }
    
    func switchToVerticalMode() {
        isVerticalMode = true
        loadInitialContent()
    }
    
    func switchToHorizontalMode() {
        isVerticalMode = false
        loadCurrentPage()
    }
    
    func nextPage() {
        if currentLocation + charsPerPage < content.count {
            currentLocation += charsPerPage
            loadCurrentPage()
        }
    }
    
    func previousPage() {
        if currentLocation >= charsPerPage {
            currentLocation -= charsPerPage
            loadCurrentPage()
        }
    }
    
    func getCurrentProgress() -> Double {
        if !isVerticalMode {
            return Double(currentLocation) / Double(max(1, content.count))
        } else {
            return readingProgress
        }
    }
} 
