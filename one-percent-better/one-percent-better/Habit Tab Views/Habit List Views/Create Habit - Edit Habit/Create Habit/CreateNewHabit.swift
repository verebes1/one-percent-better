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
                            vm.navPath.append("habit_name")
                        }
                    }
                    .navigationDestination(for: String.self) { value in
                        ChooseHabitFrequency(habitName: habitName)
                            .toolbar(.hidden, for: .tabBar)
                            .environmentObject(vm)
                    }
            }
            
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
