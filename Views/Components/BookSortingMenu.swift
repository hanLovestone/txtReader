import SwiftUI

enum BookSortOption: String, CaseIterable {
    case title = "按标题"
    case addedDate = "按添加时间"
    case lastRead = "按最近阅读"
    case fileSize = "按文件大小"
    
    var systemImage: String {
        switch self {
        case .title: return "textformat"
        case .addedDate: return "calendar"
        case .lastRead: return "clock"
        case .fileSize: return "arrow.up.arrow.down"
        }
    }
}

struct BookSortingMenu: View {
    @Binding var sortOption: BookSortOption
    @Binding var ascending: Bool
    
    var body: some View {
        Menu {
            ForEach(BookSortOption.allCases, id: \.self) { option in
                Button {
                    if sortOption == option {
                        ascending.toggle()
                    } else {
                        sortOption = option
                        ascending = true
                    }
                } label: {
                    Label {
                        HStack {
                            Text(option.rawValue)
                            if sortOption == option {
                                Image(systemName: ascending ? "chevron.up" : "chevron.down")
                            }
                        }
                    } icon: {
                        Image(systemName: option.systemImage)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.title2)
        }
    }
} 
