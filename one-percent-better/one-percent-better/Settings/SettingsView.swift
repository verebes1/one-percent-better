//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI

struct SettingsItem {
    var title: String
    var systemImage: String
    var color: Color
}

struct SettingsView: View {
    
    var exportManager = ExportManager()
    @State private var exportJson: URL = URL(fileURLWithPath: "")
    @State private var showActivityController = false
    let exportData = SettingsItem(title: "Export Data",
                                  systemImage: "square.and.arrow.up",
                                  color: .red)
    
    let importData = SettingsItem(title: "Import Data",
                                  systemImage: "square.and.arrow.down",
                                  color: .blue)
    @State private var fileContent = ""
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationView {
            Background {
                VStack {
                    Spacer().frame(height: 10)
                    List {
                        Button {
                            if let jsonFile = exportManager.createJSON(context: CoreDataManager.shared.mainContext) {
                                exportJson = jsonFile
                                showActivityController = true
                            }
                        } label: {
                            SettingsRow(item: exportData)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                        
                        Button {
                            showDocumentPicker = true
                        } label: {
                            SettingsRow(item: importData)
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

struct SettingsRow: View {
    
    var item: SettingsItem
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .foregroundColor(item.color)
                Image(systemName: item.systemImage)
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 28)
            Text(item.title)
                .font(.system(size: 18))
            Spacer()
        }
        .frame(height: 20)
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
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
    }
    
}
