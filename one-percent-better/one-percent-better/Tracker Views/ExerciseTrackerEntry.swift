//
//  ExerciseTrackerEntry.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

class ExerciseEntryModel: ObservableObject {
    
    @Published var sets: Int {
        didSet {
            reps.append(nil)
            weights.append(nil)
        }
    }
    @Published var reps: [Int?] = []
    @Published var weights: [Double?] = []
    
    init() {
        self.sets = 4
        self.reps = Array(repeating: nil, count: sets)
        self.weights = Array(repeating: nil, count: sets)
    }
    
    
}

struct ExerciseTrackerEntry: View {
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 5)
    
    var tracker: ExerciseTracker
    
    @StateObject var vm = ExerciseEntryModel()
    
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
                Image(systemName: "checkmark")
            }
            
            LazyVGrid(columns: columns) {
                ForEach(0 ..< vm.sets, id:\.self) { i in
                    Text(String(i+1))
                        .fontWeight(.medium)
                    PreviousWeight()
                    ExerciseField()
                    ExerciseField()
                    ExerciseCheckmark()
                }
            }
            .padding(.bottom, 10)
            
            ExerciseAddSet()
                .environmentObject(vm)
        }
        .padding(.vertical, 5)
    }
}

struct ExerciseTrackerEntry_Previews: PreviewProvider {
    
    static func data() -> ExerciseTracker {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let h = try? Habit(context: context, name: "Work Out")
        
        if let h = h {
            let _ = ExerciseTracker(context: context, habit: h, name: "Bench Press")
        }
        
        let habits = Habit.habitList(from: context)
        return (habits.first!.trackers.firstObject as! ExerciseTracker)
    }
    
    static var previews: some View {
        let tracker = data()
        Background {
            CardView {
                ExerciseTrackerEntry(tracker: tracker)
            }
        }
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
    
    @State private var value: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.systemGray5)
            
            TextField("", text: $value)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60, height: 25)
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
