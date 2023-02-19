//
//  ProfileView.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-02-03.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    //MARK: My profile data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    //MARK: View properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let myProfile {
                    ReusableProfileContent(user: myProfile)
                .refreshable {
                //MARK: Refresh user data
                    self.myProfile = nil
                    await fetchUserData()
            }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        //MARK: Two actions
                        //1. Logout
                        Button("Logout", action: logOutUser)
                        //2. Delete Account
                        Button("Delete account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
        }
        .task {
            //This modifier is like onAppear
            //so fetching for the first time only
            if myProfile != nil { return }
            //MARK: Initial fetch
            await fetchUserData()
        }
    }
    
    //MARK: Fetching user data
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else { return }
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    //MARK: Logging user out
    func logOutUser() {
        try? Auth.auth().signOut()
        logStatus = false
        print("User logout")
    }
    
    //MARK: Deleting user entire account
    func deleteAccount() {
        isLoading = true
        Task {
            do {
                guard let userUID =  Auth.auth().currentUser?.uid else { return }
                // Step 1: First deleting profile image from storage
                let reference = Storage.storage().reference().child("Profile_images").child(userUID)
                try await reference.delete()
                // Step 2: Deleting firestore user document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                // Step 3: Deleting auth account and setting log status to false
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            } catch {
                await setError(error)
            }
        }
    }
    
    //MARK: Setting error
    func setError(_ error: Error) async {
        //MARK: UI must be run on main thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
