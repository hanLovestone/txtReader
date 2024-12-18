import SwiftUI

struct BookProgressView: View {
    let progress: Double
    let showPercentage: Bool
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: Double,
        showPercentage: Bool = true,
        height: CGFloat = 2,
        backgroundColor: Color = .gray.opacity(0.2),
        foregroundColor: Color = .blue
    ) {
        self.progress = max(0, min(1, progress))
        self.showPercentage = showPercentage
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(backgroundColor)
                    
                    Rectangle()
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: height)
            .cornerRadius(height / 2)
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BookProgressView(progress: 0.3)
        BookProgressView(progress: 0.7, height: 4, foregroundColor: .green)
        BookProgressView(progress: 0.5, showPercentage: false)
    }
    .padding()
} 
