import Foundation
import SQLite3

class SQLiteManager {
    static let shared = SQLiteManager()
    private var db: OpaquePointer?
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("books.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            createTables()
            print("SQLite数据库成功打开: \(fileURL.path)")
        } else {
            print("打开数据库失败")
        }
    }
    
    private func createTables() {
        // 创建books表
        let createBooksTable = """
            CREATE TABLE IF NOT EXISTS books (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                author TEXT,
                filePath TEXT NOT NULL,
                lastReadDate REAL,
                coverColor TEXT
            );
        """
        
        // 创建chapters表
        let createChaptersTable = """
            CREATE TABLE IF NOT EXISTS chapters (
                id TEXT PRIMARY KEY,
                bookId TEXT,
                title TEXT,
                startOffset INTEGER NOT NULL,
                endOffset INTEGER NOT NULL,
                FOREIGN KEY(bookId) REFERENCES books(id)
            );
        """
        
        // 创建reading_progress表
        let createProgressTable = """
            CREATE TABLE IF NOT EXISTS reading_progress (
                bookId TEXT PRIMARY KEY,
                currentOffset INTEGER NOT NULL,
                currentChapterIndex INTEGER NOT NULL,
                lastReadDate REAL,
                FOREIGN KEY(bookId) REFERENCES books(id)
            );
        """
        
        execute(createBooksTable)
        execute(createChaptersTable)
        execute(createProgressTable)
    }
    
    func execute(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("执行SQL失败: \(sql)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    func query(_ sql: String) -> [[String: Any]] {
        var results: [[String: Any]] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var row: [String: Any] = [:]
                let columns = sqlite3_column_count(statement)
                
                for i in 0..<columns {
                    let name = String(cString: sqlite3_column_name(statement, i))
                    let type = sqlite3_column_type(statement, i)
                    
                    switch type {
                    case SQLITE_TEXT:
                        let value = String(cString: sqlite3_column_text(statement, i))
                        row[name] = value
                    case SQLITE_INTEGER:
                        row[name] = sqlite3_column_int64(statement, i)
                    case SQLITE_FLOAT:
                        row[name] = sqlite3_column_double(statement, i)
                    case SQLITE_NULL:
                        row[name] = nil
                    default:
                        break
                    }
                }
                results.append(row)
            }
        }
        sqlite3_finalize(statement)
        return results
    }
} 
