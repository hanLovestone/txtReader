import SwiftUI

struct BookCoverView: View {
    let book: Book
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(book.color)
                .frame(height: 200)
                .overlay(
                    Text(book.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                )
                .shadow(radius: 4)
            
            Text(book.title)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    BookCoverView(book: Book(
        title: "测试书籍",
        filePath: "test.txt",
        coverColor: "blue"
    ))
} 
