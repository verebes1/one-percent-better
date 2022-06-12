//
//  EnterTrackerDataView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/8/22.
//

import SwiftUI

class CustomTextFieldModel: ObservableObject {
    @Published var text: String
    @Published var isResponder: Bool?
    
    init(text: String, isResponder: Bool?) {
        self.text = text
        self.isResponder = isResponder
    }
}

class EnterTrackerDataViewModel: ObservableObject {
    
    @Published var fields: [CustomTextFieldModel]
    
    var habit: Habit
    var trackers: [Tracker]
    var currentDay: Date
    
    init(habit: Habit, currentDay: Date) {
        self.habit = habit
        self.trackers = habit.manualTrackers
        self.currentDay = currentDay
        
        fields = [CustomTextFieldModel]()
        var first: Bool = true
        for _ in trackers {
            let newField = CustomTextFieldModel(text: "", isResponder: first)
            fields.append(newField)
            first = false
        }
    }
    
    var currentResponder: CustomTextFieldModel? {
        for field in fields {
            if let isResponder = field.isResponder,
               isResponder {
                return field
            }
        }
        return nil
    }

    
    func save() {
        for (i, field) in fields.enumerated() {
            if let t = trackers[i] as? NumberTracker {
                if !field.text.isEmpty {
                    if let _ = Double(field.text) {
                        t.add(date: currentDay, value: field.text)
                    } else {
                        // TODO: show not a double error
                    }
                } else if t.getValue(date: currentDay) != nil {
                    t.remove(on: currentDay)
                }
            }
        }
    }
    
}

struct EnterTrackerDataView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm: EnterTrackerDataViewModel
    
    var body: some View {
        NavigationView {
            Background {
                VStack {
                    CardView {
                        VStack(spacing: 0) {
                            ForEach(vm.trackers.indices, id: \.self) { i in
                                let tracker = vm.trackers[i]
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("\(tracker.name)")
                                            .fontWeight(.medium)
                                        
                                        if i + 1 < vm.fields.count {
                                            CustomTextField(text: $vm.fields[i].text,
                                                            placeholder: "Old value",
                                                            isResponder: $vm.fields[i].isResponder,
                                                            nextResponder: $vm.fields[i+1].isResponder,
                                                            textAlignment: .right)
                                            .frame(height: 45)
                                        } else {
                                            CustomTextField(text: $vm.fields[i].text,
                                                            placeholder: "Old value",
                                                            isResponder: $vm.fields[i].isResponder,
                                                            nextResponder: .constant(nil),
                                                            textAlignment: .right)
                                            .frame(height: 45)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    if i != vm.fields.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        vm.currentResponder?.isResponder = false
                        vm.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        vm.currentResponder?.isResponder = false
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
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let h = try? Habit(context: context, name: "Soccer")
        if let h = h {
            let _ = NumberTracker(context: context, habit: h, name: "Hours")
            let _ = NumberTracker(context: context, habit: h, name: "Goals")
        }
        
        let habits = Habit.habitList(from: context)
        
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
