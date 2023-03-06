//
//  CreateHabitName.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

enum CreateFrequencyRoute: Hashable {
   case createFrequency(Habit)
}

struct CreateHabitName: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   @State var habitName: String = ""
   
   @State private var nextPressed = false
   
   @FocusState private var nameInFocus: Bool
   
   @Binding var hideTabBar: Bool
   
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
                     .listRowBackground(Color.cardColor)
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
            
//            if habitName.isEmpty {
//               BottomButtonDisabledWhenEmpty(text: "Next", dependingLabel: $habitName)
//            } else {
//               NavigationLink(value: CreateFrequencyRoute.createFrequency(habitName)) {
//                  BottomButtonDisabledWhenEmpty(text: "Next", dependingLabel: $habitName)
//               }
//            }
            
            Button {
               if !habitName.isEmpty {
                  let habit = Habit(moc: moc, name: habitName, id: UUID())
                  nav.path.append(CreateFrequencyRoute.createFrequency(habit))
               }
            } label: {
               BottomButtonDisabledWhenEmpty(text: "Next", dependingLabel: $habitName)
            }

         }
         .navigationDestination(for: CreateFrequencyRoute.self) { route in
            if case .createFrequency(let habit) = route {
               CreateHabitFrequency(habit: habit, hideTabBar: $hideTabBar)
                  .environmentObject(nav)
            }
         }
      }
      .onAppear {
         nameInFocus = true
         hideTabBar = true
      }
      // TODO: 1.0.9 FIX THIS
//      .onDisappear {
//         if releaseTabBar {
//            hideTabBar = false
//         }
//      }
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
      let moc = CoreDataManager.previews.mainContext
      CreateHabitName(hideTabBar: .constant(true))
         .environment(\.managedObjectContext, moc)
         .environmentObject(HabitListViewModel(moc))
         .environmentObject(HabitTabNavPath())
   }
}
