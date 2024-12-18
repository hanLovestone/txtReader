import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var readerSettings = ReaderSettings.shared
    @Published var currentContent: String = ""
    
    private init() {}
} 
