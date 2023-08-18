//
//  HowToCompleteHabitTip.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/15/23.
//

import SwiftUI

struct HowToCompleteHabitTip: View {
    
    @EnvironmentObject var hlvm: HabitListViewModel
    
    @Environment(\.editMode) private var editMode
    
//    var hasCompletedAHabit: Bool {
//        guard !hlvm.habits.isEmpty else { return true }
//        let completedArray = Set(hlvm.habits.map { !$0.daysCompleted.isEmpty })
//        return completedArray.contains(true)
//    }
    
    var body: some View {
        ZStack {
            if hlvm.isNewbie && editMode?.wrappedValue.isEditing == false {
                HStack(spacing: 0) {
                    Spacer().frame(width: 6)
                    Image(systemName: "arrow.turn.left.up")
                    Text(" Tap here to mark your habit as completed")
                        .font(.system(size: 12))
                        .foregroundColor(.secondaryLabel)
                    Spacer()
                }
                .transition(
                    .opacity.combined(with: .move(edge: .bottom))
                )
            }
        }
        .animation(.easeOut, value: hlvm.isNewbie)
    }
}

//struct HowToCompleteHabitTip_Previews: PreviewProvider {
//    static var previews: some View {
//        HowToCompleteHabitTip()
//    }
//}
