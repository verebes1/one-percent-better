//
//  EditHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/28/22.
//

import SwiftUI

struct EditHabitFrequency: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var vm: ProgressViewModel
    @StateObject private var fssm: FrequencySelectionStackModel
    
    init(habit: Habit) {
        let initialFrequency = habit.frequency(on: Date()) ?? .timesPerDay(1)
        self._fssm = StateObject(wrappedValue: FrequencySelectionStackModel(selection: initialFrequency))
    }
    
    var body: some View {
        Background {
            VStack(spacing: 20) {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                                    subtitle: "How often do you want to complete this habit?")
                
                FrequencySelectionStack()
                    .environmentObject(fssm)
                
                Spacer()
            }
            .onDisappear {
                if fssm.selection != vm.habit.frequency(on: Date()) {
                    vm.habit.updateFrequency(to: fssm.selection)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//struct EditHabitFrequency_Previews: PreviewProvider {
//   static var previews: some View {
//      NavigationView {
//         EditHabitFrequency(frequency: .timesPerDay(2))
//      }
//   }
//}
