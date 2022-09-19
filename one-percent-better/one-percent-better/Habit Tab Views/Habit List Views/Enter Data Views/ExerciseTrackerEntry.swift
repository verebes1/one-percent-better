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
            
            ForEach(0 ..< vm.sets, id: \.self) { i in
                ExerciseRow(index: i)
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
    
    let onChange: (String) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.systemGray5)
            
            TextField("", text: $field)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60, height: 25)
        .onChange(of: field) { newValue in
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

struct ExerciseRow: View {
    
    @EnvironmentObject var vm: ExerciseEntryModel
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    let i: Int
    
    @State private var weightField: String = ""
    @State private var repField: String = ""
    
    init(index: Int) {
        self.i = index
    }
    
    var body: some View {
        DeletableRow {
            LazyVGrid(columns: columns) {
                Text(String(i+1))
                    .fontWeight(.medium)
                PreviousWeight()
                
                ExerciseField(field: $weightField) { newValue in
                    vm.weights[i] = Double(newValue) == nil ? nil : newValue
                }
                .onAppear {
                    let initWeight = vm.weights[i] ?? ""
                    weightField = initWeight
                }
                
                ExerciseField(field: $repField) { newValue in
                    vm.reps[i] = Int(newValue) ?? nil
                }
                .onAppear {
                    let initRep = vm.reps[i] == nil ? "" : "\(vm.reps[i]!)"
                    repField = initRep
                }
            }
            .frame(height: 32)
        } deleteCallback: {
            vm.weights[i] = nil
            vm.reps[i] = nil
            weightField = ""
            repField =  ""
        }
    }
}
