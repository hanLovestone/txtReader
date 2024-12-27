import SwiftUI

struct BookshelfView: View {
    @StateObject private var appState = AppState.shared
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    
    private var filteredBooks: [Book] {
        if searchText.isEmpty {
            return appState.bookRepository.books
        } else {
            return appState.bookRepository.books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !appState.bookRepository.books.isEmpty {
                    BookSearchBar(searchText: $searchText)
                        .padding(.vertical, 8)
                }
                
                if appState.bookRepository.books.isEmpty {
                    EmptyBookshelfView(showingFilePicker: $showingFilePicker)
                } else if filteredBooks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 160), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(filteredBooks) { book in
                                NavigationLink {
                                    ReaderView(book: book)
                                } label: {
                                    BookCoverView(book: book)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("书架")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilePicker = true
                    } label: {
                        Image(systemName: "plus")
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
} 
