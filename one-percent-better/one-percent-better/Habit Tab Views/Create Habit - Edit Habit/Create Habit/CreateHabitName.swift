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
   @Environment(\.colorScheme) var scheme
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   @State private var habitName: String = ""
   @FocusState private var nameInFocus: Bool
   @State private var nextPressed = false
   @Binding var hideTabBar: Bool
   @State private var isGoingToFrequency = false
   @State private var showSuggestions = false
   
   init(hideTabBar: Binding<Bool>) {
      self._hideTabBar = hideTabBar
      print("~~~~ CreateHabit init")
   }
   
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
               
               Button {
                  if showSuggestions {
                     showSuggestions = false
                     nameInFocus = true
                  } else {
                     showSuggestions = true
                     nameInFocus = false
                  }
               } label: {
                  HStack {
                     Text("Suggestions")
                     Image(systemName: "chevron.right")
                        .rotationEffect(showSuggestions ? Angle(degrees: -90) : Angle(degrees: 90))
                  }
                  .foregroundColor(.labelOpposite(scheme: scheme))
               }
               .padding(10)
               .background(Style.accentColor)
               .cornerRadius(radius: 10)
               .contentShape(Rectangle())

               if showSuggestions {
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
                  .clipShape(Rectangle())
               }
            }
            
            Spacer().frame(height: 10)
            
            Spacer()
            
            Button {
               if !habitName.isEmpty {
                  let habit = Habit(moc: moc, name: habitName, id: UUID())
                  isGoingToFrequency = true
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
         .animation(.easeInOut, value: showSuggestions)
      }
      .onAppear {
         nameInFocus = true
         isGoingToFrequency = false
         hideTabBar = true
      }
      .onDisappear {
         if !isGoingToFrequency {
            hideTabBar = false
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
      let moc = CoreDataManager.previews.mainContext
      CreateHabitName(hideTabBar: .constant(true))
         .environment(\.managedObjectContext, moc)
         .environmentObject(HabitListViewModel(moc))
         .environmentObject(HabitTabNavPath())
   }
}
