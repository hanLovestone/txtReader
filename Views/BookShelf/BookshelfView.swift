import SwiftUI

struct BookshelfView: View {
    @StateObject private var appState = AppState.shared
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if appState.bookRepository.books.isEmpty {
                    EmptyBookshelfView(showingFilePicker: $showingFilePicker)
                } else {
                    ScrollView {
                        BookGridView(books: appState.bookRepository.books)
                    }
                    .refreshable {
                        await appState.bookRepository.refreshBooks()
                    }
                }
            }
            .navigationTitle("我的书架")
            .toolbar {
                if !appState.bookRepository.books.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingFilePicker = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.text],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    let fileName = url.lastPathComponent
                    let destination = getDocumentsDirectory().appendingPathComponent(fileName)
                    
                    // 检查文件是否已存在
                    if FileManager.default.fileExists(atPath: destination.path) {
                        alertMessage = "文件 '\(fileName)' 已存在"
                        showingAlert = true
                        continue
                    }
                    
                    // 检查文件大小
                    let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    if fileSize > 10_000_000 { // 10MB
                        alertMessage = "文件 '\(fileName)' 太大"
                        showingAlert = true
                        continue
                    }
                    
                    try FileManager.default.copyItem(at: url, to: destination)
                    appState.bookRepository.addBook(
                        title: fileName.replacingOccurrences(of: ".txt", with: ""),
                        filePath: destination.path
                    )
                }
            }
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
} 
