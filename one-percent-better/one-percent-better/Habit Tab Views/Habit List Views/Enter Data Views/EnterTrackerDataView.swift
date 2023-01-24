//
//  EnterTrackerDataView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/8/22.
//

import SwiftUI

struct NumberTrackerFieldModel {
   var text: String
   var validField: Bool = true
}

class EnterTrackerDataViewModel: ObservableObject {
   
   @Published var numberTrackerFields: [NumberTracker: NumberTrackerFieldModel] = [:]
   @Published var imageTrackerFields: [ImageTracker: UIImage] = [:]
   @Published var exerciseTrackerFields: [ExerciseTracker: ExerciseEntryModel] = [:]
   
   var habit: Habit
   var trackers: [Tracker]
   var currentDay: Date
   
   init(habit: Habit, currentDay: Date) {
      self.habit = habit
      self.trackers = habit.manualTrackers
      self.currentDay = currentDay
      
      for tracker in trackers {
         if let t = tracker as? NumberTracker {
            let previousValue = t.getValue(date: currentDay) ?? ""
            let newField = NumberTrackerFieldModel(text: previousValue)
            numberTrackerFields[t] = newField
         } else if let t = tracker as? ImageTracker {
            let previousValue = t.getValue(date: currentDay) ?? UIImage(systemName: "photo.on.rectangle")!
            imageTrackerFields[t] = previousValue
         } else if let t = tracker as? ExerciseTracker {
            let previousValue = t.getEntry(on: currentDay) ?? ExerciseEntryModel()
            previousValue.previousEntry = t.getPreviousEntry(before: currentDay)
            exerciseTrackerFields[t] = previousValue
         }
      }
   }
   
   func numberTrackerBinding(for key: NumberTracker) -> Binding<NumberTrackerFieldModel> {
      return Binding(get: {
         return self.numberTrackerFields[key] ?? NumberTrackerFieldModel(text: "")
      }, set: {
         self.numberTrackerFields[key] = $0
      })
   }
   
   func imageTrackerBinding(for key: ImageTracker) -> Binding<UIImage> {
      return Binding(get: {
         return self.imageTrackerFields[key] ?? UIImage(systemName: "photo.on.rectangle")!
      }, set: {
         self.imageTrackerFields[key] = $0
      })
   }
   
   func trackerValue(index: Int) -> String {
      if let t = trackers[index] as? NumberTracker {
         if let value = t.getValue(date: currentDay) {
            return value
         }
      }
      return ""
   }
   
   var allFieldsValid: Bool {
      var allFieldsValid = true
      for tracker in numberTrackerFields.keys {
         if !numberTrackerFields[tracker]!.text.isEmpty {
            if let _ = Double(numberTrackerFields[tracker]!.text) {
               numberTrackerFields[tracker]!.validField = true
            } else {
               allFieldsValid = false
               numberTrackerFields[tracker]!.validField = false
            }
         }
      }
      
      // TODO: Add check for exercise tracker
      for tracker in exerciseTrackerFields.keys {
         if let entry = exerciseTrackerFields[tracker] {
            let result = entry.validateFields()
            if !result {
               allFieldsValid = false
            }
         }
      }
      
      return allFieldsValid
   }
   
   func save() -> Bool {
      if !allFieldsValid {
         return false
      }
      
      var atLeastOneEntry = false
      
      for tracker in numberTrackerFields.keys {
         if !numberTrackerFields[tracker]!.text.isEmpty {
            if let _ = Double(numberTrackerFields[tracker]!.text) {
               tracker.add(date: currentDay, value: numberTrackerFields[tracker]!.text)
               atLeastOneEntry = true
            }
         } else if tracker.getValue(date: currentDay) != nil {
            tracker.remove(on: currentDay)
         }
      }
      
      for tracker in imageTrackerFields.keys {
         if let image = imageTrackerFields[tracker],
            !image.isSymbolImage {
            tracker.add(date: currentDay, value: image)
            atLeastOneEntry = true
         } else if tracker.getValue(date: currentDay) != nil {
            tracker.remove(on: currentDay)
         }
      }
      
      for tracker in exerciseTrackerFields.keys {
         if let entry = exerciseTrackerFields[tracker], !entry.isEmpty {
            tracker.updateSets(sets: entry.sets, on: currentDay)
            atLeastOneEntry = true
         } else {
            tracker.remove(on: currentDay)
         }
      }
      
      if atLeastOneEntry {
         habit.markCompleted(on: currentDay)
      } else {
         habit.toggle(on: currentDay)
      }
      return true
   }
   
}

struct EnterTrackerDataView: View {
   
   @Environment(\.colorScheme) var scheme
   @Environment(\.presentationMode) var presentationMode
   
   @ObservedObject var vm: EnterTrackerDataViewModel
   
   var body: some View {
      NavigationStack {
         Background(color: scheme == .light ? .white : .black) {
            ScrollView {
               VStack {
                  Spacer()
                     .frame(height: 10)
                  //                        CardView {
                  VStack(spacing: 0) {
                     ForEach(vm.trackers.indices, id: \.self) { i in
                        if let t = vm.trackers[i] as? NumberTracker {
                           NumberTrackerEnterDataView(name: t.name,
                                                      field: vm.numberTrackerBinding(for: t))
                        }
                        else if let t = vm.trackers[i] as? ImageTracker {
                           ImageTrackerEnterDataView(name: t.name,
                                                     image: vm.imageTrackerBinding(for: t))
                        } else if let t = vm.trackers[i] as? ExerciseTracker {
                           ExerciseTrackerEntry(tracker: t)
                              .environmentObject(vm.exerciseTrackerFields[t]!)
                        }
                        
                     }
                  }
                  //                        }
                  Spacer()
               }
            }
         }
         .navigationBarTitle("Enter Data")
         .navigationBarTitleDisplayMode(.inline)
         .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button {
                  let canSave = vm.save()
                  if canSave {
                     presentationMode.wrappedValue.dismiss()
                  }
               } label: {
                  Text("Save")
                     .fontWeight(.semibold)
               }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
               Button("Cancel") {
                  // TODO: Check if there will be any lost data
                  presentationMode.wrappedValue.dismiss()
               }
            }
         }
      }
   }
}

struct EnterTrackerDataView_Previews: PreviewProvider {
   
   static func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let h = try? Habit(context: context, name: "Soccer")
      if let h = h {
         let _ = NumberTracker(context: context, habit: h, name: "Hours")
         let _ = NumberTracker(context: context, habit: h, name: "Goals")
         let _ = ImageTracker(context: context, habit: h, name: "Swimming")
         let _ = ExerciseTracker(context: context, habit: h, name: "Squat")
         let _ = NumberTracker(context: context, habit: h, name: "Miles")
      }
      
      let habits = Habit.habits(from: context)
      
      return habits
   }
   
   static var previews: some View {
      let habits = data()
      let vm = EnterTrackerDataViewModel(habit: habits[0], currentDay: Date())
      Group {
         EnterTrackerDataView(vm: vm)
         
         Text("Background").sheet(isPresented: .constant(true)) {
            EnterTrackerDataView(vm: vm)
         }
      }
   }
}
