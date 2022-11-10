//
//  LoginViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/1/22.
//

import UIKit
import FirebaseAuthUI
import FirebaseAuth
import FirebaseEmailAuthUI

class LoginViewController: UIViewController {
    
    let titleLogo = UIImageView()
    let appName = UILabel()
    
    let signUpButton = UIButton()
    let useWithoutAccountButton = UIButton()
    
    let emailTextfieldView = UIView()
    let emailTextfield = UITextField()
    let passwordTextfieldView = UIView()
    let passwordTextfield = UITextField()
    
    let loginButton = UIButton()
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .secondarySystemBackground
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        self.enableDismissKeyboardOnTapOutside()
        
        //Title Logo: UIImageView
        view.addSubview(titleLogo)
        titleLogo.translatesAutoresizingMaskIntoConstraints = false
        titleLogo.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
//        titleLogo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        titleLogo.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        titleLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLogo.heightAnchor.constraint(equalToConstant: 200).isActive = true
        titleLogo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        titleLogo.image = UIImage(named: K.leaf)
        
        // App Name: UILabel
        view.addSubview(appName)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.topAnchor.constraint(equalTo: titleLogo.bottomAnchor, constant: 5).isActive = true
        appName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        appName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        appName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        emailTextfield.placeholder = "Email"
        
        // Password textfieldView: UITextfieldView
        view.addSubview(passwordTextfieldView)
        passwordTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfieldView.topAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: 20).isActive = true
        passwordTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        passwordTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextfieldView.backgroundColor = .white
        passwordTextfieldView.layer.cornerRadius = 5.0
        
      
        passwordTextfieldView.addSubview(passwordTextfield)
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.topAnchor.constraint(equalTo: passwordTextfieldView.topAnchor, constant: 5).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: passwordTextfieldView.leftAnchor, constant: 20).isActive = true
        passwordTextfield.rightAnchor.constraint(equalTo: passwordTextfieldView.rightAnchor, constant: -20).isActive = true
        passwordTextfield.bottomAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: -5).isActive = true
        passwordTextfield.backgroundColor = .white
        passwordTextfield.placeholder = "Password"
        
        
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
        loginButton.backgroundColor = .systemYellow
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        loginButton.layer.cornerRadius = 5.0
        loginButton.addTarget(self, action: #selector(loginButtonClicked(sender:)), for: .touchUpInside)
        
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
    
    @objc func loginButtonClicked(sender: UIButton) {
        // Add segue to MainViewController with Firebase loaded.
        print("Login button clicked")
        
        if Auth.auth().currentUser != nil {
          // User is signed in.
          // ...
            print("\(Auth.auth().currentUser?.uid)")
        } else {
          // No user is signed in.
          // ...
        }
        
//        let authUI = FUIAuth.defaultAuthUI()
//
//        guard authUI != nil else {
//            return
//        }
//
//        authUI?.delegate = self
//        authUI?.providers = [FUIEmailAuth()]
//
//        let authViewController = authUI!.authViewController()
//
//        present(authViewController, animated: true, completion: nil)
        
//        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { authResult, error in
//            print("Error creating user using Firebase. Error: \(error)")
//        }
    }
    
    @objc func useWithoutAccountButtonClicked(sender: UIButton) {
        // Add segue to WaterHabitDaysViewController
        print("Use without login account - button clicked")
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewControllerID")  as! MainViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
        
    }
    
    @objc func signUpButtonClicked(sender: UIButton) {
        // Add segue to SignUpViewController
        print("Sign up an account - button clicked")
        let signUpVC = SignUpViewController()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    
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

extension LoginViewController: FUIAuthDelegate {
    
    // User didSignIn
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        // Handle signIn Error
        if error == nil {
            print("FUI login error: \(String(describing: error))")
            return
        }
        
    }
    
}
