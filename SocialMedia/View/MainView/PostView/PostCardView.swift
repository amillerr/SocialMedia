//
//  PostCardView.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-02-18.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import SDWebImageSwiftUI

struct PostCardView: View {
    var post: Post
    /// Callbacks
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    /// View properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListner: ListenerRegistration?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                /// Post image if any
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                PostInteraction()
            }
        }
        .vAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            /// Displaying delete button ( if it's author of that post )
            if post.userUID == userUID {
                Menu {
                    Button("Delete post", role: .destructive, action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear {
            /// Adding once only
            if docListner == nil {
                guard let postID = post.id else {return}
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot,
                    error in
                    if let snapshot {
                        if snapshot.exists{
                            ///  Document Updated
                            /// Fetching Updated Document
                            if let updatedPost = try? snapshot.data(as: Post.self){
                                onUpdate(updatedPost)
                            }
                        } else {
                            /// - Document deleted
                            onDelete()
                        }
                    }
                    
                })
            }
        }
        .onDisappear {
            // Applying snapshot listener only when the post is available on the screen
            // else removing listner ( it saved unwanted live updates from the posts which was swiped away from the screen )
            if let docListner {
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    
    //MARK: Like/dislike interactions
    @ViewBuilder
    func PostInteraction() -> some View {
        HStack(spacing: 6) {
            Button (action: likePost) {
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button (action: dislikePost){
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading, 25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical, 8)
    }
    
    /// Like post
    func likePost() {
        Task {
            guard let postID = post.id else { return }
            if post.likedIDs.contains(userUID) {
                /// Removing user ID from the array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                /// Adding user ID to the liked array and removing that id from disliked array ( if added ir prior )
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
                
            }
        }
    }
    
    /// Dislike post
    func dislikePost() {
        Task {
            guard let postID = post.id else { return }
            if post.dislikedIDs.contains(userUID) {
                /// Removing user ID from the array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                /// Adding user ID to the liked array and removing that id from disliked array ( if added ir prior )
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID]),
                    "dislikedIDs": FieldValue.arrayUnion([userUID])
                ])
                
            }
        }
    }
    
    /// Delete post
    func deletePost() {
        Task {
            /// Step 1: Delete image from firebase storage if present
            do {
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_images").child(post.imageReferenceID).delete()
                }
                /// Step 2: Delete firestore document
                guard let postID = post.id else { return }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
