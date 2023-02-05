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
            Text("Recent Posts")
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Posts")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        // Changing tab lable tint to black
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
