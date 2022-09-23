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
    
    @State private var dailyFrequencyText: String
    @State private var timesPerDay: Int
    
    @Binding var show: Bool
    
    @State private var timesPerDayZeroError = false
    @State private var timesPerDayEmptyError = false
    
    init(timesPerDay: Int, show: Binding<Bool>) {
        self._timesPerDay = State(initialValue: timesPerDay)
        self._dailyFrequencyText = State(initialValue: String(timesPerDay))
        self._show = show
    }
    
    func canSave() throws -> Bool {
        if dailyFrequencyText == "" {
            throw HabitFrequencyError.emptyFrequency
        }
        if let timesPerDay = Int(dailyFrequencyText) {
            if timesPerDay > 0 {
                self.timesPerDay = timesPerDay
                return true
            } else {
                throw HabitFrequencyError.zeroFrequency
            }
        }
        return false
    }
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                subtitle: "How often do you want to complete this habit?")
                
                EveryDaily(frequencyText: $dailyFrequencyText,
                                           zeroError: $timesPerDayZeroError,
                                           emptyError: $timesPerDayEmptyError)
                
                Spacer()
            }
            .navigationTitle("Edit Frequency")
            .navigationBarTitleDisplayMode(.inline)
            // Hide the system back button
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        do {
                            if try canSave() {
                                habit.timesPerDay = self.timesPerDay
                                moc.fatalSave()
                                show = false
                            }
                        } catch HabitFrequencyError.zeroFrequency {
                            timesPerDayZeroError = true
                            timesPerDayEmptyError = false
                        } catch HabitFrequencyError.emptyFrequency {
                            timesPerDayZeroError = false
                            timesPerDayEmptyError = true
                        } catch {
                            fatalError("Unknown error in EditHabit")
                        }
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
