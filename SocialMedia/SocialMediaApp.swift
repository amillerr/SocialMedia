//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-01-27.
//

import SwiftUI
import Firebase

@main
struct SocialMediaApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
