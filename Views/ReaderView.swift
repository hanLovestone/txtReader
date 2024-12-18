import SwiftUI

// 添加 PreferenceKey 定义
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ReaderView: View {
    let book: Book
    @StateObject private var contentManager: TextContentManager
    @State private var showingSettings = false
    @StateObject private var appState = AppState.shared
    @State private var horizontalDragOffset: CGFloat = 0
    
    init(book: Book) {
        self.book = book
        self._contentManager = StateObject(wrappedValue: try! TextContentManager(filePath: book.filePath))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                appState.readerSettings.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if appState.readerSettings.pageTurnDirection == .horizontal {
                        // 水平翻页模式
                        Text(contentManager.currentPage)
                            .font(.system(size: appState.readerSettings.fontSize))
                            .lineSpacing(appState.readerSettings.lineSpacing)
                            .foregroundColor(appState.readerSettings.textColor)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .offset(x: horizontalDragOffset)
                    } else {
                        // 垂直连续滚动模式
                        ScrollView(.vertical, showsIndicators: true) {
                            Text(contentManager.displayedContent)
                                .font(.system(size: appState.readerSettings.fontSize))
                                .lineSpacing(appState.readerSettings.lineSpacing)
                                .foregroundColor(appState.readerSettings.textColor)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self,
                                                      value: geo.frame(in: .global).minY)
                                    }
                                )
                        }
                        .frame(maxHeight: .infinity)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                            contentManager.updateContent(for: offset, viewportHeight: geometry.size.height)
                        }
                    }
                    
                    // 底部信息栏
                    VStack(spacing: 8) {
                        ProgressView(value: contentManager.getCurrentProgress())
                        Text("\(Int(contentManager.getCurrentProgress() * 100))%")
                            .font(.caption)
                            .foregroundColor(appState.readerSettings.textColor)
                    }
                    .padding()
                }
            }
            .onChange(of: appState.readerSettings.pageTurnDirection) { newValue in
                if newValue == .vertical {
                    contentManager.switchToVerticalMode()
                } else {
                    contentManager.switchToHorizontalMode()
                }
            }
            .contentShape(Rectangle())
            .gesture(appState.readerSettings.pageTurnDirection == .horizontal ?
                DragGesture()
                    .onChanged { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            horizontalDragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if abs(value.translation.width) > abs(value.translation.height) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                if value.translation.width > threshold {
                                    contentManager.previousPage()
                                } else if value.translation.width < -threshold {
                                    contentManager.nextPage()
                                }
                                horizontalDragOffset = 0
                            }
                        }
                    } : nil
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(book.title)
        .navigationBarItems(trailing:
            Button(action: { showingSettings.toggle() }) {
                Image(systemName: "textformat.size")
            }
        )
        .sheet(isPresented: $showingSettings) {
            ReaderSettingsView(settings: appState.readerSettings)
        }
    }
}

#Preview {
    let testContent = """
    这是测试内容
    第二行
    第三行
    这是一个很长的段落，用来测试文本显示是否正常工作。
    """
    
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.txt")
    try? testContent.write(to: tempURL, atomically: true, encoding: .utf8)
    
    return NavigationView {
        ReaderView(book: Book(
            title: "测试书籍",
            filePath: tempURL.path
        ))
    }
} 
