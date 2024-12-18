import SwiftUI
import UniformTypeIdentifiers

struct BookImporter: View {
    @Binding var isPresented: Bool
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        EmptyView()
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [.text],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    try importFile(from: url)
                }
            }
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func importFile(from url: URL) throws {
        let fileName = url.lastPathComponent
        let destination = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // 检查文件是否已存在
        if FileManager.default.fileExists(atPath: destination.path) {
            throw ImportError.fileExists(fileName)
        }
        
        // 检查文件大小
        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        if fileSize > 10_000_000 { // 10MB
            throw ImportError.fileTooLarge(fileName)
        }
        
        // 检查文件编码
        guard let _ = try? String(contentsOf: url, encoding: .utf8) else {
            throw ImportError.invalidEncoding(fileName)
        }
        
        try FileManager.default.copyItem(at: url, to: destination)
        appState.bookRepository.addBook(
            title: fileName.replacingOccurrences(of: ".txt", with: ""),
            filePath: destination.path
        )
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

enum ImportError: LocalizedError {
    case fileExists(String)
    case fileTooLarge(String)
    case invalidEncoding(String)
    
    var errorDescription: String? {
        switch self {
        case .fileExists(let name):
            return "文件 '\(name)' 已存在"
        case .fileTooLarge(let name):
            return "文件 '\(name)' 太大"
        case .invalidEncoding(let name):
            return "文件 '\(name)' 编码不支持"
        }
    }
}

#Preview {
    BookImporter(isPresented: .constant(false), showingAlert: .constant(false), alertMessage: .constant(""))
} 
