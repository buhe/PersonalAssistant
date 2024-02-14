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
    @AppStorage(wrappedValue: true, "first") var first: Bool
    var body: some Scene {
        WindowGroup {
            if first {
                Use {
                    first = false
                }
            } else {
                ContentView(viewModel: ViewModel())
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
        .defaultSize(width: 800, height: 800)
    }
}
