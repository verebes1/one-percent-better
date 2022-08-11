//
//  HabitsHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI
import CoreData

struct HabitsHeaderView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var vm: HabitListViewModel
    var color: Color = .systemTeal
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0 ..< 7) { i in
                    SelectedDayView(index: i,
                                    selectedWeekDay: $vm.selectedWeekDay,
                                    selectedWeek: $vm.selectedWeek,
                                    currentDay: $vm.currentDay,
                                    color: color)
                    .environmentObject(vm)
                }
            }
            .padding(.horizontal, 20)
            
            let ringSize: CGFloat = 27
            TabView(selection: $vm.selectedWeek) {
                ForEach(0 ..< vm.numWeeksSinceEarliest, id: \.self) { i in
                    HStack {
                        ForEach(0 ..< 7) { j in
                            let dayOffset = vm.dayOffset(week: i, day: j)
                            let dayOffsetFromEarliest = vm.dayOffsetFromEarliest(week: i, day: j)
                            let percent = vm.percent(week: i, day: j)
                            RingView(percent: percent,
                                     color: color,
                                     size: ringSize,
                                     withText: true)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                if dayOffset <= 0 && dayOffsetFromEarliest >= 0 {
                                    vm.selectedWeekDay = j
                                    let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
                                    vm.currentDay = newDay
                                }
                            }
                            .contentShape(Rectangle())
                            .opacity((dayOffset > 0 || dayOffsetFromEarliest < 0) ? 0.4 : 1)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: ringSize + 22)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: vm.selectedWeek, perform: { newWeek in
                // If scrolling to week which has dates ahead of today
                let today = Date()
                let currentOffset = vm.thisWeekDayOffset(today)
                if newWeek == (vm.numWeeksSinceEarliest - 1),
                   vm.selectedWeekDay > currentOffset {
                    vm.selectedWeekDay = currentOffset
                }
                
                // If scrolls to week which has days before the earliest start date
                if vm.date(week: newWeek, day: vm.selectedWeekDay) < vm.earliestStartDate {
                    vm.selectedWeekDay = vm.thisWeekDayOffset(vm.earliestStartDate)
                }
                
                let dayOffset = vm.dayOffset(week: newWeek, day: vm.selectedWeekDay)
                let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: today)!
                vm.currentDay = newDay
            })
        }
    }
    
}

struct HabitsListHeaderView_Previews: PreviewProvider {
    
    @State static var currentDay = Date()
    
    static func habitsListHeaderData() -> [Habit] {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -9, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Cook")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        let h2 = try? Habit(context: context, name: "Clean")
        h2?.markCompleted(on: day1)
        h2?.markCompleted(on: day2)
        
        let h3 = try? Habit(context: context, name: "Laundry")
        h3?.markCompleted(on: day2)
        
        let habits = Habit.habitList(from: context)
        return habits
    }
    
    static var previews: some View {
//        let habits = habitsListHeaderData()
        
        let moc = CoreDataManager.previews.persistentContainer.viewContext
        let vm = HabitListViewModel(moc)
        HabitsHeaderView()
            .environment(\.managedObjectContext, moc)
            .environmentObject(vm)
    }
}

struct SelectedDayView: View {
    
    @EnvironmentObject var viewModel: HabitListViewModel
    var index: Int
    @Binding var selectedWeekDay: Int
    @Binding var selectedWeek: Int
    @Binding var currentDay: Date
    var color: Color = .systemTeal
    
    func isIndexSameAsToday(_ index: Int) -> Bool {
        let dayIsSelectedWeekday = viewModel.thisWeekDayOffset(Date()) == index
        let weekIsSelectedWeek = selectedWeek == (viewModel.numWeeksSinceEarliest - 1)
        return dayIsSelectedWeekday && weekIsSelectedWeek
    }
    
    let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ZStack {
            let circleSize: CGFloat = 19
            let isSelected = index == viewModel.thisWeekDayOffset(currentDay)
            if isSelected {
                Circle()
                    .foregroundColor(isIndexSameAsToday(index) ? color : .systemGray2)
                    .frame(width: circleSize, height: circleSize)
            }
            Text(smwttfs[index])
                .font(.system(size: 12))
                .fontWeight(isIndexSameAsToday(index) && !isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .white : (isIndexSameAsToday(index) ? color : .secondary))
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            let dayOffset = viewModel.dayOffset(week: selectedWeek, day: index)
            if dayOffset <= 0 {
                selectedWeekDay = index
                currentDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            }
        }
    }
}
