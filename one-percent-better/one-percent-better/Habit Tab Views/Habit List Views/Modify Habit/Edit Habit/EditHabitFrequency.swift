//
//  EditHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/28/22.
//

import SwiftUI

struct EditHabitFrequency: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var habit: Habit
    
    @State private var timesPerDay: Int
    @State private var selectedWeekDays: [Int] = [0]
    
    @State private var selection: FrequencySelection = .timesPerDay
    
    @Binding var show: Bool
    
    init(timesPerDay: Int, show: Binding<Bool>) {
        self._timesPerDay = State(initialValue: timesPerDay)
        self._show = show
    }
    
    var body: some View {
        Background {
            VStack(spacing: 20) {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                subtitle: "How often do you want to complete this habit?")
                
                SelectableCard(selection: $selection, type: .timesPerDay) {
                    EveryDaily(timesPerDay: $timesPerDay)
                }
                
                
                SelectableCard(selection: $selection, type: .daysInTheWeek) {
                    EveryWeekly(selectedWeekdays: $selectedWeekDays)
                }
                
                Spacer()
            }
            .navigationTitle("Edit Frequency")
            .navigationBarTitleDisplayMode(.inline)
            // Hide the system back button
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        habit.timesPerDay = self.timesPerDay
                        moc.fatalSave()
                        show = false
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

struct EditHabitFrequency_Previews: PreviewProvider {
    static var previews: some View {
        EditHabitFrequency(timesPerDay: 2, show: .constant(true))
    }
}
