//
//  SignUpViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/3/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class SignUpViewController: UIViewController {
    
    let titleLogo = UIImageView()
    let appName = UILabel()
    let introPageLabel = UILabel()
    
    let userNameTextfieldView = UIView()
    let userNameTextfield = UITextField()
    
    let emailTextfieldView = UIView()
    let emailTextfield = UITextField()
    let passwordTextfieldView = UIView()
    let passwordTextfield = UITextField()
    
    let createAnAccountButton = UIButton()
    
    deinit {
        print("SignUpVC has been deinitialized")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .secondarySystemBackground
        
        userNameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        self.enableDismissKeyboardOnTapOutside()
        
        //Title Logo: UIImageView
        view.addSubview(titleLogo)
        titleLogo.translatesAutoresizingMaskIntoConstraints = false
        titleLogo.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        titleLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLogo.heightAnchor.constraint(equalToConstant: 70).isActive = true
        titleLogo.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        titleLogo.image = UIImage(named: K.leaf)
        
        // App Name: UILabel
        view.addSubview(appName)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.topAnchor.constraint(equalTo: titleLogo.bottomAnchor, constant: 0).isActive = true
        appName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        appName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        appName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        appName.text = "PlantApp"
        appName.font = UIFont.boldSystemFont(ofSize: 50)
        appName.adjustsFontForContentSizeCategory = true
        appName.adjustsFontSizeToFitWidth = true
        appName.textColor = UIColor(named: K.customGreen2)
        appName.textAlignment = .center
        
        // Intro to Sign Up Page: UILabel
        view.addSubview(introPageLabel)
        introPageLabel.translatesAutoresizingMaskIntoConstraints = false
        introPageLabel.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 0).isActive = true
        introPageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        introPageLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        introPageLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        introPageLabel.text = "Sign up for an account to save your plants in the cloud"
        introPageLabel.font = UIFont.boldSystemFont(ofSize: 50)
        introPageLabel.adjustsFontForContentSizeCategory = true
        introPageLabel.adjustsFontSizeToFitWidth = true
        introPageLabel.textColor = .systemGray
        introPageLabel.textAlignment = .center
        
        view.addSubview(userNameTextfieldView)
        userNameTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        userNameTextfieldView.topAnchor.constraint(equalTo: introPageLabel.bottomAnchor, constant: 10
        ).isActive = true
        userNameTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        userNameTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        userNameTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        userNameTextfieldView.backgroundColor = UIColor(named: "customWhite")
        userNameTextfieldView.layer.cornerRadius = 5.0
        
        userNameTextfieldView.addSubview(userNameTextfield)
        userNameTextfield.translatesAutoresizingMaskIntoConstraints = false
        userNameTextfield.topAnchor.constraint(equalTo: userNameTextfieldView.topAnchor, constant: 5).isActive = true
        userNameTextfield.leftAnchor.constraint(equalTo: userNameTextfieldView.leftAnchor, constant: 20).isActive = true
        userNameTextfield.rightAnchor.constraint(equalTo: userNameTextfieldView.rightAnchor, constant: -20).isActive = true
        userNameTextfield.bottomAnchor.constraint(equalTo: userNameTextfieldView.bottomAnchor, constant: -5).isActive = true
        userNameTextfield.backgroundColor = .clear
        userNameTextfield.placeholder = "Full Name or Username"
        userNameTextfield.autocapitalizationType = .none
        userNameTextfield.autocorrectionType = .no
        userNameTextfield.spellCheckingType = .no
        
        
        // Email textfieldView: UITextfieldView
        view.addSubview(emailTextfieldView)
        emailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextfieldView.topAnchor.constraint(equalTo: userNameTextfieldView.bottomAnchor, constant: 10).isActive = true
        emailTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        emailTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextfieldView.backgroundColor = UIColor(named: "customWhite")
        emailTextfieldView.layer.cornerRadius = 5.0
        
      
        emailTextfieldView.addSubview(emailTextfield)
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.topAnchor.constraint(equalTo: emailTextfieldView.topAnchor, constant: 5).isActive = true
        emailTextfield.leftAnchor.constraint(equalTo: emailTextfieldView.leftAnchor, constant: 20).isActive = true
        emailTextfield.rightAnchor.constraint(equalTo: emailTextfieldView.rightAnchor, constant: -20).isActive = true
        emailTextfield.bottomAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: -5).isActive = true
        emailTextfield.backgroundColor = .clear
        emailTextfield.placeholder = "Email"
        emailTextfield.autocorrectionType = .no
        emailTextfield.autocapitalizationType = .none
        emailTextfield.spellCheckingType = .no
        
        
        
        // Password textfieldView: UITextfieldView
        view.addSubview(passwordTextfieldView)
        passwordTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfieldView.topAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: 10).isActive = true
        passwordTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        passwordTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextfieldView.backgroundColor = UIColor(named: "customWhite")
        passwordTextfieldView.layer.cornerRadius = 5.0
        
      
        passwordTextfieldView.addSubview(passwordTextfield)
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.topAnchor.constraint(equalTo: passwordTextfieldView.topAnchor, constant: 5).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: passwordTextfieldView.leftAnchor, constant: 20).isActive = true
        passwordTextfield.rightAnchor.constraint(equalTo: passwordTextfieldView.rightAnchor, constant: -20).isActive = true
        passwordTextfield.bottomAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: -5).isActive = true
        passwordTextfield.backgroundColor = .clear
        passwordTextfield.placeholder = "Password"
        passwordTextfield.autocapitalizationType = .none
        passwordTextfield.autocorrectionType = .no
        passwordTextfield.spellCheckingType = .no
        
        
        view.addSubview(createAnAccountButton)
        createAnAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAnAccountButton.topAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: 10).isActive = true
        createAnAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        createAnAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        createAnAccountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        createAnAccountButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        createAnAccountButton.setTitle("Create an account", for: .normal)
        createAnAccountButton.backgroundColor = .opaqueSeparator
        createAnAccountButton.layer.borderWidth = 1.0
        createAnAccountButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        createAnAccountButton.layer.cornerRadius = 5.0
        createAnAccountButton.addTarget(self, action: #selector(createAnAccountButtonClicked(sender:)), for: .touchUpInside)
        
        
    }
    
    
    @objc func createAnAccountButtonClicked(sender: UIButton) {
        // Add segue to MainViewController with Firebase loaded.
        print("createAnAccountButton button clicked")
        
        // 1: Create user on Firebase
        Auth.auth().createUser(withEmail: emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (authResult, error) in
            
            // If there is an error
            if error != nil {
                K.presentAlert(self, error!)
            } else {
                
                // Authenticate user signed in.
                if Auth.auth().currentUser?.uid != nil {
                    
                    print("User signed in on Firebase: \(String(describing: Auth.auth().currentUser?.email!))")
                    
                    // 2: FIREBASE: Create a new collection/new document - Create a new user
                    let db = Firestore.firestore()
                    
                    // Add collection("users")
                    let userUID = Auth.auth().currentUser?.uid
                    let newUserFireBase = db.collection("users").document(userUID!)
                    let userEmail = Auth.auth().currentUser?.email
                    
                    // set/add document(userName, unique ID/documentID).
                    newUserFireBase.setData(
                        ["userName": self.userNameTextfield.text!,
                         "userUID": userUID!,
                         "email:": userEmail!,
                         "Notification On": false,
                         "Notification Alert Time": 0,
                         "Notification Badge Count": 0
                        ]) { error in
                            if error != nil {
                                K.presentAlert(self, error!)
                            }
                        }
                    
                    
                    // Once succesfully signed up, SignUpVC will dismiss.
                    self.dismiss(animated: true)
                    // Then, LoginVC will navigate to MainVC.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "navigateToMainVC"), object: nil)
                    
                } else {
                    print("User is not signed in.")
                }
            }
            
            print("Successfully created firebase account user with email: \(String(describing: Auth.auth().currentUser?.email))")
            
        }
        
    }
    
    func validateEntry() {
        if userNameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            createAnAccountButton.isEnabled = false
            createAnAccountButton.backgroundColor = .opaqueSeparator
        } else {
            createAnAccountButton.isEnabled = true
            createAnAccountButton.backgroundColor = UIColor(named: K.customGreen2)
        }
    }

}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // Lowercase email textfield
        emailTextfield.text = emailTextfield.text?.lowercased()
        
        // Validate textfields
        validateEntry()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func enableDismissKeyboardOnTapOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action:    #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}

