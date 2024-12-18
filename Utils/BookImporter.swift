import SwiftUI
import UniformTypeIdentifiers

struct BookImporter: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var bookshelf = Bookshelf.shared
    @State private var showingDocumentPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("选择要导入的TXT文件")
                    .font(.headline)
                    .padding()
                
                Button(action: { showingDocumentPicker = true }) {
                    Label("选择文件", systemImage: "doc.badge.plus")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("导入书籍")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
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
                    bookshelf.addBook(
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

#Preview {
    BookImporter()
} 
