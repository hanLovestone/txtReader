import SwiftUI

struct EmptyBookshelfView: View {
    @Binding var isShowingFileImporter: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("书架空空如也")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button(action: { isShowingFileImporter = true }) {
                Label("添加书籍", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
        }
    }
} 
