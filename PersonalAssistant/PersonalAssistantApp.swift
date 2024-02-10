//
//  PersonalAssistantApp.swift
//  PersonalAssistant
//
//  Created by 顾艳华 on 2/10/24.
//

import SwiftUI

@main
struct PersonalAssistantApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
