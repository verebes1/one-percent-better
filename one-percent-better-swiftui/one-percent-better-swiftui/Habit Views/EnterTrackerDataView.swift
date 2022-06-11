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
    
    var trackers: [Tracker]
    
    init(habit: Habit) {
        self.trackers = habit.manualTrackers
        
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
}

struct EnterTrackerDataView: View {
    
    @ObservedObject var vm: EnterTrackerDataViewModel
    
    var body: some View {
        NavigationView {
            Background {
                VStack {
                    Spacer().frame(height: 70)
                    CardView {
                        VStack {
                            ForEach(vm.trackers.indices, id: \.self) { i in
                                let tracker = vm.trackers[i]
                                VStack {
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
                        print("Do nothing")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("Do nothing")
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
        let vm = EnterTrackerDataViewModel(habit: habits[0])
        Group {
            EnterTrackerDataView(vm: vm)
            
            Text("Background").sheet(isPresented: .constant(true)) {
                EnterTrackerDataView(vm: vm)
            }
        }
    }
}
