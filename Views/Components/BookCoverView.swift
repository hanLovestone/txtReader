import SwiftUI

struct BookCoverView: View {
    let book: Book
    @State private var showingDetail = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            BookContextMenu(
                                book: book,
                                showingDetail: $showingDetail,
                                showingDeleteAlert: $showingDeleteAlert,
                                showingShareSheet: $showingShareSheet
                            )
                            .padding(8)
                        }
                        Spacer()
                        Text(book.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        if let progress = calculateProgress() {
                            BookProgressView(
                                progress: progress,
                                showPercentage: false,
                                height: 3,
                                backgroundColor: .gray.opacity(0.1),
                                foregroundColor: .blue.opacity(0.8)
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                )
            
            Text(book.filePath)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
        .onLongPressGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            BookDetailView(book: book)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: book.filePath) {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let index = appState.bookRepository.books.firstIndex(where: { $0.id == book.id }) {
                    appState.bookRepository.removeBook(at: IndexSet(integer: index))
                }
            }
        } message: {
            Text("确定要删除这本书吗？此操作无法撤销。")
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
}

#Preview {
    BookCoverView(book: Book(
        title: "测试书籍",
        filePath: "test.txt"
    ))
} 
