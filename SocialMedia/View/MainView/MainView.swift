//
//  MainView.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-02-03.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        //MARK: TabView with recent post's and profile tabs
        TabView {
            Text("Recent Post's")
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            
            Text("Profile View")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
