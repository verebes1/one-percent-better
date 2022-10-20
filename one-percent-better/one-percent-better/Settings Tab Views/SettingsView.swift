//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI
import CoreData

enum SettingsNavRoute: Hashable {
   case dailyReminder
}

class SettingsViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   private let settingsController: NSFetchedResultsController<Settings>
   private let moc: NSManagedObjectContext
   
   init(_ context: NSManagedObjectContext) {
      settingsController = Settings.resultsController(context: context, sortDescriptors: [])
      moc = context
      super.init()
      settingsController.delegate = self
      try? settingsController.performFetch()
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      objectWillChange.send()
   }
   
   var settings: Settings {
      guard let settingsArr = settingsController.fetchedObjects else {
         fatalError("Unable to retrieve settings")
      }
      
      if settingsArr.isEmpty {
         let set = Settings(myContext: moc)
         moc.fatalSave()
         return set
      }
      
      guard settingsArr.count == 1 else {
         fatalError("Not exactly 1 setting! Count: \(settingsArr.count)")
      }
      
      return settingsArr[0]
   }
}

struct SettingsView: View {
   
   @Environment(\.managedObjectContext) var moc
   
   var exportManager = ExportManager()
   
   @ObservedObject var vm: SettingsViewModel
   
   @State private var exportJson: URL = URL(fileURLWithPath: "")
   @State private var showActivityController = false
   @State private var fileContent = ""
   @State private var showDocumentPicker = false
   
   var body: some View {
      NavigationStack {
         Background {
            VStack {
               List {
                  Section(header: Text("Notifications")) {
                     NavigationLink(value: SettingsNavRoute.dailyReminder) {
                        DailyReminderRow()
                           .environmentObject(vm)
                     }
                  }
                  
                  Section(header: Text("Data")) {
                     Button {
                        if let jsonFile = exportManager.createJSON(context: CoreDataManager.shared.mainContext) {
                           exportJson = jsonFile
                           showActivityController = true
                        }
                     } label: {
                        IconTextRow(title: "Export Data", icon: "square.and.arrow.up", color: .red)
                     }
                     .buttonStyle(PlainButtonStyle())
                     
                     Button {
                        showDocumentPicker = true
                     } label: {
                        IconTextRow(title: "Import Data", icon: "square.and.arrow.down", color: .blue)
                     }
                     .buttonStyle(PlainButtonStyle())
                  }
                  .sheet(isPresented: $showActivityController, content: {
                     ActivityViewController(jsonFile: $exportJson)
                  })
                  .sheet(isPresented: $showDocumentPicker) {
                     DocumentPicker(fileContent: $fileContent)
                  }
               }
               .listStyle(.insetGrouped)
               .navigationDestination(for: SettingsNavRoute.self) { route in
                  DailyReminder()
               }
            }
         }
         .navigationTitle("Settings")
      }
   }
}

struct SettingsView_Previews: PreviewProvider {
   
   static func data() {
      let context = CoreDataManager.previews.mainContext
      let _ = Settings(context: context)
   }
   
   static var previews: some View {
      let moc = CoreDataManager.previews.mainContext
      let _ = data()
      SettingsView(vm: SettingsViewModel(moc))
   }
}
