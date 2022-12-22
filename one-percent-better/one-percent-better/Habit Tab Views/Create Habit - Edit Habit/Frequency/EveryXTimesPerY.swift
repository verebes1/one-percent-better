//
//  EveryXTimesPerY.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/14/22.
//

import SwiftUI

struct EveryXTimesPerY: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @Binding var timesPerDay: Int
   let tpdRange = 1 ... 100
   
   private let backgroundColor = Color(#colorLiteral(red: 0.9061154127, green: 0.9810385108, blue: 1, alpha: 1))
   
   
   enum Period: String {
      case day = "Day"
      case week = "Week"
   //   case month = "Month"
   }
   
   @State private var periodSelection: Period = .day
   
   var isPlural: Binding<Bool> {
      Binding {
         timesPerDay > 1
      } set: { _, _ in
         // do nothing
      }
   }
   
   var body: some View {
      HStack(spacing: 5) {
         
         // Times selection
         Menu {
            Button("1", action: {})
            Button("2", action: {})
            Button("3", action: {})
            Button("Custom", action: {})
            
         } label: {
            RoundedDropDownMenuButton(text: "\(timesPerDay)", color: .blue)
         }
         
         
         HStack(spacing: 0) {
            Text(" ")
            AnimatedTimesText(plural: isPlural)
            Text(" every ")
         }
         .foregroundColor(.label)
         
         // Period selection
         Menu {
            // Day
            Button {
               periodSelection = .day
            } label: {
               Label(Period.day.rawValue,
                     systemImage: periodSelection == .day ? "checkmark" : "")
            }
            // Week
            Button {
               periodSelection = .week
            } label: {
               Label(Period.week.rawValue,
                     systemImage: periodSelection == .week ? "checkmark" : "")
            }
         } label: {
            RoundedDropDownMenuButton(text: periodSelection.rawValue, color: .blue)
         }
      }
      .padding(.vertical, 30)
   }
}

struct EveryXTimesPerYPreviewContainer: View {
   
   @StateObject var vm = FrequencySelectionModel(selection: .timesPerDay(2))
   @State private var timesPerDay = 3
   
   var body: some View {
      Background {
         CardView {
            EveryXTimesPerY(timesPerDay: $timesPerDay)
               .environmentObject(vm)
         }
      }
   }
}

struct EveryXTimesPerY_Previews: PreviewProvider {
   static var previews: some View {
      EveryXTimesPerYPreviewContainer()
   }
}

