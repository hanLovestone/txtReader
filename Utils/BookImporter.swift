import Foundation

class BookImporter: ObservableObject {
    enum ImportError: Error {
        case invalidFile
        case accessDenied
        case importFailed
    }
    
    func importBook(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard url.startAccessingSecurityScopedResource() else {
            completion(.failure(ImportError.accessDenied))
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            // 创建目标文件夹
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let booksFolder = documentsURL.appendingPathComponent("Books")
            try FileManager.default.createDirectory(at: booksFolder, withIntermediateDirectories: true)
            
            // 复制文件到应用沙盒
            let fileName = url.lastPathComponent
            let destinationURL = booksFolder.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // 创建Book对象
            let book = Book(
                title: fileName.replacingOccurrences(of: ".txt", with: ""),
                filePath: destinationURL.path,
                coverColor: ["blue", "green", "red", "purple", "orange"].randomElement()
            )
            
            // 保存到数据库
            BookRepository.shared.addBook(book)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
} 
