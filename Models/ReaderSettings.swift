import SwiftUI

enum PageTurnDirection: String, CaseIterable {
    case horizontal = "左右滑动"
    case vertical = "上下滑动"
}

class ReaderSettings: ObservableObject {
    static let shared = ReaderSettings()
    
    @Published var fontSize: CGFloat {
        didSet { UserDefaults.standard.set(fontSize, forKey: "fontSize") }
    }
    
    @Published var lineSpacing: CGFloat {
        didSet { UserDefaults.standard.set(lineSpacing, forKey: "lineSpacing") }
    }
    
    @Published var pageTurnDirection: PageTurnDirection {
        didSet { UserDefaults.standard.set(pageTurnDirection.rawValue, forKey: "pageTurnDirection") }
    }
    
    @Published var backgroundColor: Color {
        didSet {
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(backgroundColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "backgroundColor")
            }
        }
    }
    
    @Published var textColor: Color {
        didSet {
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(textColor), requiringSecureCoding: false) {
                UserDefaults.standard.set(colorData, forKey: "textColor")
            }
        }
    }
    
    private init() {
        self.fontSize = UserDefaults.standard.object(forKey: "fontSize") as? CGFloat ?? 16
        self.lineSpacing = UserDefaults.standard.object(forKey: "lineSpacing") as? CGFloat ?? 8
        self.pageTurnDirection = PageTurnDirection(rawValue: UserDefaults.standard.string(forKey: "pageTurnDirection") ?? "") ?? .horizontal
        
        if let colorData = UserDefaults.standard.data(forKey: "backgroundColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            self.backgroundColor = Color(color)
        } else {
            self.backgroundColor = .white
        }
        
        if let colorData = UserDefaults.standard.data(forKey: "textColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            self.textColor = Color(color)
        } else {
            self.textColor = .black
        }
    }
} 
