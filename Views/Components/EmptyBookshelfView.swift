import SwiftUI

struct EmptyBookshelfView: View {
    @Binding var showingFilePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("书架空空如也")
                .font(.title2)
                .foregroundColor(.primary)
            
            Text("点击下方按钮添加书籍")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showingFilePicker = true
            } label: {
                Label("添加书籍", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyBookshelfView(showingFilePicker: .constant(false))
} 
