import SwiftUI

struct BookGridView: View {
    let books: [Book]
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(books) { book in
                NavigationLink(destination: ReaderView(book: book)) {
                    BookCoverView(book: book)
                }
            }
        }
        .padding()
    }
}

#Preview {
    BookGridView(books: [
        Book(title: "测试书籍1", filePath: "test1.txt"),
        Book(title: "测试书籍2", filePath: "test2.txt")
    ])
} 
