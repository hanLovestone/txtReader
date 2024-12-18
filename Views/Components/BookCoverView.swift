import SwiftUI

struct BookCoverView: View {
    let book: Book
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .overlay(
                    Text(book.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                )
            
            Text(book.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
    }
}

#Preview {
    BookCoverView(book: Book(
        title: "测试书籍",
        filePath: "test.txt"
    ))
} 
