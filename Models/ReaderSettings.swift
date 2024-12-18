import SwiftUI

enum PageTurnDirection: String, CaseIterable {
    case horizontal = "左右滑动"
    case vertical = "上下滑动"
}

class ReaderSettings: ObservableObject {
    @Published var fontSize: CGFloat = 18
    @Published var lineSpacing: CGFloat = 8
    @Published var backgroundColor: Color = .white
    @Published var textColor: Color = .black
    @Published var pageTurnDirection: PageTurnDirection = .horizontal
    
    static let shared = ReaderSettings()
    
    private init() {}
} 
