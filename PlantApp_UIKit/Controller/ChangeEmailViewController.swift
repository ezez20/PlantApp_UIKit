//
//  ChangeEmailViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 2/14/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChangeEmailViewController: UIViewController {
    
    let instructionTitle = UILabel()
    let currentEmailLabel = UILabel()
    
    let currentEmailTextfieldView = UIView()
    let currentEmailTextfield = UITextField()
    
    let newEmailTextfieldView = UIView()
    let newEmailTextfield = UITextField()
    
    let passwordTextfieldView = UIView()
    let passwordTextfield = UITextField()
    
    let updateEmailButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Update email"
        
        view.addSubview(currentEmailLabel)
        currentEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        currentEmailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        currentEmailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currentEmailLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        currentEmailLabel.sizeToFit()
        currentEmailLabel.font = .boldSystemFont(ofSize: 15)
        currentEmailLabel.adjustsFontForContentSizeCategory = true
        currentEmailLabel.text = "Current Email: \(getFBUserEmail())"
        
        view.addSubview(instructionTitle)
        instructionTitle.translatesAutoresizingMaskIntoConstraints = false
        instructionTitle.topAnchor.constraint(equalTo: currentEmailLabel.bottomAnchor, constant: 10).isActive = true
        instructionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instructionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        instructionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        instructionTitle.sizeToFit()
        instructionTitle.font = .systemFont(ofSize: 15)
        instructionTitle.numberOfLines = 2
        instructionTitle.text = "Please enter the following to update your email:"
        instructionTitle.tintColor = .lightText
        
        view.addSubview(currentEmailTextfieldView)
        currentEmailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        currentEmailTextfieldView.topAnchor.constraint(equalTo: instructionTitle.bottomAnchor, constant: 10).isActive = true
        currentEmailTextfieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currentEmailTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        currentEmailTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        currentEmailTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        currentEmailTextfieldView.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        currentEmailTextfieldView.addSubview(currentEmailTextfield)
        currentEmailTextfield.translatesAutoresizingMaskIntoConstraints = false
        currentEmailTextfield.topAnchor.constraint(equalTo: currentEmailTextfieldView.topAnchor, constant: 5).isActive = true
        currentEmailTextfield.leftAnchor.constraint(equalTo: currentEmailTextfieldView.leftAnchor, constant: 20).isActive = true
        currentEmailTextfield.rightAnchor.constraint(equalTo: currentEmailTextfieldView.rightAnchor, constant: -20).isActive = true
        currentEmailTextfield.bottomAnchor.constraint(equalTo: currentEmailTextfieldView.bottomAnchor, constant: -5).isActive = true
        currentEmailTextfield.backgroundColor = .white
        currentEmailTextfield.placeholder = "Current email address"
        currentEmailTextfield.keyboardType = .emailAddress
        currentEmailTextfield.autocapitalizationType = .none
        currentEmailTextfield.delegate = self
        
        view.addSubview(newEmailTextfieldView)
        newEmailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        newEmailTextfieldView.topAnchor.constraint(equalTo: currentEmailTextfieldView.bottomAnchor, constant: 10).isActive = true
        newEmailTextfieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newEmailTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        newEmailTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        newEmailTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newEmailTextfieldView.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        newEmailTextfieldView.addSubview(newEmailTextfield)
        newEmailTextfield.translatesAutoresizingMaskIntoConstraints = false
        newEmailTextfield.topAnchor.constraint(equalTo: newEmailTextfieldView.topAnchor, constant: 5).isActive = true
        newEmailTextfield.leftAnchor.constraint(equalTo: newEmailTextfieldView.leftAnchor, constant: 20).isActive = true
        newEmailTextfield.rightAnchor.constraint(equalTo: newEmailTextfieldView.rightAnchor, constant: -20).isActive = true
        newEmailTextfield.bottomAnchor.constraint(equalTo: newEmailTextfieldView.bottomAnchor, constant: -5).isActive = true
        newEmailTextfield.backgroundColor = .white
        newEmailTextfield.placeholder = "New email address"
        newEmailTextfield.keyboardType = .emailAddress
        newEmailTextfield.autocapitalizationType = .none
        newEmailTextfield.delegate = self
        
        view.addSubview(passwordTextfieldView)
        passwordTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfieldView.topAnchor.constraint(equalTo: newEmailTextfieldView.bottomAnchor, constant: 10).isActive = true
        passwordTextfieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        passwordTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextfieldView.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        passwordTextfieldView.addSubview(passwordTextfield)
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.topAnchor.constraint(equalTo: passwordTextfieldView.topAnchor, constant: 5).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: passwordTextfieldView.leftAnchor, constant: 20).isActive = true
        passwordTextfield.rightAnchor.constraint(equalTo: passwordTextfieldView.rightAnchor, constant: -20).isActive = true
        passwordTextfield.bottomAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: -5).isActive = true
        passwordTextfield.backgroundColor = .white
        passwordTextfield.placeholder = "Current password"
        passwordTextfield.keyboardType = .emailAddress
        passwordTextfield.autocapitalizationType = .none
        passwordTextfield.delegate = self
        
        view.addSubview(updateEmailButton)
        updateEmailButton.translatesAutoresizingMaskIntoConstraints = false
        updateEmailButton.topAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: 20).isActive = true
        updateEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateEmailButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        updateEmailButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        updateEmailButton.backgroundColor = .systemYellow
        updateEmailButton.layer.cornerRadius = 15
        updateEmailButton.setTitle("Update", for: .normal)
        updateEmailButton.addTarget(self, action: #selector(updateEmailButtonPressed), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func updateEmailButtonPressed() {
        
        let user = Auth.auth().currentUser
        
        // Prompt the user to re-provide their sign-in credentials
        let credential = EmailAuthProvider.credential(withEmail: currentEmailTextfield.text!, password: passwordTextfield.text!)
        user?.reauthenticate(with: credential) { result, error in
            if result != nil {
                // User re-authenticated.
                print("User re-authenticated")
        
                user?.updateEmail(to: self.newEmailTextfield.text!) { error in
                    if error != nil {
                        print("Error updating FB email. Error: \(String(describing: error))")
                        self.instructionTitle.text = "Error updating email. Please try again."

                    } else {
                        print("FB email updated successfuly")
                        self.updateAccountInfoFB(self.newEmailTextfield.text!.lowercased())
                        self.instructionTitle.text = "Email successfully updated to: \(self.newEmailTextfield.text!.lowercased())"
                        self.currentEmailLabel.text = "Current Email: \(self.getFBUserEmail())"
                        // Reset textfields.
                        self.currentEmailTextfield.text = ""
                        self.newEmailTextfield.text = ""
                        self.passwordTextfield.text = ""
                    }
                }
                
            } else {
                // An error happened.
                self.instructionTitle.text = "Error updating email. Please try again."
                print("Error authenticating user")
            }
        }
        
    }
    

}

extension ChangeEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
}

extension ChangeEmailViewController {
    
    func getFBUserEmail() -> String {
        guard let userEmail = Auth.auth().currentUser?.email else { return "" }
        return userEmail
    }
    
    func updateAccountInfoFB(_ email: String) {
        let db = Firestore.firestore()
        
        // Add collection("users")
        let userUID = Auth.auth().currentUser?.uid
        let newUserFireBase = db.collection("users").document(userUID!)
        
        // set/add document(userName, unique ID/documentID).
        newUserFireBase.updateData ([
            "email": email
            ]) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
            }
    }
    
}
