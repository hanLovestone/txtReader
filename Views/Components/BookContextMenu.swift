import SwiftUI

struct BookContextMenu: View {
    let book: Book
    @Binding var showingDetail: Bool
    @Binding var showingDeleteAlert: Bool
    @Binding var showingShareSheet: Bool
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        Menu {
            Button {
                showingDetail = true
            } label: {
                Label("详细信息", systemImage: "info.circle")
            }
            
            Button {
                showingShareSheet = true
            } label: {
                Label("分享", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("删除", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    BookContextMenu(
        book: Book(title: "测试书籍", filePath: "test.txt"),
        showingDetail: .constant(false),
        showingDeleteAlert: .constant(false),
        showingShareSheet: .constant(false)
    )
} 
