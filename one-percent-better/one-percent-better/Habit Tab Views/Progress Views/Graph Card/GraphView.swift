//
//  GraphView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/14/22.
//

import SwiftUI

struct GraphView: UIViewRepresentable {

    var graphData: GraphData
    var numDays: Int
    @Binding var selectedValue: String
    
    func makeUIView(context: UIViewRepresentableContext<GraphView>) -> UIView {
        let graphView = GraphUIKitView(frame: .zero)
        graphView.backgroundColor = UIColor(Color.cardColor)
        graphView.delegate = context.coordinator
        return graphView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphView>) {
        if let graphView = uiView as? GraphUIKitView {
            graphData.updateRange(endDate: Date(), numDaysBefore: numDays)
            graphView.configure(graphData: graphData)
        }
    }
    
    func makeCoordinator() -> GraphViewCoordinator {
        return GraphViewCoordinator(selectedValue: $selectedValue)
    }
    
    class GraphViewCoordinator: UpdateGraphValueDelegate {
        
        @Binding var selectedValue: String
        
        init(selectedValue: Binding<String>) {
            self._selectedValue = selectedValue
        }
        
        func update(to value: String) {
            selectedValue = value
        }
        
    }
}

struct GraphView_Previews: PreviewProvider {
    
    @State static var selectedValue: String = ""
    
    static func data() -> GraphData {
        let context = CoreDataManager.previews.mainContext
        
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
        
        let habits = Habit.habits(from: context)
        let habit = habits.first!
        let graphTracker = habit.trackers.firstObject as! GraphTracker
        let graphData = GraphData(graphTracker: graphTracker)
        return graphData
    }
    
    static var previews: some View {
        let graphData = data()
        VStack {
            Text("Selected value: \(selectedValue)")
            GraphView(graphData: graphData, numDays: 7, selectedValue: $selectedValue)
                .preferredColorScheme(.light)
                .frame(height: 300)
                .padding(.horizontal, 20)
            .border(.black)
        }
    }
}
