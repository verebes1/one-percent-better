//
//  CreateTimeTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/30/22.
//

import SwiftUI

struct CreateTimeTracker: View {
   
   @Environment(\.managedObjectContext) var moc
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habit: Habit
   
   @State var hourSelection: Int = 0
   @State var minuteSelection: Int = 0
   
   @State private var selections: [Int] = [0, 10, 0]
   
   @State var zeroTimeError: Bool = false
   
   @State var uiTabarController: UITabBarController?
   
   var body: some View {
      Background {
         VStack {
            HabitCreationHeader(systemImage: "timer",
                                title: "Time",
                                subtitle: "Track how long you spend doing your habit")
            
            Spacer()
               .frame(height: 10)
            
            CardView {
               TimePicker(selections: $selections)
            }
            .frame(height: 250)
            
            if zeroTimeError {
               Label("Goal time can't be 0", systemImage: "exclamationmark.triangle")
                  .foregroundColor(.red)
                  .animation(.easeInOut, value: zeroTimeError)
            }
            
            Spacer()
            
            Button {
               let timeInSec = selections[0] * 3600 + selections[1] * 60 + selections[2]
               if timeInSec == 0 {
                  zeroTimeError = true
               } else {
                  let _ = TimeTracker(context: moc, habit: habit, goalTime: timeInSec)
                  try? moc.save()
                  nav.path.removeLast(2)
               }
            } label: {
                Text("Create")
            }
            .buttonStyle(.wideAccent)
         }
      }
      .onDisappear{
         uiTabarController?.tabBar.isHidden = false
      }
   }
}

struct CreateTimeTracker_Previews: PreviewProvider {
   
   @State static var rootPresenting: Bool = false
   
   static var previews: some View {
      let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
      let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
      CreateTimeTracker(habit: habit)
   }
}


struct PickerView: UIViewRepresentable {
   var data: [[String]]
   @Binding var selections: [Int]
   
   //makeCoordinator()
   func makeCoordinator() -> PickerView.Coordinator {
      Coordinator(self)
   }
   
   //makeUIView(context:)
   func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
      let picker = UIPickerView(frame: .zero)
      
      picker.dataSource = context.coordinator
      picker.delegate = context.coordinator
      
      //        let hours = UILabel()
      //        hours.text = "hours"
      //        let minutes = UILabel()
      //        minutes.text = "minutes"
      //        let sec = UILabel()
      //        sec.text = "sec"
      //        picker.setPickerLabels(labels: [0 : hours, 1: minutes, 2: sec], width: 380)
      
      return picker
   }
   
   //updateUIView(_:context:)
   func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
      for i in 0...(self.selections.count - 1) {
         view.selectRow(self.selections[i], inComponent: i, animated: false)
      }
   }
   
   class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
      var parent: PickerView
      
      //init(_:)
      init(_ pickerView: PickerView) {
         self.parent = pickerView
      }
      
      //numberOfComponents(in:)
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return self.parent.data.count
      }
      
      //pickerView(_:numberOfRowsInComponent:)
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return self.parent.data[component].count
      }
      
      //pickerView(_:titleForRow:forComponent:)
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return self.parent.data[component][row]
      }
      
      //pickerView(_:didSelectRow:inComponent:)
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         self.parent.selections[component] = row
      }
   }
}

extension UIPickerView {
   
   func setPickerLabels(labels: [Int:UILabel], width: CGFloat) { // [component number:label]
      
      let fontSize:CGFloat = 20
      let labelWidth:CGFloat = width / CGFloat(self.numberOfComponents)
      let x:CGFloat = self.frame.origin.x
      let y:CGFloat = (self.frame.size.height / 2) - (fontSize / 2)
      
      for i in 0...self.numberOfComponents {
         
         if let label = labels[i] {
            
            if self.subviews.contains(label) {
               label.removeFromSuperview()
            }
            
            label.frame = CGRect(x: x + labelWidth * CGFloat(i), y: y, width: labelWidth, height: fontSize)
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
            label.backgroundColor = .clear
            label.textAlignment = NSTextAlignment.center
            
            self.addSubview(label)
         }
      }
   }
}

struct TimePicker: View {
   
   
   private let data: [[String]] = [
      Array(0...23).map { "\($0)" },
      Array(0...60).map { "\($0)" },
      Array(0...60).map { "\($0)" }
   ]
   
   @Binding var selections: [Int]
   
   var body: some View {
      GeometryReader { geometry in
         VStack(spacing: 0) {
            Text("Goal Time")
               .font(.title3)
               .fontWeight(.medium)
               .padding(.top, 10)
            
            ZStack {
               PickerView(data: self.data, selections: self.$selections)
                  .frame(width: geometry.size.width)
                  .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
               //                                .border(.black)
               
               let pickerWidth: CGFloat = 230
               
               let hoursX = (geometry.size.width / 2) - (pickerWidth / 2) + 48
               Text("hours")
                  .fontWeight(.medium)
                  .position(x: hoursX, y: geometry.size.height / 2)
               
               let minX = (geometry.size.width / 2) + 33
               Text("min")
                  .fontWeight(.medium)
                  .position(x: minX, y: geometry.size.height / 2)
               
               let secX = (geometry.size.width / 2) + (pickerWidth / 2) + 14
               Text("sec")
                  .fontWeight(.medium)
                  .position(x: secX, y: geometry.size.height / 2)
            }
         }
      }
   }
}
