import SwiftUI

struct BookReaderSettings: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: ReaderSettings
    @State private var tempFontSize: CGFloat
    @State private var tempLineSpacing: CGFloat
    @State private var tempBackgroundColor: Color
    @State private var tempTextColor: Color
    @State private var tempPageTurnDirection: PageTurnDirection
    
    init(settings: ReaderSettings) {
        self.settings = settings
        _tempFontSize = State(initialValue: settings.fontSize)
        _tempLineSpacing = State(initialValue: settings.lineSpacing)
        _tempBackgroundColor = State(initialValue: settings.backgroundColor)
        _tempTextColor = State(initialValue: settings.textColor)
        _tempPageTurnDirection = State(initialValue: settings.pageTurnDirection)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("字体设置") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("字体大小: \(Int(tempFontSize))")
                            Spacer()
                            Button("重置") {
                                tempFontSize = 16
                            }
                            .foregroundColor(.blue)
                        }
                        Slider(value: $tempFontSize, in: 12...24, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("行间距: \(Int(tempLineSpacing))")
                            Spacer()
                            Button("重置") {
                                tempLineSpacing = 8
                            }
                            .foregroundColor(.blue)
                        }
                        Slider(value: $tempLineSpacing, in: 4...16, step: 1)
                    }
                }
                
                Section("颜色设置") {
                    ColorPicker("背景颜色", selection: $tempBackgroundColor)
                    ColorPicker("文字颜色", selection: $tempTextColor)
                    Button("恢复默认颜色") {
                        tempBackgroundColor = .white
                        tempTextColor = .black
                    }
                }
                
                Section("翻页方式") {
                    Picker("翻页方式", selection: $tempPageTurnDirection) {
                        ForEach(PageTurnDirection.allCases, id: \.self) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("恢复所有默认设置") {
                        resetAllSettings()
                    }
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        settings.fontSize = tempFontSize
        settings.lineSpacing = tempLineSpacing
        settings.backgroundColor = tempBackgroundColor
        settings.textColor = tempTextColor
        settings.pageTurnDirection = tempPageTurnDirection
    }
    
    private func resetAllSettings() {
        tempFontSize = 16
        tempLineSpacing = 8
        tempBackgroundColor = .white
        tempTextColor = .black
        tempPageTurnDirection = .horizontal
    }
}

#Preview {
    BookReaderSettings(settings: ReaderSettings.shared)
} 
