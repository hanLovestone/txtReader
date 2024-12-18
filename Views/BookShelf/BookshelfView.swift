import SwiftUI

struct BookshelfView: View {
    @StateObject private var appState = AppState.shared
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !appState.bookRepository.books.isEmpty {
                    BookSearchBar(searchText: $searchText)
                        .padding(.vertical, 8)
                }
                
                Group {
                    if appState.bookRepository.books.isEmpty {
                        EmptyBookshelfView(showingFilePicker: $showingFilePicker)
                    } else {
                        ScrollView {
                            BookGridView(
                                books: appState.bookRepository.filteredAndSortedBooks(
                                    searchText: searchText
                                )
                            )
                        }
                        .refreshable {
                            await appState.bookRepository.refreshBooks()
                        }
                    }
                }
            }
            .navigationTitle("我的书架")
            .toolbar {
                if !appState.bookRepository.books.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            BookSortingMenu(
                                sortOption: $appState.bookRepository.sortOption,
                                ascending: $appState.bookRepository.sortAscending
                            )
                            Button(action: { showingFilePicker = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
        .background(
            BookImporter(
                isPresented: $showingFilePicker,
                showingAlert: $showingAlert,
                alertMessage: $alertMessage
            )
        )
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
} 
