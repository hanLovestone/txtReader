import SwiftUI

struct EmptyBookshelfView: View {
    @Binding var showingFilePicker: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("书架空空如也")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button(action: { showingFilePicker = true }) {
                Text("添加书籍")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    EmptyBookshelfView(showingFilePicker: .constant(false))
} 
