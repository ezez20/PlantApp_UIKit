//
//  DeleteAccountViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 2/21/23.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseFirestore
import FirebaseStorage

class DeleteAccountViewController: UIViewController {
    
    let instructionTitle = UILabel()
    
    let emailTextfieldView = UIView()
    let emailTextfield = UITextField()
    
    let passwordTextfieldView = UIView()
    let passwordTextfield = UITextField()
    let revealPasswordButton = UIButton()
    
    let deleteAccountButton = UIButton()
    let defaults = UserDefaults.standard
    
    // MARK: - Core Data - Persisting data
    var plants: [Plant]!
    var context : NSManagedObjectContext!
    let deleteDataGroup = DispatchGroup()
    
    deinit {
        print("DeleteAccountVC has been deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Delete account"
        
        view.addSubview(instructionTitle)
        instructionTitle.translatesAutoresizingMaskIntoConstraints = false
        instructionTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        instructionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instructionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        instructionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        instructionTitle.sizeToFit()
        instructionTitle.numberOfLines = 2
        instructionTitle.text = "Please enter your email and password to proceed deleting your account:"
        instructionTitle.tintColor = .lightText
        
        view.addSubview(emailTextfieldView)
        emailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextfieldView.topAnchor.constraint(equalTo: instructionTitle.bottomAnchor, constant: 10).isActive = true
        emailTextfieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        emailTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextfieldView.backgroundColor = .white
        
        emailTextfieldView.addSubview(emailTextfield)
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.topAnchor.constraint(equalTo: emailTextfieldView.topAnchor, constant: 5).isActive = true
        emailTextfield.leftAnchor.constraint(equalTo: emailTextfieldView.leftAnchor, constant: 20).isActive = true
        emailTextfield.rightAnchor.constraint(equalTo: emailTextfieldView.rightAnchor, constant: -20).isActive = true
        emailTextfield.bottomAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: -5).isActive = true
        emailTextfield.backgroundColor = .white
        emailTextfield.placeholder = "Email address"
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.autocorrectionType = .no
        emailTextfield.autocapitalizationType = .none
        emailTextfield.delegate = self

        view.addSubview(passwordTextfieldView)
        passwordTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfieldView.topAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: 10).isActive = true
        passwordTextfieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        passwordTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextfieldView.backgroundColor = .white
        
        passwordTextfieldView.addSubview(revealPasswordButton)
        revealPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        revealPasswordButton.rightAnchor.constraint(equalTo: passwordTextfieldView.rightAnchor).isActive = true
        revealPasswordButton.centerYAnchor.constraint(equalTo: passwordTextfieldView.centerYAnchor).isActive = true
        revealPasswordButton.heightAnchor.constraint(equalTo: passwordTextfieldView.heightAnchor).isActive = true
        revealPasswordButton.widthAnchor.constraint(equalTo: passwordTextfieldView.heightAnchor).isActive = true
        revealPasswordButton.backgroundColor = .clear
        revealPasswordButton.tintColor = .lightGray
        revealPasswordButton.addTarget(self, action: #selector(revealPasswordButtonClicked(sender:)), for: .touchUpInside)
        
        passwordTextfieldView.addSubview(passwordTextfield)
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.topAnchor.constraint(equalTo: passwordTextfieldView.topAnchor, constant: 5).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: passwordTextfieldView.leftAnchor, constant: 20).isActive = true
        passwordTextfield.rightAnchor.constraint(equalTo: revealPasswordButton.leftAnchor).isActive = true
        passwordTextfield.bottomAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: -5).isActive = true
        passwordTextfield.backgroundColor = .white
        passwordTextfield.placeholder = "Password"
        passwordTextfield.keyboardType = .emailAddress
        passwordTextfield.keyboardType = .default
        passwordTextfield.autocapitalizationType = .none
        passwordTextfield.autocorrectionType = .no
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.delegate = self
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.topAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: 20).isActive = true
        deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteAccountButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        deleteAccountButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        deleteAccountButton.layer.cornerRadius = 15
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.isEnabled = false
        deleteAccountButton.backgroundColor = UIColor(named: "customRed")
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonPressed), for: .touchUpInside)
    }
    
    
    
    @objc func deleteAccountButtonPressed() {
        print("deleteAccountButtonPressed")
        deleteAccountFB()
    }
    
    @objc private func revealPasswordButtonClicked(sender: UIButton) {
        print("dd")
        passwordTextfield.isSecureTextEntry.toggle()
        if passwordTextfield.isSecureTextEntry == false {
            revealPasswordButton.tintColor = .darkGray
        } else {
            revealPasswordButton.tintColor = .lightGray
        }
    }

}

extension DeleteAccountViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateEntry()
    }
    
    func validateEntry() {
        
        if emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            deleteAccountButton.isEnabled = false
            deleteAccountButton.backgroundColor = UIColor(named: "customRed")
        } else {
            deleteAccountButton.isEnabled = true
            deleteAccountButton.backgroundColor = .systemRed
        }
        
        if !passwordTextfield.text!.isEmpty {
            revealPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            revealPasswordButton.setImage(UIImage(systemName: ""), for: .normal)
        }
        
    }
    
}

extension DeleteAccountViewController {
    
