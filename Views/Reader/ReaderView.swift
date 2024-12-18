import SwiftUI

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
        do {
            let manager = try TextContentManager(filePath: book.filePath)
            manager.currentLocation = book.lastReadLocation
            self._contentManager = StateObject(wrappedValue: manager)
        } catch {
            let errorManager = TextContentManager.createWithError(
                "无法加载文件: \(error.localizedDescription)"
            )
            self._contentManager = StateObject(wrappedValue: errorManager)
        }
    }
    
    private func makeVerticalContent() -> some View {
        Text(contentManager.displayedContent)
            .font(.system(size: appState.readerSettings.fontSize))
            .lineSpacing(appState.readerSettings.lineSpacing)
            .foregroundColor(appState.readerSettings.textColor)
    }
    
    private func makeHorizontalContent() -> some View {
        Text(contentManager.currentPage)
            .font(.system(size: appState.readerSettings.fontSize))
            .lineSpacing(appState.readerSettings.lineSpacing)
            .foregroundColor(appState.readerSettings.textColor)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: horizontalDragOffset)
    }
    
    private func makeScrollViewContent(geometry: GeometryProxy) -> some View {
        makeVerticalContent()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .global).minY
                        )
                        .onAppear {
                            contentManager.updateContent(
                                for: 0,
                                viewportHeight: geometry.size.height
                            )
                        }
                }
            )
    }
    
    private func makeBottomToolbar() -> some View {
        VStack(spacing: 8) {
            BookProgressView(
                progress: contentManager.getCurrentProgress(),
                height: 2,
                backgroundColor: appState.readerSettings.textColor.opacity(0.1),
                foregroundColor: appState.readerSettings.textColor.opacity(0.8)
            )
            
            HStack {
                Text("\(Int(contentManager.getCurrentProgress() * 100))%")
                    .font(.caption2)
                    .foregroundColor(appState.readerSettings.textColor)
                
                Spacer()
                
                BookReaderToolbar(
                    book: book,
                    showingSettings: $showingSettings,
                    onJumpToLocation: { location in
                        contentManager.jumpToLocation(location)
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(appState.readerSettings.backgroundColor)
    }
    
    private func makeErrorView() -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(contentManager.errorMessage)
                .foregroundColor(.red)
                .padding()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                appState.readerSettings.backgroundColor
                    .ignoresSafeArea()
                
                if contentManager.hasError {
                    makeErrorView()
                } else {
                    VStack(spacing: 0) {
                        if appState.readerSettings.pageTurnDirection == .horizontal {
                            makeHorizontalContent()
                        } else {
                            ScrollView(.vertical, showsIndicators: false) {
                                makeScrollViewContent(geometry: geometry)
                            }
                            .frame(maxHeight: .infinity)
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                                contentManager.updateContent(
                                    for: offset,
                                    viewportHeight: geometry.size.height
                                )
                            }
                        }
                        
                        makeBottomToolbar()
                    }
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
            BookReaderSettings(settings: appState.readerSettings)
        }
        .onDisappear {
            appState.bookRepository.updateReadingProgress(
                for: book,
                location: contentManager.currentLocation
            )
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
