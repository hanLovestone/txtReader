import SwiftUI

struct BookProgressView: View {
    let progress: Double
    var showPercentage: Bool = true
    var height: CGFloat = 2
    var backgroundColor: Color = .gray.opacity(0.1)
    var foregroundColor: Color = .blue.opacity(0.8)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: height)
                
                Rectangle()
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progress, height: height)
                
                if showPercentage {
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(y: -16)
                }
            }
        }
        .frame(height: showPercentage ? 24 : height)
    }
}

#Preview {
    VStack(spacing: 20) {
        BookProgressView(progress: 0.75)
            .padding()
        
        BookProgressView(
            progress: 0.3,
            showPercentage: false,
            height: 4,
            backgroundColor: .red.opacity(0.1),
            foregroundColor: .red.opacity(0.8)
        )
        .padding()
    }
} 
