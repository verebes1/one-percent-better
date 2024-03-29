//
//  DocumentPicker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/20/22.
//

import Foundation
import SwiftUI

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

   func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
      let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
      documentPicker.delegate = context.coordinator
      documentPicker.allowsMultipleSelection = false
      documentPicker.modalPresentationStyle = .popover
      return documentPicker
   }

   func makeCoordinator() -> DocumentPickerCoordinator {
      return DocumentPickerCoordinator()
   }

   func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
      // Do nothing
   }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {

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
            print("habit: \(habit.name)")
            for t in habit.trackers {
               if let t = t as? Tracker {
                  print("habit: \(habit.name), tracker: \(t.name), t.habit: \(t.habit.name)")
               }
            }
         }
         FeatureLogController.shared.setUp()
         CoreDataManager.shared.saveContext()
      } catch {
         print("unable to load data: \(error)")
      }

      if relinquish {
         url.stopAccessingSecurityScopedResource()
      }
      controller.dismiss(animated: true)

   }

   public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      controller.dismiss(animated: true)
   }
}
