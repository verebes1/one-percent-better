////
////  InteractiveGraph.swift
////  one-percent-better
////
////  Created by Jeremy Cook on 11/13/22.
////
//
//import SwiftUI
//import Charts
//
//
//struct InteractiveGraph: View {
//   
//   struct ChartPosition {
//      var date: Date
//      var value: Double
//   }
//   
//   @State var position: ChartPosition?
//   
//   var body: some View {
//      Chart {
//         ForEach(session!.heightData) { height in
//            AreaMark(
//               x: .value("Time", height.time.start),
//               y: .value("Height", height.height.doubleValue(for: diveManager.heightUnit))
//            )
//         }
//         if let position = position {
//            RuleMark(x: .value("Time", position.x))
//               .foregroundStyle(.orange.opacity(0.5))
//            RuleMark(y: .value("Height", position.y))
//               .foregroundStyle(.orange.opacity(0.5))
//            PointMark(x: .value("Time", position.x), y: .value("Height", position.y))
//               .foregroundStyle(.orange)
//               .symbol(BasicChartSymbolShape.circle.strokeBorder(lineWidth: 3.0))
//               .symbolSize(250)
//         }
//      }
//      .chartOverlay { proxy in
//         GeometryReader { geometry in
//            Rectangle().fill(.clear).contentShape(Rectangle())
//               .gesture(DragGesture().onChanged { value in updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy) })
//               .onTapGesture { location in updateCursorPosition(at: location, geometry: geometry, proxy: proxy) }
//         }
//      }
//   }
//   
//   func updateCursorPosition(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
//      let data = session!.heightData
//      let origin = geometry[proxy.plotAreaFrame].origin
//      let datePos = proxy.value(atX: at.x - origin.x, as: Date.self)
//      let firstGreater = data.lastIndex(where: { $0.time.start < datePos! })
//      if let index = firstGreater {
//         let time = data[index].time.start
//         let height = data[index].height.doubleValue(for: diveManager.heightUnit)
//         position = ChartPosition(x: time, y: height)
//      }
//   }
//}
//
//struct InteractiveGraph_Previews: PreviewProvider {
//   static var previews: some View {
//      InteractiveGraph()
//   }
//}
