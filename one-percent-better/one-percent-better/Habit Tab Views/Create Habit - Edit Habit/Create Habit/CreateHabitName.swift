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
   @EnvironmentObject var barManager: BottomBarManager
   
   @State private var habitName: String = ""
   @FocusState private var nameInFocus: Bool
   @State private var nextPressed = false
   @State private var isGoingToFrequency = false
   @State private var showSuggestions = false
   
   init() {
      print("~~~~ CreateHabit init")
   }
   
   var body: some View {
      Background {
         VStack {
            
            Spacer()
            
            HabitCreationHeader(systemImage: "square.and.pencil",
                                title: "Create New Habit")
            
            
            CreateTextField(placeholder: "Name", text: $habitName, focus: $nameInFocus)
            
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
               .transaction { transaction in
                   transaction.disablesAnimations = true
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
                  HapticEngineManager.playHaptic()
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
               CreateHabitFrequency(habit: habit)
            }
         }
         .animation(.easeInOut, value: showSuggestions)
      }
      .onAppear {
         nameInFocus = true
         isGoingToFrequency = false
         barManager.isHidden = true
      }
      .onDisappear {
         if !isGoingToFrequency {
            barManager.isHidden = false
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
      NavigationStack {
         CreateHabitName()
            .environment(\.managedObjectContext, moc)
            .environmentObject(HabitListViewModel(moc))
            .environmentObject(HabitTabNavPath())
            .environmentObject(BottomBarManager())
      }
   }
}
