//
//  ChooseHabitName.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI
import Introspect

enum CreateFrequencyRoute: Hashable {
   case createFrequency(String)
}

struct ChooseHabitName: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   @EnvironmentObject var vm: HabitListViewModel
   
   @State var habitName: String = ""
   //   @State private var isResponder: Bool? = true
   
   @FocusState private var nameInFocus: Bool
   
   var body: some View {
      Background {
         VStack {
            
            Spacer()
            
            HabitCreationHeader(systemImage: "square.and.pencil",
                                title: "Create New Habit")
            
            TextField("Name", text: $habitName)
               .focused($nameInFocus)
               .padding(.leading, 20)
               .frame(height: 50)
               .background(Color.cardColor)
               .cornerRadius(radius: 10)
               .padding(.horizontal, 20)
            
            Spacer().frame(height: 20)
            
            VStack(spacing: 5) {
               HStack {
                  Text("Suggestions")
                     .font(.system(size: 14))
                     .foregroundColor(.secondaryLabel)
                  Spacer()
               }
               .padding(.leading, 20)
               
               List {
                  ForEach(PrebuiltHabits.habitNames, id: \.self) { name in
                     HStack {
                        Text(name)
                        Spacer()
                     }
                     .contentShape(Rectangle())
                     .onTapGesture {
                        habitName = name
                     }
                  }
               }
               .scrollContentBackground(.hidden)
               .padding(.top, -30)
               .clipShape(Rectangle())
            }
            
            Spacer().frame(height: 10)
            
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
                  .environmentObject(vm)
                  .environmentObject(nav)
            }
         }
         .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
               self.nameInFocus = true
            }
         }
      }
      .toolbar {
         ToolbarItem(placement: .principal) {
            // This sets the back button as "Back" instead of the title of the previous screen
            Text("           ")
         }
      }
   }
}

struct CreateNewHabit_Previews: PreviewProvider {
   
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      ChooseHabitName()
         .environment(\.managedObjectContext, context)
   }
}