//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI

enum SettingsNavRoute: Hashable {
   case dailyReminder
}

struct SettingsView: View {
   
   @FetchRequest(sortDescriptors: []) var settings: FetchedResults<Settings>
   @Environment(\.managedObjectContext) var moc
   
   var exportManager = ExportManager()
   @State private var exportJson: URL = URL(fileURLWithPath: "")
   @State private var showActivityController = false
   @State private var fileContent = ""
   @State private var showDocumentPicker = false
   
   init() {
      _settings = FetchRequest<Settings>(sortDescriptors: [])
   }
   
   var body: some View {
      NavigationStack {
         Background {
            VStack {
               List {
                  Section(header: Text("Notifications")) {
                     NavigationLink(value: SettingsNavRoute.dailyReminder) {
                        IconTextRow(title: "Daily Reminder", icon: "bell.fill", color: .pink)
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
               
               if !settings.isEmpty {
                  Text("Notifications enabled: \(String(describing: settings[0].dailyReminderEnabled))")
               }
            }
            
         }
         .navigationTitle("Settings")
      }
   }
}

struct SettingsView_Previews: PreviewProvider {
   static var previews: some View {
      SettingsView()
   }
}

struct ActivityViewController: UIViewControllerRepresentable {
   
   @Binding var jsonFile: URL
   
   func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
      
      let activityViewController = UIActivityViewController(activityItems: [jsonFile], applicationActivities: nil)
      return activityViewController
   }
   
   func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
      // Do nothing
   }
   
}

struct DocumentPicker: UIViewControllerRepresentable {
   
   @Binding var fileContent: String
   
   func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
      let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
      documentPicker.delegate = context.coordinator
      documentPicker.allowsMultipleSelection = false
      documentPicker.modalPresentationStyle = .popover
      return documentPicker
   }
   
   func makeCoordinator() -> DocumentPicker.Coordinator {
      return Coordinator()
   }
   
   func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
      // Do nothing
   }
   
   class Coordinator: NSObject, UIDocumentPickerDelegate {
      
      lazy var exportManager = ExportManager()
      
      public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
         guard let url = urls.first else {
            return
         }
         var relinquish = false
         do {
            relinquish = url.startAccessingSecurityScopedResource()
            let jsonData = try Data(contentsOf: url)
            do {
               let _: ExportContainer = try exportManager.load(jsonData)
            } catch {
               print("IMPORT DATA ERROR: \(error)")
               //                fatalError("\(#function) - Unexpected error: \(error)")
            }
            let habits = Habit.habits(from: CoreDataManager.shared.mainContext)
            for habit in habits {
               for t in habit.trackers {
                  if let t = t as? Tracker {
                     print("habit: \(habit.name), tracker: \(t.name), t.habit: \(t.habit.name)")
                  }
               }
            }
            CoreDataManager.shared.saveContext()
            FeatureLogController.shared.setUp()
         } catch {
            print("unable to load data: \(error)")
         }
         
         if relinquish {
            url.stopAccessingSecurityScopedResource()
         }
         controller.dismiss(animated: true)
      }
   }
   
}
