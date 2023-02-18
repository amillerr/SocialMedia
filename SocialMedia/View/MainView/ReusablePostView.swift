//
//  ReusablePostView.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-02-13.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusablePostView: View {
    @Binding var posts: [Post]
    /// - View properties
    @State var isFetching: Bool = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty {
                        /// No Posts found on Firestore
                        Text("No posts found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    } else {
                        /// Displaying Posts
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            /// Scroll to refresh
            isFetching = true
            posts = []
            await fetchPosts()
        }
        .task {
            /// Fetching for one time
            guard posts.isEmpty else { return }
            await fetchPosts()
        }
    }
    
    /// - Displaying fetched posts
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatePost in
                
            } onDelte: {
                
            }
        }
    }
    
    /// - Fetching posts
    func fetchPosts() async {
        do {
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
