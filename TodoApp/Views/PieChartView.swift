import SwiftUI

struct PieSliceData {
    var startAngle: Double
    var endAngle: Double
    var color: Color
    var value: Int
    var title: String
}

struct PieSlice: Shape {
    var pieSliceData: PieSliceData
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + radius * CGFloat(cos(pieSliceData.startAngle * .pi / 180)),
            y: center.y + radius * CGFloat(sin(pieSliceData.startAngle * .pi / 180))
        )
        
        var path = Path()
        path.move(to: center)
        path.addLine(to: start)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: Angle(degrees: pieSliceData.startAngle),
                   endAngle: Angle(degrees: pieSliceData.endAngle),
                   clockwise: false)
        path.addLine(to: center)
        
        return path
    }
}

struct PieChartView: View {
    var slices: [PieSliceData]
    var totalValue: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                ForEach(0..<slices.count, id: \.self) { index in
                    PieSlice(pieSliceData: slices[index])
                        .fill(slices[index].color)
                        .accessibilityIdentifier("pieSlice_\(slices[index].title)")
                }
            }
            .frame(width: min(geometry.size.width, geometry.size.height),
                   height: min(geometry.size.width, geometry.size.height))
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .accessibilityIdentifier("pieChartContainer")
        }
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(slices: [
            PieSliceData(startAngle: 0, endAngle: 120, color: .red, value: 3, title: "Yüksek"),
            PieSliceData(startAngle: 120, endAngle: 240, color: .orange, value: 2, title: "Orta"),
            PieSliceData(startAngle: 240, endAngle: 360, color: .blue, value: 1, title: "Düşük")
        ], totalValue: 6)
        .frame(width: 200, height: 200)
        .padding()
    }
}
