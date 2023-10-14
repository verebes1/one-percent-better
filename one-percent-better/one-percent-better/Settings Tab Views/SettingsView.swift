//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI
import CoreData

enum SettingsNavRoute: Hashable {
    case dailyReminder(Settings)
    case habitNotifications
    case feedback
    case privacy
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
        }
    }
    
    var body: some View {
        Background {
            VStack {
                if let settings = settings.first {
                    List {
                        // Appearance
                        Section(header: Text("Appearance")) {
                            ChangeAppearanceRow()
                            ChangeStartingWeekdayView()
                        }
                        .listRowBackground(Color.cardColor)
                        
                        // Notifications
                        Section(header: Text("Notifications")) {
                            NavigationLink(value: SettingsNavRoute.dailyReminder(settings)) {
                                DailyReminderRow()
                            }
                            
                            // Habit Notifications Debug View
                            /*
                             NavigationLink(value: SettingsNavRoute.habitNotifications) {
                             IconTextRow(title: "Habit Notifications", icon: "bell.fill", color: .cyan)
                             }
                             */
                        }
                        .listRowBackground(Color.cardColor)
                        
                        // Feedback
                        Section(header: Text("Share")) {
                            
                            ShareLink(item: URL(string: "https://testflight.apple.com/join/LJ9NUdbc")!) {
                                IconTextRow(title: "Share Beta Link", icon: "link", color: .appIconColor)
                            }
                            .foregroundColor(.label)
                            
                            NavigationLink(value: SettingsNavRoute.feedback) {
                                IconTextRow(title: "Share Feedback", icon: "arrowshape.turn.up.right.fill", color: .blue)
                            }
                        }
                        .listRowBackground(Color.cardColor)
                        
                        // Privacy
                        Section {
                            NavigationLink(value: SettingsNavRoute.privacy) {
                                IconTextRow(title: "Privacy Policy", icon: "lock.fill", color: .teal)
                            }
                        } header: {
                            Text("Privacy")
                        }
                        .listRowBackground(Color.cardColor)

                        
                        Section(footer: versionFooter) {}
                            .listRowBackground(Color.cardColor)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .environmentObject(settings)
                    .navigationDestination(for: SettingsNavRoute.self) { route in
                        switch route {
                        case .dailyReminder(let settings):
                            DailyReminder(settings: settings)
                        case .habitNotifications:
                            AllHabitNotifications()
                        case .feedback:
                            ShareBetaFeedback()
                        case .privacy:
                            PrivacyPolicy()
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
