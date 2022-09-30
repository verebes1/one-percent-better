//
//  HabitFrequencyStack.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/28/22.
//

import SwiftUI

class FrequencySelectionModel: ObservableObject {
    
    @Published var selection: HabitFrequency = .timesPerDay
    @Published var timesPerDay: Int = 1
    @Published var daysPerWeek: [Int] = [0]
    
    init(selection: HabitFrequency, timesPerDay: Int, daysPerWeek: [Int]) {
        self.selection = selection
        self.timesPerDay = timesPerDay
        self.daysPerWeek = daysPerWeek
    }
}

struct FrequencySelectionStack: View {
    
    @EnvironmentObject var vm: FrequencySelectionModel
    
    var body: some View {
        VStack(spacing: 20) {
            SelectableCard(selection: $vm.selection, type: .timesPerDay) {
                EveryDaily(timesPerDay: $vm.timesPerDay)
            }
            
            SelectableCard(selection: $vm.selection, type: .daysInTheWeek) {
                EveryWeekly(selectedWeekdays: $vm.daysPerWeek)
            }
        }
    }
}

struct HabitFrequencyStack_Previews: PreviewProvider {
    static var previews: some View {
        let vm = FrequencySelectionModel(selection: .timesPerDay, timesPerDay: 1, daysPerWeek: [2,4])
        Background {
            FrequencySelectionStack()
                .environmentObject(vm)
        }
    }
}
