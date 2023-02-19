//
//  ReusableProfileContent.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-02-05.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack (spacing: 12) {
                    WebImage(url: user.userProfileURL).placeholder {
                        //MARK: Placeholder image
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        //MARK: Displaying bio link, if given while signing up profile page
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("Posts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
                
                ReusablePostView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
            }
            .padding(15)
        }
    }
}
