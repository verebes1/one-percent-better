//
//  CreateNewHabit.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI
import Introspect

struct CreateNewHabit: View {
    
    @EnvironmentObject var vm: HabitListViewModel
    
    @State var habitName: String = ""
    @State private var isResponder: Bool? = true
    
    @State private var nextView = false
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "square.and.pencil",
                                    title: "Create New Habit")
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.cardColor)
                            .frame(height: 50)
//                        TextField("Habit Name", text: $habitName)
//                            .padding(.leading, 10)
                        
                        CustomTextField(text: $habitName,
                                        placeholder: "Name",
                                        isResponder: $isResponder,
                                        nextResponder: .constant(nil))
                            .padding(.leading, 10)
                            .frame(height: 50)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                BottomButtonDisabledWhenEmpty(text: "Next", dependingLabel: $habitName)
                    .onTapGesture {
                        if !habitName.isEmpty {
//                            nextView = true
                            vm.createHabitPath.append("habit_name")
                        }
                    }
                    .navigationDestination(for: String.self) { value in
                        ChooseHabitFrequency(habitName: habitName)
                            .environmentObject(vm)
                    }
//                    .background(
//                        NavigationLink(isActive: $nextView) {
//                            ChooseHabitFrequency(habitName: habitName, rootPresenting: $rootPresenting)
//                        } label: {
//                            EmptyView()
//                        }
//                    )
            }
            // Hide the system back button
//            .navigationBarBackButtonHidden(true)
//            // Add your custom back button here
//            .navigationBarItems(leading:
//                                    Button(action: {
//                self.presentationMode.wrappedValue.dismiss()
//            }) {
//                HStack {
//                    Image(systemName: "chevron.left")
//                    Text("Back")
//                }
//            })
        }
    }
}

struct CreateNewHabit_Previews: PreviewProvider {
    
    static var previews: some View {
        let context = CoreDataManager.previews.mainContext
        CreateNewHabit()
            .environment(\.managedObjectContext, context)
    }
}
