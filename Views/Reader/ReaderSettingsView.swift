import SwiftUI

struct ReaderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: ReaderSettings
    
    var body: some View {
        NavigationView {
            Form {
                Section("字体大小") {
                    HStack {
                        Slider(value: $settings.fontSize, in: 12...24, step: 1)
                        Text("\(Int(settings.fontSize))")
                    }
                }
                
                Section("行间距") {
                    HStack {
                        Slider(value: $settings.lineSpacing, in: 4...16, step: 1)
                        Text("\(Int(settings.lineSpacing))")
                    }
                }
                
                Section("翻页方式") {
                    Picker("翻页方式", selection: $settings.pageTurnDirection) {
                        ForEach(PageTurnDirection.allCases, id: \.self) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("背景颜色") {
                    ColorPicker("选择背景颜色", selection: $settings.backgroundColor)
                }
                
                Section("文字颜色") {
                    ColorPicker("选择文字颜色", selection: $settings.textColor)
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ReaderSettingsView(settings: ReaderSettings.shared)
} 
