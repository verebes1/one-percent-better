//
//  ExerciseTrackerEntry.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

class WeightRep: ObservableObject {
    
    @Published var weightField: String = ""
    @Published var repField: String = ""
    
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
}

struct ExerciseTrackerEntry: View {
    
    @EnvironmentObject var vm: ExerciseEntryModel
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    var tracker: ExerciseTracker
    
    func removeRows(at offsets: IndexSet) {
        vm.sets.remove(atOffsets: offsets)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(tracker.name)
                    .fontWeight(.medium)
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
            
            ExerciseAddSet()
            
            if !vm.isValid {
                Label("Not a valid exercise set", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
//            ErrorLabel(message: "Not a valid exercise set", showError: !$vm.isValid)
        }
        .padding(.vertical, 10)
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
        Background {
            CardView {
                ExerciseTrackerEntry(tracker: tracker)
                    .environmentObject(vm)
            }
        }
        )
    }
}

struct PreviousWeight: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .foregroundColor(.systemGray5)
            .frame(width: 35, height: 3)
    }
}

struct ExerciseField: View {
    
    @Binding var field: String
    
//    let onChange: (String) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.systemGray5)
            
            TextField("", text: $field)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60, height: 25)
//        .onChange(of: field) { newValue in
//            onChange(newValue)
//        }
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

struct ExerciseRow: View {
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    let i: Int
    @ObservedObject var gymSet: WeightRep
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Text(String(i+1))
                .fontWeight(.medium)
            PreviousWeight()
            ExerciseField(field: $gymSet.weightField)
            ExerciseField(field: $gymSet.repField)
        }
        .frame(height: 32)
    }
}
