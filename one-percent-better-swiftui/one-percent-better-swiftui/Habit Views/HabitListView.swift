//
//  HabitListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData

struct HabitListView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)
    ]) var habits: FetchedResults<Habit>
    
    @State var isHabitsViewPresenting: Bool = false
    @State var currentDay = Date()
    
    /// Date formatter for the month year label at the top of the calendar
    var dateTitleFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
        return dateFormatter
    }()
    
    var body: some View {
        NavigationView {
            Background {
                VStack {
                    HabitsHeaderView(viewModel: HabitsHeaderViewModel(moc),
                                         currentDay: $currentDay)
                    
                    List {
                        ForEach(habits, id: \.self.name) { habit in
                            NavigationLink(
                                destination: ProgressView().environmentObject(habit)) {
                                    HabitRow(currentDay: currentDay)
                                        .environmentObject(habit)
                                        .animation(.easeInOut, value: currentDay)
                                }
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                    }
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(
                            destination: CreateNewHabit(rootPresenting: $isHabitsViewPresenting),
                            isActive: $isHabitsViewPresenting) {
                                Image(systemName: "square.and.pencil")
                            }
                    }
                }
                .navigationTitle("\(dateTitleFormatter.string(from: currentDay))")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear {
                UITableView.appearance().contentInset.top = -25
                
                if !Calendar.current.isDate(currentDay, inSameDayAs: Date()) {
                    currentDay = Date()
                }
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        // Make an array from fetched results
        var revisedItems: [Habit] = habits.map{ $0 }
        
        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        // Update the orderIndex indices
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
        }
        try? moc.save()
    }
    
    private func delete(from source: IndexSet) {
        // Make an array from fetched results
        var revisedItems: [Habit] = habits.map{ $0 }
        
        // Remove the item to be deleted
        guard let index = source.first else { return }
        let habitToBeDeleted = revisedItems[index]
        revisedItems.remove(atOffsets: source)
        moc.delete(habitToBeDeleted)
        
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
        }
        try? moc.save()
    }
}

struct HabitsView_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewData.habitViewData()

        return HabitListView()
            .environment(\.managedObjectContext, CoreDataManager.previews.persistentContainer.viewContext)
    }
}

struct HabitRow: View {
    
    @EnvironmentObject var habit: Habit
    
    var currentDay: Date
    
    var body: some View {
        HStack {
            VStack {
                HabitCompletionCircle(currentDay: currentDay,
                                      size: 28)
            }
            VStack(alignment: .leading) {
                
                Text(habit.name)
                    .font(.system(size: 16))
                
                if Calendar.current.isDateInToday(currentDay) {
                    Text(habit.streakLabel)
                        .font(.system(size: 11))
                        .foregroundColor(habit.streakLabelColor)
                }
            }
            Spacer()
        }
    }
}
