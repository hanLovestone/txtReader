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
                Label("查看详情", systemImage: "info.circle")
            }
            
            Button {
                showingShareSheet = true
            } label: {
                Label("分享文件", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("删除书籍", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
        }
    }
} 
