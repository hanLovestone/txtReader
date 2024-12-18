import Foundation
import SwiftUI

class TextContentManager: ObservableObject {
    private let fileURL: URL?
    private var content: String = ""
    
    @Published var currentPage: String = ""
    @Published var currentLocation: Int = 0
    @Published var totalPages: Int = 0
    @Published var displayedContent: String = ""
    @Published var readingProgress: Double = 0
    @Published var isVerticalMode: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    
    private let charsPerPage: Int = 2000
    private let initialLoadSize: Int = 3000
    private let batchSize: Int = 2000
    private var lastUpdateTime: TimeInterval = 0
    private let minimumUpdateInterval: TimeInterval = 0.3
    private var isLoadingMore = false
    
    private var loadTask: Task<Void, Never>?
    
    init(filePath: String) throws {
        print("初始化TextContentManager: \(filePath)")
        self.fileURL = URL(fileURLWithPath: filePath)
        
        do {
            guard let fileURL = self.fileURL else {
                throw NSError(domain: "TextContentManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的文件路径"])
            }
            
            self.content = try String(contentsOf: fileURL, encoding: .utf8)
            print("文件内容长度: \(self.content.count)")
            self.totalPages = (content.count + charsPerPage - 1) / charsPerPage
            loadInitialContent()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // 创建一个带有错误信息的实例
    static func createWithError(_ message: String) -> TextContentManager {
        let manager = TextContentManager()
        manager.hasError = true
        manager.errorMessage = message
        return manager
    }
    
    // 私有初始化方法，用于创建错误实例
    private init() {
        self.fileURL = nil
        self.content = ""
        self.totalPages = 0
        self.hasError = true
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
        // 取消之前的任务
        loadTask?.cancel()
        
        // 创建新任务
        loadTask = Task { @MainActor in
            let currentTime = CACurrentMediaTime()
            guard currentTime - lastUpdateTime >= minimumUpdateInterval else { return }
            lastUpdateTime = currentTime
            
            let progress = max(0, min(1, -scrollOffset / max(1, viewportHeight)))
            readingProgress = progress
            
            // 当滚动到接近末尾时加载更多内容
            if progress > 0.7 {
                await loadMoreContent()
            }
        }
    }
    
    private func loadMoreContent() async {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        let currentLength = displayedContent.count
        guard currentLength < content.count else {
            isLoadingMore = false
            return
        }
        
        // 在后台线程处理文本
        await Task.detached(priority: .userInitiated) {
            let nextEndIndex = min(self.content.count, currentLength + self.batchSize)
            let startIndex = self.content.index(self.content.startIndex, offsetBy: currentLength)
            let endIndex = self.content.index(self.content.startIndex, offsetBy: nextEndIndex)
            let newContent = String(self.content[startIndex..<endIndex])
            
            await MainActor.run {
                self.displayedContent += newContent
                self.isLoadingMore = false
            }
        }.value
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
