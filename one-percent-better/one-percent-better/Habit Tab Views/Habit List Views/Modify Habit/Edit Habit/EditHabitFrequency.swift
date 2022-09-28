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
    
    @Binding var show: Bool
    
    @ObservedObject var vm: FrequencySelectionModel
    
    init(timesPerDay: Int, show: Binding<Bool>) {
        self.vm = FrequencySelectionModel(selection: .timesPerDay, timesPerDay: timesPerDay, daysPerWeek: [1,3,5])
        self._show = show
    }
    
    func canSave() -> Bool {
        return true
    }
    
    var body: some View {
        Background {
            VStack(spacing: 20) {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                subtitle: "How often do you want to complete this habit?")
                
                FrequencySelectionStack()
                    .environmentObject(vm)
                
                Spacer()
            }
            .onDisappear {
                if canSave() {
                    switch vm.selection {
                    case .timesPerDay:
                        habit.timesPerDay = vm.timesPerDay
                        habit.changeFrequency(to: .timesPerDay)
                    case .daysInTheWeek:
                        habit.daysPerWeek = vm.daysPerWeek
                        habit.changeFrequency(to: .daysInTheWeek)
                    }
                    moc.fatalSave()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EditHabitFrequency_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditHabitFrequency(timesPerDay: 2, show: .constant(true))
        }
    }
}
