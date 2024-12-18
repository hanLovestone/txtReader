import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var readerSettings: ReaderSettings
    @Published var bookRepository: BookRepository
    
    private init() {
        self.readerSettings = ReaderSettings.shared
        self.bookRepository = BookRepository.shared
    }
} 
