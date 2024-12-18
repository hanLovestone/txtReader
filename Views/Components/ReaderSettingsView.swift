import SwiftUI

struct ReaderSettingsView: View {
    @ObservedObject var settings: ReaderSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("翻页方式") {
                    Picker("翻页方向", selection: $settings.pageTurnDirection) {
                        ForEach(PageTurnDirection.allCases, id: \.self) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("字体") {
                    VStack(alignment: .leading) {
                        Text("字体大小: \(Int(settings.fontSize))")
                        Slider(value: $settings.fontSize, in: 12...24, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("行间距: \(Int(settings.lineSpacing))")
                        Slider(value: $settings.lineSpacing, in: 4...16, step: 1)
                    }
                }
                
                Section("颜色") {
                    ColorPicker("背景颜色", selection: $settings.backgroundColor)
                    ColorPicker("文���颜色", selection: $settings.textColor)
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("完成") {
                    dismiss()
                }
            )
        }
        .frame(maxHeight: 400)
    }
}

#Preview {
    ReaderSettingsView(settings: ReaderSettings.shared)
} 
