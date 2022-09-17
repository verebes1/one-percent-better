//
//  ExerciseTrackerEntry.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

class ExerciseEntryModel: ObservableObject {
    
    @Published var sets: Int {
        willSet {
            reps.append(nil)
            weights.append(nil)
        }
    }
    @Published var reps: [Int?] = []
    @Published var weights: [String?] = []
    @Published var isValid: Bool = true
    
    var finalReps: [Int] {
        var arr: [Int] = []
        for rep in reps {
            if let rep = rep {
                arr.append(rep)
            }
        }
        return arr
    }
    
    var finalWeights: [String] {
        var arr: [String] = []
        for weight in weights {
            if let weight = weight {
                arr.append(weight)
            }
        }
        return arr
    }
    
    var isEmpty: Bool {
        for rep in reps {
            if rep != nil {
                return false
            }
        }
        for weight in weights {
            if weight != nil {
                return false
            }
        }
        return true
    }
    
    init() {
        self.sets = 4
        self.reps = Array(repeating: nil, count: sets)
        self.weights = Array(repeating: nil, count: sets)
    }
    
    init(reps: [Int], weights: [String]) {
        self.sets = reps.count
        self.reps = reps
        self.weights = weights
    }
    
    func weightBinding(for set: Int) -> Binding<String> {
        // TODO: check if set # is valid
        return Binding(get: {
            return self.weights[set] ?? ""
        }, set: {
            self.weights[set] = $0
        })
    }
    
    func repBinding(for set: Int) -> Binding<Int?> {
        // TODO: check if set # is valid
        return Binding(get: {
            return self.reps[set]
        }, set: {
            self.reps[set] = $0
        })
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
                    .padding(.leading, 20)
                Spacer()
            }
            
            LazyVGrid(columns: columns) {
                Text("Set")
                Text("Previous")
                Text("lbs")
                Text("Reps")
//                Image(systemName: "checkmark")
            }
            
            LazyVGrid(columns: columns) {
                ForEach(0 ..< vm.sets, id:\.self) { i in
                    Text(String(i+1))
                        .fontWeight(.medium)
                    PreviousWeight()
                    
                    ExerciseField(initalValue: vm.weights[i] ?? "") { newValue in
                        if let _ = Double(newValue) {
                            vm.weights[i] = newValue
                        }
                    }
                    
                    let initalRep = vm.reps[i] == nil ? "" : "\(vm.reps[i]!)"
                    ExerciseField(initalValue: initalRep) { newValue in
                        if let newRep = Int(newValue) {
                            vm.reps[i] = newRep
                        }
                    }
                    
//                    ExerciseCheckmark()
                }
            }
            .padding(.bottom, 10)
            
            ExerciseAddSet()
                .environmentObject(vm)
            
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
    
    @State private var value: String
    
    let onChange: (String) -> Void
    
    init(initalValue: String, onChange: @escaping (String) -> Void) {
        self.onChange = onChange
        self._value = State(initialValue: initalValue)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.systemGray5)
            
            TextField("", text: $value)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60, height: 25)
        .onChange(of: value) { newValue in
            onChange(newValue)
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
                vm.sets += 1
            }
        }
    }
}
