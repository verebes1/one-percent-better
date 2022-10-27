//
//  CreateNewHabit.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI
import Introspect

enum CreateFrequencyRoute: Hashable {
   case createFrequency(String)
}

struct CreateNewHabit: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   @EnvironmentObject var vm: HabitListViewModel
   
   @State var habitName: String = ""
//   @State private var isResponder: Bool? = true
   
   @FocusState private var nameInFocus: Bool
   
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
                  
                  TextField("Name", text: $habitName)
                     .focused($nameInFocus)
                  
                  .padding(.leading, 10)
                  .frame(height: 50)
               }
               .padding(.horizontal, 20)
            }
            
            Spacer()
            
            BottomButtonDisabledWhenEmpty(text: "Next", dependingLabel: $habitName)
               .onTapGesture {
                  if !habitName.isEmpty {
                     nav.path.append(CreateFrequencyRoute.createFrequency(habitName))
                  }
               }
         }
         .navigationDestination(for: CreateFrequencyRoute.self) { route in
            if case let .createFrequency(habitName) = route {
               ChooseHabitFrequency(habitName: habitName)
                  .toolbar(.hidden, for: .tabBar)
                  .environmentObject(vm)
                  .environmentObject(nav)
            }
         }
         .onAppear {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
             self.nameInFocus = true
           }
         }
      }
      .toolbar {
         ToolbarItem(placement: .principal) {
            // This sets the back button as "Back" instead of the title of the previous screen
            Text("    ")
         }
      }
      .toolbar(.hidden, for: .tabBar)
   }
}

struct CreateNewHabit_Previews: PreviewProvider {
   
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      CreateNewHabit()
         .environment(\.managedObjectContext, context)
   }
}
