//
//  Avinash_MCA4App.swift
//  Avinash_MCA4
//
//  Created by Sahil Sharma on 29/11/25.
//

import SwiftUI

@main
struct Avinash_MCA4App: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
