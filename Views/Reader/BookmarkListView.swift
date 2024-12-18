import SwiftUI

struct BookmarkListView: View {
    let book: Book
    let onJumpToLocation: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppState.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var showingAddBookmark = false
    @State private var newBookmarkNote = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("当前位置") {
                    Text("阅读进度: \(Int(getCurrentProgress() * 100))%")
                    if let date = book.lastReadDate {
                        Text("最后阅读: \(ReaderUtils.formatDate(date))")
                    }
                }
                
                Section("书签列表") {
                    if bookmarkManager.getBookmarks(for: book.id).isEmpty {
                        Text("暂无书签")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(bookmarkManager.getBookmarks(for: book.id)) { bookmark in
                            Button {
                                onJumpToLocation(bookmark.location)
                                dismiss()
                            } label: {
                                BookmarkRow(bookmark: bookmark)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    bookmarkManager.removeBookmark(bookmark)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("书签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("添加书签") {
                        showingAddBookmark = true
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .alert("添加书签", isPresented: $showingAddBookmark) {
            TextField("备注（可选）", text: $newBookmarkNote)
            Button("取消", role: .cancel) { }
            Button("添加") {
                addBookmark()
                newBookmarkNote = ""
            }
        } message: {
            Text("在当前位置添加书签？")
        }
    }
    
    private func addBookmark() {
        guard let content = try? String(
            contentsOf: URL(fileURLWithPath: book.filePath),
            encoding: .utf8
        ) else { return }
        
        let start = content.index(content.startIndex, offsetBy: book.lastReadLocation)
        let end = content.index(start, offsetBy: min(100, content.count - book.lastReadLocation))
        let preview = String(content[start..<end])
        
        bookmarkManager.addBookmark(
            bookId: book.id,
            location: book.lastReadLocation,
            content: preview,
            note: newBookmarkNote.isEmpty ? nil : newBookmarkNote
        )
    }
    
    private func getCurrentProgress() -> Double {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: book.filePath),
              let fileSize = attributes[.size] as? Int,
              fileSize > 0 else {
            return 0
        }
        return Double(book.lastReadLocation) / Double(fileSize)
    }
}

struct BookmarkRow: View {
    let bookmark: Bookmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(bookmark.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let note = bookmark.note {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(ReaderUtils.formatDate(bookmark.createdAt))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    BookmarkListView(book: Book(
        title: "测试书籍",
        filePath: "test.txt"
    )) { location in
        // 处理跳转到书签位置的逻辑
    }
} 
