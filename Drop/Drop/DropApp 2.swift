//
//  DropApp.swift
//  Drop
//
//  Created by Angel Aarón Muñoz Alvarez on 18/04/26.
//

import SwiftUI

@main
struct DropApp: App {
    init() {
        // Limpia cualquier userId guardado de sesiones anteriores que fallaron
        UserDefaults.standard.removeObject(forKey: "dropUserId")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
