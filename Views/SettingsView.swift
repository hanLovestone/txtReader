 import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("阅读设置") {
                    Text("字体大小")
                    Text("背景颜色")
                    Text("翻页动画")
                }
                
                Section("关于") {
                    Text("版本 1.0.0")
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingsView()
}
