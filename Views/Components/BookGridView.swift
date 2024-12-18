import SwiftUI

struct BookGridView: View {
    let books: [Book]
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(books) { book in
                    NavigationLink(destination: ReaderView(book: book)) {
                        BookCoverView(book: book)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    BookGridView(books: [])
} 