    func getFBUserEmail() -> String {
        guard let userEmail = Auth.auth().currentUser?.email else { return "" }
        return userEmail
    }
    
    func deleteAccountFB() {
        
        let user = Auth.auth().currentUser

        // Prompt the user to re-provide their sign-in credentials
        let credential = EmailAuthProvider.credential(withEmail: emailTextfield.text!, password: passwordTextfield.text!)
        user?.reauthenticate(with: credential) { result, error in
            if result != nil {
                // User re-authenticated.
                print("User re-authenticated")
                
                self.deleteAccount_FB()

            } else {
                // An error happened.
                self.instructionTitle.text = "Error deleting account. Please try again."
                print("Error authenticating user")
            }
        }
        
    }
    
    func updatePlants() {
        do {
            try context.save()
        } catch {
            print("Error updating plants. Error: \(error)")
        }
    }


    func deleteAccount_FB() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // 1: Delete
        deleteUserData_FB(user: currentUser)
        
        // Call deleteUser only when all data has been deleted
        deleteDataGroup.notify(queue: .main) {
            print("Previous work has finished")
            self.deleteUser_FB(user: currentUser)
        }
        
        
    }
    
    // Delete from Firebase Firestore/Storage
    func deleteUserData_FB(user currentUser: User) {
    
        let db = Firestore.firestore()
        let plantsSubCollection = db.collection("users").document(currentUser.uid).collection("plants")
        
        // 1: Delete subcollection(plants) in Firestore
        if plants.isEmpty {
            print("Plants is empty. Nothing to delete.")
        } else {
            for p in plants {
                deleteDataGroup.enter()
                print("DDG1 - ENTER CLOSURE")
                if let docIDToDelete = p.id?.uuidString {
                    plantsSubCollection.document(docIDToDelete).delete() { error in
                        if error != nil { print("Error deleting doc from plants subcollection, ID: \(docIDToDelete)")
                            self.deleteDataGroup.leave()
                            print("DDG1 - LEAVE INNER CLOSURE")
                        }
                        
                    }
                    
                }
                deleteDataGroup.leave()
                print("DDG1 - LEAVE CLOSURE")
            }
        }
        
        
        // 2: Loop through Firebase Storage to delete custom plant photos
        if plants.isEmpty {
            print("Plants is empty. Nothing to delete.")
        } else {
            for p in plants {
                deleteDataGroup.enter()
                print("DDG2 - ENTER CLOSURE")
                if p.customPlantImageID != nil {
                    deleteDataGroup.enter()
                    print("DDG2 - ENTER INNER CLOSURE")
                    let customPlantImageIDToDelete = p.customPlantImageID
                    let fileRef = Storage.storage().reference(withPath: customPlantImageIDToDelete!)
                    fileRef.delete { error in
                        if error != nil { print("Error deleting from Firebase Storage: \(String(describing: error))") }
                        self.deleteDataGroup.leave()
                        print("DDG2 - LEAVE INNER INNERCLOSURE")
                    }
                }
                deleteDataGroup.leave()
                print("DDG2 LEAVE CLOSURE")
            }
        }
        
        // 3: Delete "user"'s collection from Firestore Database.
        deleteDataGroup.enter()
        print("DDD3 ENTER")
        db.collection("users").document(currentUser.uid).delete() { error in
            if error != nil { print("Error: \(String(describing: error))") }
            self.deleteDataGroup.leave()
            print("DDG3 - LEAVE CLOSURE")
        }
     
    }

    // Delete User function for Firebase
    func deleteUser_FB(user currentUser: User) {
        currentUser.delete { [self] error in
            if let nsError = error as? NSError {
                if AuthErrorCode(_nsError: nsError).code == AuthErrorCode.requiresRecentLogin {
                    print("FB User requires re-authentication")
                    self.reauthenticate()
                } else {
                    // Another error occurred
                    print("An error occured deleting FB account. Error: \(String(describing: error))")
                }
                return
            }

            // Logout
            deleteDataGroup.enter()
            do {
                
                try Auth.auth().signOut()
                
                defaults.set(false, forKey: "fbUserFirstLoggedIn")
                print("Successfully signed out of FB")
                deleteDataGroup.leave()
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                deleteDataGroup.leave()
            }
            
            // Ensures to delete in Core Data before signing out.
            if plants.count != 0 {
                for i in 0...plants.endIndex - 1 {
                    deleteDataGroup.enter()
                    context.delete(plants[i])
                    updatePlants()
                    deleteDataGroup.leave()
                }
            }
            
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutTriggered"), object: nil)
              defaults.set(true, forKey: "firstUpdateUserSettings")
              defaults.set(true, forKey: "loginVCReload")
              defaults.set(false, forKey: "userDiscardedApp")
              defaults.set(false, forKey: "notificationOn")
              defaults.set(0, forKey: "selectedAlertOption")
              dismiss(animated: true)
        }
    }

    func reauthenticate() {
        
        let credential = EmailAuthProvider.credential(withEmail: emailTextfield.text!, password: passwordTextfield.text!)
        Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
            if let error = error {
                print(error)
                return
            }

            Auth.auth().currentUser?.reload { error in
                if let error = error {
                    print(error)
                    return
                }
                self.deleteAccountFB()
            }
        }
        
    }
    
}

extension Date {
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
}
