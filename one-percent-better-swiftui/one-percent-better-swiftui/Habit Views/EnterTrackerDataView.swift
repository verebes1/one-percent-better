//
//  EnterTrackerDataView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/8/22.
//

import SwiftUI

struct CustomTextFieldModel {
    var text: String
    var validField: Bool = true
    
    init(text: String) {
        self.text = text
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
        for tracker in trackers {
            var previousValue = ""
            if let t = tracker as? NumberTracker {
                if let value = t.getValue(date: currentDay) {
                    previousValue = value
                }
            }
            let newField = CustomTextFieldModel(text: previousValue)
            fields.append(newField)
        }
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
        for (i, myField) in fields.enumerated() {
            if let _ = trackers[i] as? NumberTracker {
                if !myField.text.isEmpty {
                    if let _ = Double(myField.text) {
                        fields[i].validField = true
                    } else {
                        allFieldsValid = false
                        fields[i].validField = false
                    }
                }
            }
        }
        return allFieldsValid
    }
    
    func save() -> Bool {
        if !allFieldsValid {
            return false
        }
        
        for (i, field) in fields.enumerated() {
            if let t = trackers[i] as? NumberTracker {
                if !field.text.isEmpty {
                    if let _ = Double(field.text) {
                        t.add(date: currentDay, value: field.text)
                    }
                } else if t.getValue(date: currentDay) != nil {
                    t.remove(on: currentDay)
                }
            }
        }
        
        habit.markCompleted(on: currentDay)
        return true
    }
    
}

struct EnterTrackerDataView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm: EnterTrackerDataViewModel
    
    @State var updateForError: Bool = false
//    @State var validFields: [Bool]
    
    init(vm: EnterTrackerDataViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        NavigationView {
            Background {
                ScrollView {
                    VStack {
                    Spacer()
                        .frame(height: 10)
                    CardView {
                        VStack(spacing: 0) {
                            ForEach(vm.trackers.indices, id: \.self) { i in
                                NumberTrackerEnterDataView(vm: vm,
                                                           index: i)
                            }
                        }
                    }
                    Spacer()
                }
                }
            }
            .navigationBarTitle("Enter Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let canSave = vm.save()
                        if canSave {
                            presentationMode.wrappedValue.dismiss()
                        }
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

struct NumberTrackerEnterDataView: View {
    
    @ObservedObject var vm: EnterTrackerDataViewModel
    let index: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(vm.trackers[index].name)")
                    .fontWeight(.medium)
                
                TextField("Value", text: $vm.fields[index].text)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .frame(height: 45)
            }
            .padding(.horizontal, 20)
            
            if !vm.fields[index].validField {
                Label("Not a valid number", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .padding(.bottom, (index != vm.fields.count - 1) ? 5 : 0)
            }
            
            if index != vm.fields.count - 1 {
                Divider()
            }
        }
    }
}
