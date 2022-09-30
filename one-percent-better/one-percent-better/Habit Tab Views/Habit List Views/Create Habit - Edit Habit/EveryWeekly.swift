//
//  EveryWeekly.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import SwiftUI


struct EveryWeekly: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var frequencyText = "1"
    
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    @Binding var selectedWeekdays: [Int]
    
    private var backgroundColor: Color {
        colorScheme == .light ?
        Color(#colorLiteral(red: 0.9310173988, green: 0.9355356693, blue: 0.935390532, alpha: 1))
        :
        Color(#colorLiteral(red: 0.1921563745, green: 0.1921573281, blue: 0.2135840654, alpha: 1))
        
    }
    private let selectedTextColor = Color(#colorLiteral(red: 0.8744927645, green: 0.9400271177, blue: 0.9856405854, alpha: 1))
    
    private var textColor: Color {
        colorScheme == .light ?
        Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        :
        Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    private let selectedBackground = Color(#colorLiteral(red: 0.4746856689, green: 0.6031921506, blue: 0.9928647876, alpha: 1))
    
    func updateSelection(_ i: Int) {
        if selectedWeekdays.count == 1 && i == selectedWeekdays[0] {
            return
        }
        if let index = selectedWeekdays.firstIndex(of: i) {
            selectedWeekdays.remove(at: index)
        } else {
            selectedWeekdays.append(i)
        }
    }
    
    var body: some View {
        VStack {
            Text("Every week on")
            HStack(spacing: 3) {
                ForEach(0 ..< 7) { i in
                    ZStack {
                        let isSelected = selectedWeekdays.contains(i)
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(isSelected ? selectedBackground : backgroundColor)
                        
                        Text(weekdays[i])
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundColor(isSelected ? selectedTextColor : textColor)
                    }
                    .frame(height: 30)
                    .onTapGesture {
                        updateSelection(i)
                    }
                }
            }
            .padding(.horizontal, 25)
        }
        .padding()
    }
}

struct EveryWeeklyPreviews: View {
    @State var selectedWeekdays: [Int] = [1,2]
    var body: some View {
        CardView {
            EveryWeekly(selectedWeekdays: $selectedWeekdays)
        }
    }
}


struct EveryWeekly_Previews: PreviewProvider {
    static var previews: some View {
        EveryWeeklyPreviews()
    }
}
