//
//  LoginViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/1/22.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class LoginViewController: UIViewController {
    
    private let titleLogo = UIImageView()
    private let appName = UILabel()

    private let signUpButton = UIButton()
    private let useWithoutAccountButton = UIButton()

    private let emailTextfieldView = UIView()
    private let emailTextfield = UITextField()
    private let passwordTextfieldView = UIView()
    private let passwordTextfield = UITextField()
    private let revealPasswordButton = UIButton()
    private let passwordReveal = true

    private let loginButton = UIButton()
    private let forgotPasswordButton = UIButton()
    
    // MARK: - UserDefaults for saving small data/settings
    private let defaults = UserDefaults.standard
    
    deinit {
        print("LoginVC has been deinitialized")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        view.backgroundColor = .secondarySystemBackground
        
        self.enableDismissKeyboardOnTapOutside()
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentMainVC), name: NSNotification.Name("navigateToMainVC"), object: nil)
        
        //Title Logo: UIImageView
        view.addSubview(titleLogo)
        titleLogo.translatesAutoresizingMaskIntoConstraints = false
        titleLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        titleLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let titleLogoFrameConstant = view.frame.height / 5
        titleLogo.heightAnchor.constraint(equalToConstant: titleLogoFrameConstant).isActive = true
        titleLogo.widthAnchor.constraint(equalToConstant: titleLogoFrameConstant).isActive = true
        titleLogo.image = UIImage(named: K.leaf)
        
        
        // App Name: UILabel
        view.addSubview(appName)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.topAnchor.constraint(equalTo: titleLogo.bottomAnchor, constant: 0).isActive = true
        appName.centerXAnchor.constraint(equalTo: titleLogo.centerXAnchor).isActive = true
        let appNameFrameConstant = view.frame.height / 10
        appName.heightAnchor.constraint(equalToConstant: appNameFrameConstant).isActive = true
        
        appName.text = "PlantApp"
        appName.font = UIFont.boldSystemFont(ofSize: 50)
        appName.textColor = UIColor(named: K.customGreen2)
        appName.textAlignment = .center
        
        // Email textfieldView: UITextfieldView
        view.addSubview(emailTextfieldView)
        emailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextfieldView.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 20).isActive = true
        emailTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        emailTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextfieldView.backgroundColor = .white
        emailTextfieldView.layer.cornerRadius = 5.0
        
      
        emailTextfieldView.addSubview(emailTextfield)
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.topAnchor.constraint(equalTo: emailTextfieldView.topAnchor, constant: 5).isActive = true
        emailTextfield.leftAnchor.constraint(equalTo: emailTextfieldView.leftAnchor, constant: 20).isActive = true
        emailTextfield.rightAnchor.constraint(equalTo: emailTextfieldView.rightAnchor, constant: -20).isActive = true
        emailTextfield.bottomAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: -5).isActive = true
        emailTextfield.backgroundColor = .white
        emailTextfield.placeholder = "Email address"
        emailTextfield.autocapitalizationType = .none
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.delegate = self
        
        // Password textfieldView: UITextfieldView
        view.addSubview(passwordTextfieldView)
        passwordTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfieldView.topAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: 20).isActive = true
        passwordTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        passwordTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextfieldView.backgroundColor = .white
        passwordTextfieldView.layer.cornerRadius = 5.0
        
        // Reveal Password Button: UIButton
        passwordTextfieldView.addSubview(revealPasswordButton)
        revealPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        revealPasswordButton.rightAnchor.constraint(equalTo: passwordTextfieldView.rightAnchor).isActive = true
        revealPasswordButton.centerYAnchor.constraint(equalTo: passwordTextfieldView.centerYAnchor).isActive = true
        revealPasswordButton.heightAnchor.constraint(equalTo: passwordTextfieldView.heightAnchor).isActive = true
        revealPasswordButton.widthAnchor.constraint(equalTo: passwordTextfieldView.heightAnchor).isActive = true
        revealPasswordButton.backgroundColor = .clear
        revealPasswordButton.tintColor = .lightGray
        revealPasswordButton.addTarget(self, action: #selector(revealPasswordButtonClicked(sender:)), for: .touchUpInside)
        
        // Password Textfield: UITextfield
        passwordTextfieldView.addSubview(passwordTextfield)
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.topAnchor.constraint(equalTo: passwordTextfieldView.topAnchor, constant: 5).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: passwordTextfieldView.leftAnchor, constant: 20).isActive = true
        passwordTextfield.rightAnchor.constraint(equalTo: revealPasswordButton.leftAnchor).isActive = true
        passwordTextfield.bottomAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: -5).isActive = true
        passwordTextfield.backgroundColor = .clear
        passwordTextfield.placeholder = "Password"
        passwordTextfield.keyboardType = .default
        passwordTextfield.autocapitalizationType = .none
        passwordTextfield.autocorrectionType = .no
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.delegate = self
        
        // Login Button: UIButton
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: 20).isActive = true
        loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(.placeholderText, for: .highlighted)
        loginButton.backgroundColor = UIColor(named: "customYellow1")
        loginButton.isEnabled = false
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        loginButton.layer.cornerRadius = 5.0
        loginButton.addTarget(self, action: #selector(loginButtonClicked(sender:)), for: .touchUpInside)
        
        // Forgot Password Button: UIButton
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10).isActive = true
        forgotPasswordButton.leftAnchor.constraint(equalTo: loginButton.leftAnchor, constant: 40).isActive = true
        forgotPasswordButton.rightAnchor.constraint(equalTo: loginButton.rightAnchor, constant: -40).isActive = true
        forgotPasswordButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        forgotPasswordButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        forgotPasswordButton.setTitle("Forgot password?", for: .normal)
        forgotPasswordButton.setTitleColor(.brown, for: .normal)
        forgotPasswordButton.setTitleColor(.placeholderText, for: .highlighted)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonClicked(sender:)), for: .touchUpInside)
        
        // useWithoutAccountButton: UIButton
        view.addSubview(useWithoutAccountButton)
        useWithoutAccountButton.translatesAutoresizingMaskIntoConstraints = false
        useWithoutAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        useWithoutAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        useWithoutAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        useWithoutAccountButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        useWithoutAccountButton.setTitle("Use without login account", for: .normal)
        useWithoutAccountButton.setTitleColor(.placeholderText, for: .normal)
        useWithoutAccountButton.setTitleColor(.white, for: .highlighted)
        useWithoutAccountButton.addTarget(self, action: #selector(useWithoutAccountButtonClicked(sender:)), for: .touchUpInside)
        
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.bottomAnchor.constraint(equalTo: useWithoutAccountButton.topAnchor, constant: -20).isActive = true
        signUpButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        signUpButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        signUpButton.setTitle("Sign Up for an account", for: .normal)
        signUpButton.setTitleColor(.systemCyan, for: .normal)
        signUpButton.setTitleColor(.white, for: .highlighted)
        signUpButton.addTarget(self, action: #selector(signUpButtonClicked(sender:)), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.hidesBackButton = true
        
        // If FB User login, this will navigate to MainVC
        if authenticateFBUser() {
            self.defaults.set(true, forKey: "fbUserFirstLoggedIn")
            K.navigateToMainVC(self)
        }
        
        // If user is logging in without a FB account, this will navigate to MainVC
//        if defaults.bool(forKey: "useWithoutFBAccount") {
//            K.navigateToMainVC(self)
//        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // Reset/Clear textfields when leaving login screen
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }

    
    // MARK: - objc functions
    @objc func loginButtonClicked(sender: UIButton) {
        // Add segue to MainViewController with Firebase loaded.
        print("Login button clicked")
        
        // Signing in Firebase
        Auth.auth().signIn(withEmail: (emailTextfield.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)), password: passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            [unowned self] (authResult, error) in
            
            // Check for error signing in
            if error != nil {
                if error?.localizedDescription == K.tempLockMessageFB {
                    print("Sign in error with Firebase: \(error!.localizedDescription)")
                    let alert = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("Sign in error with Firebase: \(error!.localizedDescription)")
                    let alert = UIAlertController(title: "Oops!", message: "You've entered either the wrong email or password. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }

            // If no error signing in, navigate to MainViewController.
            } else {
                if self.authenticateFBUser() {
                    self.defaults.set(true, forKey: "fbUserFirstLoggedIn")
                    K.navigateToMainVC(self)
                }
            }
            
        }
    }
    
    @objc func forgotPasswordButtonClicked(sender: UIButton) {
        print("Forgot password button clicked")
        
        // Present half sheet/modally
        let vc = ForgotPasswordViewController()
        let navVC = UINavigationController(rootViewController: vc)
        if let sheet = navVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(navVC, animated: true)
    }
    
    @objc func signUpButtonClicked(sender: UIButton) {
        // Add segue to SignUpViewController
        print("Sign up an account - button clicked")
        let signUpVC = SignUpViewController()
        self.present(signUpVC, animated: true)
    }
    
    @objc func useWithoutAccountButtonClicked(sender: UIButton) {
        self.defaults.set(true, forKey: "useWithoutFBAccount")
        K.navigateToMainVC(self)
        print("Use without login account - button clicked")
    }
    
    @objc func presentMainVC() {
        if self.authenticateFBUser() {
            self.defaults.set(true, forKey: "fbUserFirstLoggedIn")
            K.navigateToMainVC(self)
        }
    }
    
    @objc func revealPasswordButtonClicked(sender: UIButton) {
        print("dd")
        passwordTextfield.isSecureTextEntry.toggle()
        if passwordTextfield.isSecureTextEntry == false {
            revealPasswordButton.tintColor = .darkGray
        } else {
            revealPasswordButton.tintColor = .lightGray
        }
    }
    
}

// MARK: - Extension: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
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

        if !passwordTextfield.isEditing {
            view.endEditing(true)
        }
        
    }
    
    func validateEntry() {
        
        if emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(named: "customYellow1")
        } else {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .systemYellow
        }
        
        if !passwordTextfield.text!.isEmpty {
            revealPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            revealPasswordButton.setImage(UIImage(systemName: ""), for: .normal)
        }
        
    }
    
}

// MARK: - Extension: Firebase - Firestore
extension LoginViewController {

    // Firestore: Authenticate
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func signOutFBUser() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    


}
