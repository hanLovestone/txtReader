import SwiftUI

struct BookshelfView: View {
    @EnvironmentObject private var bookRepository: BookRepository
    @StateObject private var bookImporter = BookImporter()
    
    @State private var isShowingFileImporter = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if bookRepository.books.isEmpty {
                    EmptyBookshelfView(isShowingFileImporter: $isShowingFileImporter)
                } else {
                    BookGridView(books: bookRepository.books)
                }
            }
            .navigationTitle("我的书架")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingFileImporter = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.text],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
        .alert("提示", isPresented: $isShowingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                bookImporter.importBook(from: url) { result in
                    switch result {
                    case .success:
                        alertMessage = "导入成功"
                    case .failure(let error):
                        alertMessage = "导入失败：\(error.localizedDescription)"
                    }
                    isShowingAlert = true
                }
            }
        case .failure(let error):
            alertMessage = "选择文件失败：\(error.localizedDescription)"
            isShowingAlert = true
        }
    }
}

#Preview {
    BookshelfView()
        .environmentObject(BookRepository.shared)
} 
