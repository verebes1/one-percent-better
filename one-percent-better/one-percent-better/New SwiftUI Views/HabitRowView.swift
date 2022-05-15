//
//  HabitRowView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI

class SwiftUIViewHostingController: UIHostingController<HabitList> {
    required init?(coder aDecoder: NSCoder) {
        let habitRows = [
            HabitRow(habitName: "Baseball",
                     streakLabel: "Not done in 20 days"),
            HabitRow(habitName: "Brush teeth",
                     streakLabel: "3 day steak"),
            HabitRow(habitName: "Floss",
                     streakLabel: "Not done in 2 days"),
            HabitRow(habitName: "Work out",
                     streakLabel: "1 day steak"),
            HabitRow(habitName: "Stretch",
                     streakLabel: "14 day streak")
        ]
        super.init(coder: aDecoder, rootView: HabitList(habitRows: habitRows))
    }
}

struct HabitList: View {
    
    @Environment(\.managedObjectContext) var moc
    
    var habitRows: [HabitRow] = []
    
    var body: some View {
        VStack {
            Text("Hello World!")
            List(0 ..< habitRows.count, id: \.self) { i in
                habitRows[i]
            }
        }
    }
}

struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        let habitRows = [
            HabitRow(habitName: "Baseball",
                     streakLabel: "Not done in 20 days"),
            HabitRow(habitName: "Brush teeth",
                     streakLabel: "3 day steak"),
            HabitRow(habitName: "Floss",
                     streakLabel: "Not done in 2 days"),
            HabitRow(habitName: "Work out",
                     streakLabel: "1 day steak"),
            HabitRow(habitName: "Stretch",
                     streakLabel: "14 day streak")
        ]
        HabitList(habitRows: habitRows)
    }
}

struct HabitRow: View {
    var habitName = "Habit Name"
    
    @State var secondaryLabel = ""
    @State var streakLabel = "Streak label"
    @State var timerLabel = "3:15"
    @State var showTimer = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func ringButtonCallback(state: Bool) {
        showTimer = state
    }
    
    var body: some View {
        HStack {
            VStack {
                RingView(percent: 0,
                         size: 28,
                         buttonCallback: ringButtonCallback)
            }
            VStack(alignment: .leading) {
                
                Text(habitName)
                    .font(.system(size: 16))
                
                Text(streakLabel)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.519))
                    .transition(.opacity)
                    .onReceive(timer, perform: { date in
                        timerLabel = "\(date)"
                        secondaryLabel = showTimer ? timerLabel : streakLabel
                    })
            }
            Spacer()
            
            // TODO replace with navigation link
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 7)
                .foregroundColor(Color.gray)
        }
    }
}
