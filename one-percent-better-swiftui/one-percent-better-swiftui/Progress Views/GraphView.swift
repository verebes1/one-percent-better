//
//  GraphView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/14/22.
//

import SwiftUI

struct GraphView: UIViewRepresentable {

    var graphData: GraphData
    
    func makeUIView(context: UIViewRepresentableContext<GraphView>) -> UIView {
        let graphView = GraphUIKitView(frame: .zero)
//        graphView.backgroundColor = .red
        graphView.backgroundColor = .white
        graphView.configure(graphData: graphData)
        return graphView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphView>) {
        if let graphView = uiView as? GraphUIKitView {
            print("configuring graph view")
            
            graphData.updateRange(endDate: Date(), numDaysBefore: 7)
            graphView.configure(graphData: graphData)
        }
//        uiView.text = text
    }
}

struct GraphView_Previews: PreviewProvider {
    
    static func data() -> GraphData {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        if let h1 = h1 {
            let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
            t1.add(date: day0, value: "3")
            t1.add(date: day1, value: "2")
            t1.add(date: day2, value: "1")
        }
        
        let habits = Habit.habitList(from: context)
        let habit = habits.first!
        let graphTracker = habit.trackers.firstObject as! GraphTracker
        let graphData = GraphData(graphTracker: graphTracker)
        return graphData
    }
    
    static var previews: some View {
        let graphData = data()
        VStack {
            Text("All dates: \(String(describing: graphData.allDates))")
            GraphView(graphData: graphData)
                .frame(width: 330, height: 300)
//                .background(.blue)
            Text("All values: \(String(describing: graphData.allValues))")
        }
    }
}
