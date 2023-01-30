//
//  LoginView.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-01-27.
//

import SwiftUI
import PhotosUI
import Firebase

struct LoginView: View {
    //MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    
    //MARK: View properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed.")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button (action: loginUser) {
                    //MARK: Login button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 12)
            }
            
            //MARK: Register button
            HStack {
                Text("Don't have an account")
                    .foregroundColor(.gray)
                
                Button("Register now") {
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        
        //MARK: Register view via Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        //MARK: Displaying alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser() {
        Task {
            do {
                //With the help of Swift Concurrency Auth can be done with single line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User found")
            } catch {
               await setError(error)
            }
        }
    }
    
    func resetPassword() {
        Task {
            do {
                //With the help of Swift Concurrency Auth can be done with single line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link sent")
            } catch {
               await setError(error)
            }
        }
    }
    
    //MARK: Displaying errors via Alerts
    func setError(_ error: Error) async {
        //MARK: UI must be updated on main thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

//MARK: Register view
struct RegisterView: View {
    //MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    //MARK: View properties
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Register \nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello, have a wonderful journey.")
                .font(.title3)
                .hAlign(.leading)
            
            //MARK: For smaller size optimization
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                HelperView()
            }
            
            //MARK: Register button
            HStack {
                Text("Already have an account")
                    .foregroundColor(.gray)
                
                Button("Login now") {
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            //MARK: Extracting UIIMage from PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self)
                        else { return }
                        //MARK: UI must be updated on main thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch {}
                }
            }
        }
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePicData,let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $userName)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))

            
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))

            Button (action: registerUser){
                //MARK: Login button
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .padding(.top, 12)
        }
    }
    
    func registerUser() {
        Task {
            do {
                
            } catch {
                await setError(error)
            }
        }
    }
    
    //MARK: Displaying errors via Alerts
    func setError(_ error: Error) async {
        //MARK: UI must be updated on main thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

//MARK: View Extensions for UI Building
extension View {
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
//MARK: Custom border View with padding
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    //MARK: Custom fill View with padding
        func fillView(_ color: Color) -> some View {
            self
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(color)
                }
        }
}


