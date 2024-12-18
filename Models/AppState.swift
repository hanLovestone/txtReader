import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var bookRepository = BookRepository.shared
    @Published var readerSettings = ReaderSettings.shared
    @Published var bookmarkManager = BookmarkManager.shared
    
    private init() {}
} 
