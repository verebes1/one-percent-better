//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI
import CoreData

enum SettingsNavRoute: Hashable {
   case appearance
   case dailyReminder(Settings)
   case habitNotifications
   case importData
}

struct SettingsView: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @FetchRequest(entity: Settings.entity(), sortDescriptors: []) private var settings: FetchedResults<Settings>
   
   @State private var exportJson: URL = URL(fileURLWithPath: "")
   @State private var showActivityController = false
   @State private var fileContent = ""
   @State private var showDocumentPicker = false
   
   var exportManager = ExportManager()
   
   var versionFooter: some View {
      VStack {
         HStack {
            Spacer()
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unkown"
            Text("Version \(appVersion)")
            Spacer()
         }
         Text("Made by ") + Text("Jeremy").foregroundColor(.primary)// + Text(" from 🇺🇸")
      }
   }
   
   var body: some View {
      NavigationStack {
         Background {
            VStack {
               if let settings = settings.first {
                  List {
                     // Appearance Row
                     /*
                     Section(header: Text("Appearance (Coming Soon)")) {
                        NavigationLink(value: SettingsNavRoute.appearance) {
                           ChangeAppearanceRow()
                              .environmentObject(vm)
                        }
                     }
                     .listRowBackground(Color.cardColor)
                      */
                     
                     Section(header: Text("Notifications")) {
                        NavigationLink(value: SettingsNavRoute.dailyReminder(settings)) {
                           DailyReminderRow()
                              .environmentObject(settings)
                        }
                        
                        // Habit Notifications Debug View
                        /*
                        NavigationLink(value: SettingsNavRoute.habitNotifications) {
                           IconTextRow(title: "Habit Notifications", icon: "bell.fill", color: .cyan)
                        }
                         */
                     }
                     .listRowBackground(Color.cardColor)
                     
//                     Section(header: Text("Data")) {
//                        Button {
//                           if let jsonFile = exportManager.createJSON(context: CoreDataManager.shared.mainContext) {
//                              exportJson = jsonFile
//                              showActivityController = true
//                           }
//                        } label: {
//                           IconTextRow(title: "Export Data", icon: "square.and.arrow.up", color: .red)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Button {
//                           showDocumentPicker = true
//                        } label: {
//                           IconTextRow(title: "Import Data", icon: "square.and.arrow.down", color: .blue)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                     }
//                     .listRowBackground(Color.cardColor)
                     
                     Section(footer: versionFooter) {}
                        .listRowBackground(Color.cardColor)
                  }
                  .listStyle(.insetGrouped)
                  .scrollContentBackground(.hidden)
                  .navigationDestination(for: SettingsNavRoute.self) { route in
                     switch route {
                     case .appearance:
                        // TODO: Make this a menu, or a whole view?
                        // Maybe a whole view with an animated sun/moon which show and hide
                        EmptyView()
                     case .dailyReminder(let settings):
                           DailyReminder(settings: settings)
                     case .habitNotifications:
                        AllHabitNotifications()
                     case .importData:
                        DocumentPicker()
                     }
                  }
                  .sheet(isPresented: $showDocumentPicker) {
                     DocumentPicker()
                  }
                  .sheet(isPresented: $showActivityController) {
                     ActivityViewController(jsonFile: $exportJson)
                  }
               }
            }
         }
         .navigationTitle("Settings")
      }
   }
}

struct SettingsView_Previews: PreviewProvider {
   static var previews: some View {
      NavigationStack {
         let moc = CoreDataManager.previews.mainContext
         let _ = Settings(myContext: moc)
         SettingsView()
            .environment(\.managedObjectContext, moc)
      }
   }
}
