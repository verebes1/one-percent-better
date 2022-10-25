//
//  ExerciseTrackerEntry.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

class WeightRep: ObservableObject {
   
   @Published var weightField: String = ""
   @Published var weightFieldValid: Bool = true
   
   @Published var repField: String = ""
   @Published var repFieldValid: Bool = true
   
   
   var weight: String? {
      if !weightField.isEmpty,
         let _ = Double(weightField) {
         return weightField
      } else {
         return nil
      }
   }
   
   var rep: Int? {
      if !repField.isEmpty,
         let rep = Int(repField) {
         return rep
      } else {
         return nil
      }
   }
   
   var isEmpty: Bool {
      if (weight == nil || weightField == "") && (rep == nil || repField == "") {
         return true
      } else {
         return false
      }
   }
   
   var isValid: Bool {
      if weight == nil && rep == nil {
         return false
      } else {
         return true
      }
   }
   
   init() {
      self.weightField = ""
      self.repField = ""
   }
   
   init(weight: String, rep: Int) {
      self.weightField = weight
      self.repField = "\(rep)"
   }
}

class ExerciseEntryModel: ObservableObject {
   
   @Published var sets: [WeightRep] = []
   @Published var isValid: Bool = true
   
   var previousEntry: ExerciseEntryModel? {
      didSet {
         if let pe = previousEntry,
            pe.sets.count > sets.count {
            for _ in 0 ..< pe.sets.count - sets.count {
               sets.append(WeightRep())
            }
         }
      }
   }
   
   var isEmpty: Bool {
      for s in sets {
         if !s.isEmpty {
            return false
         }
      }
      return true
   }
   
   init() {
      self.sets = [WeightRep()]
   }
   
   init(reps: [Int], weights: [String]) {
      var newSets: [WeightRep] = []
      for i in 0 ..< reps.count {
         newSets.append(WeightRep(weight: weights[i], rep: reps[i]))
      }
      self.sets = newSets
   }
   
   
   func validateFields() -> Bool {
      var isValid = true
      for i in 0 ..< sets.count {
         if (sets[i].weight != nil && sets[i].rep == nil) ||
               (sets[i].weight == nil && sets[i].rep != nil) {
            isValid = false
            sets[i].weightFieldValid = sets[i].weight != nil ? true : false
            sets[i].repFieldValid = sets[i].rep != nil ? true : false
         } else {
            sets[i].weightFieldValid = true
            sets[i].repFieldValid = true
         }
      }
      self.isValid = isValid
      return isValid
   }
}

struct ExerciseTrackerEntry: View {
   
   @EnvironmentObject var vm: ExerciseEntryModel
   
   let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
   
   var tracker: ExerciseTracker
   
   var body: some View {
      VStack {
         HStack {
            Text(tracker.name)
               .fontWeight(.medium)
               .foregroundColor(Style.accentColor)
               .padding(.leading, 20)
            Spacer()
         }
         
         LazyVGrid(columns: columns) {
            Text("Set")
            Text("Previous")
            Text("lbs")
            Text("Reps")
         }
         
         ForEach(Array(vm.sets.enumerated()), id: \.offset) { (i, gymSet) in
            DeletableRow {
               ExerciseRow(i: i, gymSet: gymSet)
            } deleteCallback: {
               vm.sets.remove(at: i)
            }
         }
         
         ErrorLabel(message: "Enter weight and reps", showError: !$vm.isValid)
         
         ExerciseAddSet()
         
      }
      .padding(.vertical, 10)
      .font(.system(size: 15, weight: .medium))
      
//      .bold()
   }
}

struct ExerciseTrackerEntry_Previews: PreviewProvider {
   
   static func data() -> ExerciseTracker {
      let context = CoreDataManager.previews.mainContext
      
      let h = try? Habit(context: context, name: "Work Out")
      
      if let h = h {
         let _ = ExerciseTracker(context: context, habit: h, name: "Bench Press")
      }
      
      let habits = Habit.habits(from: context)
      return (habits.first!.trackers.firstObject as! ExerciseTracker)
   }
   
   static var previews: some View {
      let tracker = data()
      let vm = ExerciseEntryModel()
      return (
         ExerciseTrackerEntry(tracker: tracker)
            .environmentObject(vm)
      )
   }
}

struct PreviousWeight: View {
   
   @EnvironmentObject var vm: ExerciseEntryModel
   
   let i: Int
   
   var body: some View {
      if let prev = vm.previousEntry,
         i < prev.sets.count,
         let weight = prev.sets[i].weight,
         let reps = prev.sets[i].rep {
         Text("\(weight) lb x \(reps)")
      } else {
         RoundedRectangle(cornerRadius: 7)
            .foregroundColor(.systemGray5)
            .frame(width: 35, height: 3)
      }
   }
}

struct ExerciseCheckmark: View {
   
   @State private var completed: Bool = false
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 7)
            .foregroundColor(completed ? .systemGreen : .systemGray5)
            .frame(width: 35, height: 25)
         
         Image(systemName: "checkmark")
            .foregroundColor(completed ? .white : .black)
      }
      .onTapGesture {
         completed.toggle()
      }
   }
}

struct ExerciseAddSet: View {
   
   @EnvironmentObject var vm: ExerciseEntryModel
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 7)
            .foregroundColor(.systemGray5)
            .frame(height: 25)
         Label("Add Set", systemImage: "plus")
            .font(.system(size: 14))
      }
      .padding(.horizontal, 18)
      .onTapGesture {
         withAnimation {
            vm.sets.append(WeightRep())
         }
      }
   }
}

struct ExerciseField: View {
   
   @Environment(\.colorScheme) var scheme
   
   @Binding var field: String
   @Binding var isValid: Bool
   
   @FocusState private var textFieldFocus
   
   var useDecimal: Bool
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 7)
            .foregroundColor(.systemGray5)
         
         TextField("", text: $field)
            .multilineTextAlignment(.center)
            .keyboardType(useDecimal ? .decimalPad : .numberPad)
            .focused($textFieldFocus)
      }
      .frame(width: 60, height: 25)
      .overlay(
         !self.isValid ?
         RoundedRectangle(cornerRadius: 7)
            .stroke(.red, lineWidth: 2)
         : nil
      )
      .overlay(
         self.textFieldFocus ?
         RoundedRectangle(cornerRadius: 7)
            .stroke(scheme == .light ? .black : .white, lineWidth: 2)
         : nil
      )
   }
}

struct ExerciseRow: View {
   
   let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
   
   let i: Int
   @ObservedObject var gymSet: WeightRep
   
   var body: some View {
      LazyVGrid(columns: columns) {
         Text(String(i+1))
            .fontWeight(.medium)
         PreviousWeight(i: i)
         ExerciseField(field: $gymSet.weightField,
                       isValid: $gymSet.weightFieldValid,
                       useDecimal: true)
         ExerciseField(field: $gymSet.repField,
                       isValid: $gymSet.repFieldValid,
                       useDecimal: false)
      }
      .frame(height: 32)
   }
}
