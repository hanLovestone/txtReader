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
    private var lastViewportHeight: CGFloat = 0
    
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
            self.totalPages = ReaderUtils.calculatePageCount(contentLength: content.count, charsPerPage: charsPerPage)
            loadInitialContent()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    static func createWithError(_ message: String) -> TextContentManager {
        let manager = TextContentManager()
        manager.hasError = true
        manager.errorMessage = message
        return manager
    }
    
    private init() {
        self.fileURL = nil
        self.content = ""
        self.totalPages = 0
        self.hasError = true
    }
    
    private func loadInitialContent() {
        let endIndex = min(content.count, initialLoadSize)
        displayedContent = ReaderUtils.extractPage(from: content, start: 0, length: endIndex)
        loadCurrentPage()
    }
    
    func loadCurrentPage() {
        guard !content.isEmpty else {
            currentPage = "文件为空"
            return
        }
        
        currentPage = ReaderUtils.extractPage(from: content, start: currentLocation, length: charsPerPage)
    }
    
    func updateContent(for scrollOffset: CGFloat, viewportHeight: CGFloat) {
        loadTask?.cancel()
        lastViewportHeight = viewportHeight
        
        loadTask = Task { @MainActor in
            let currentTime = CACurrentMediaTime()
            guard currentTime - lastUpdateTime >= minimumUpdateInterval else { return }
            lastUpdateTime = currentTime
            
            let progress = max(0, min(1, -scrollOffset / max(1, viewportHeight)))
            readingProgress = progress
            
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
        
        await Task.detached(priority: .userInitiated) {
            let nextEndIndex = min(self.content.count, currentLength + self.batchSize)
            let newContent = ReaderUtils.extractPage(
                from: self.content,
                start: currentLength,
                length: self.batchSize
            )
            
            await MainActor.run {
                self.displayedContent += newContent
                self.isLoadingMore = false
            }
        }.value
    }
    
    func nextPage() {
        currentLocation = ReaderUtils.getNextPageLocation(
            currentLocation: currentLocation,
            charsPerPage: charsPerPage,
            totalLength: content.count
        )
        loadCurrentPage()
    }
    
    func previousPage() {
        currentLocation = ReaderUtils.getPreviousPageLocation(
            currentLocation: currentLocation,
            charsPerPage: charsPerPage
        )
        loadCurrentPage()
    }
    
    func getCurrentProgress() -> Double {
        if !isVerticalMode {
            return ReaderUtils.calculateProgress(
                currentLocation: currentLocation,
                totalLength: content.count
            )
        } else {
            return readingProgress
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
    
    func jumpToLocation(_ location: Int) {
        if !isVerticalMode {
            // 水平翻页模式
            currentLocation = location
            loadCurrentPage()
        } else {
            // 垂直滚动模式
            currentLocation = location
            updateContent(for: 0, viewportHeight: lastViewportHeight)
        }
    }
}
