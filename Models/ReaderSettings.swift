import SwiftUI

enum PageTurnDirection: String, CaseIterable {
    case horizontal = "水平翻页"
    case vertical = "垂直滚动"
}

class ReaderSettings: ObservableObject {
    static let shared = ReaderSettings()
    
    @Published var fontSize: CGFloat {
        didSet { saveSettings() }
    }
    
    @Published var lineSpacing: CGFloat {
        didSet { saveSettings() }
    }
    
    @Published var backgroundColor: Color {
        didSet { saveSettings() }
    }
    
    @Published var textColor: Color {
        didSet { saveSettings() }
    }
    
    @Published var pageTurnDirection: PageTurnDirection {
        didSet { saveSettings() }
    }
    
    private let defaults = UserDefaults.standard
    private let fontSizeKey = "readerFontSize"
    private let lineSpacingKey = "readerLineSpacing"
    private let backgroundColorKey = "readerBackgroundColor"
    private let textColorKey = "readerTextColor"
    private let pageTurnDirectionKey = "readerPageTurnDirection"
    
    private init() {
        // 加载或使用默认值
        self.fontSize = defaults.double(forKey: fontSizeKey).nonZero ?? 16
        self.lineSpacing = defaults.double(forKey: lineSpacingKey).nonZero ?? 8
        self.backgroundColor = Color(defaults.color(forKey: backgroundColorKey) ?? .white)
        self.textColor = Color(defaults.color(forKey: textColorKey) ?? .black)
        
        if let directionString = defaults.string(forKey: pageTurnDirectionKey),
           let direction = PageTurnDirection(rawValue: directionString) {
            self.pageTurnDirection = direction
        } else {
            self.pageTurnDirection = .horizontal
        }
    }
    
    private func saveSettings() {
        defaults.set(fontSize, forKey: fontSizeKey)
        defaults.set(lineSpacing, forKey: lineSpacingKey)
        defaults.set(UIColor(backgroundColor), forKey: backgroundColorKey)
        defaults.set(UIColor(textColor), forKey: textColorKey)
        defaults.set(pageTurnDirection.rawValue, forKey: pageTurnDirectionKey)
    }
}

// MARK: - 辅助扩展
private extension Double {
    var nonZero: Double? {
        self == 0 ? nil : self
    }
}

private extension UserDefaults {
    func color(forKey key: String) -> UIColor? {
        guard let colorData = data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
    }
    
    func set(_ color: UIColor?, forKey key: String) {
        guard let color = color,
              let colorData = try? NSKeyedArchiver.archivedData(
                withRootObject: color,
                requiringSecureCoding: true
              ) else { return }
        set(colorData, forKey: key)
    }
} 
