import SwiftUI

struct BookDetailView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppState.shared
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section("基本信息") {
                    LabeledContent("标题", value: book.title)
                    LabeledContent("文件大小", value: book.formattedFileSize)
                    LabeledContent("添加时间", value: book.formattedAddedDate)
                    LabeledContent("文件路径", value: book.filePath)
                }
                
                Section("阅读记录") {
                    LabeledContent("最后阅读时间", value: book.formattedLastReadDate)
                    if let progress = calculateProgress() {
                        LabeledContent("阅读进度", value: "\(Int(progress * 100))%")
                    }
                }
                
                Section {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("分享文件", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("删除书籍", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("书籍详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteBook()
                dismiss()
            }
        } message: {
            Text("确定要删除这本书吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: book.filePath) {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func calculateProgress() -> Double? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: book.filePath),
              let fileSize = attributes[.size] as? Int,
              fileSize > 0 else {
            return nil
        }
        return Double(book.lastReadLocation) / Double(fileSize)
    }
    
    private func deleteBook() {
        if let index = appState.bookRepository.books.firstIndex(where: { $0.id == book.id }) {
            appState.bookRepository.removeBook(at: IndexSet(integer: index))
        }
    }
}

// 用于分享文件的 UIKit 包装器
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.txt")
    try? "测试内容".write(to: tempURL, atomically: true, encoding: .utf8)
    
    return BookDetailView(book: Book(
        title: "测试书籍",
        filePath: tempURL.path
    ))
} 
