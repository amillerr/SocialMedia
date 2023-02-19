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
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    /// - View properties
    @State private var isFetching: Bool = true
    /// - Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?

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
            /// Disabling refresh for UID based posts
            guard !basedOnUID else { return }
            isFetching = true
            posts = []
            /// Reseting pagination doc
            paginationDoc = nil
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
            PostCardView(post: post) { updatedPost in
                /// Updating post in the array
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }) {
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                /// Removing post from the array
                withAnimation(.easeInOut(duration: 0.25)) {
                    posts.removeAll{post.id == $0.id}
                }
            }
            .onAppear {
                /// When last posr appears, fetching new post ( if threre )
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task {
                       await fetchPosts()
                    }
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    /// - Fetching posts
    func fetchPosts() async {
        do {
            var query: Query!
            /// - Implementing pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            
            /// New query for UID based document fetch
            /// Simply filter the posts which is not belongs to this uid
            if basedOnUID {
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
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
