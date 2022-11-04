//
//  SignUpViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/3/22.
//

import UIKit

class SignUpViewController: UIViewController {
    
    let titleLogo = UIImageView()
    let appName = UILabel()
    
    let userNameTextfieldView = UIView()
    let userNameTextfield = UITextField()
    
    let emailTextfieldView = UIView()
    let emailTextfield = UITextField()
    let passwordTextfieldView = UIView()
    let passwordTextfield = UITextField()
    
    let createAnAccountButton = UIButton()
    

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
        
        view.addSubview(userNameTextfieldView)
        userNameTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        userNameTextfieldView.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 20).isActive = true
        userNameTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        userNameTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        userNameTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        userNameTextfieldView.backgroundColor = .white
        userNameTextfieldView.layer.cornerRadius = 5.0
        
        userNameTextfieldView.addSubview(userNameTextfield)
        userNameTextfield.translatesAutoresizingMaskIntoConstraints = false
        userNameTextfield.topAnchor.constraint(equalTo: userNameTextfieldView.topAnchor, constant: 5).isActive = true
        userNameTextfield.leftAnchor.constraint(equalTo: userNameTextfieldView.leftAnchor, constant: 20).isActive = true
        userNameTextfield.rightAnchor.constraint(equalTo: userNameTextfieldView.rightAnchor, constant: -20).isActive = true
        userNameTextfield.bottomAnchor.constraint(equalTo: userNameTextfieldView.bottomAnchor, constant: -5).isActive = true
        userNameTextfield.backgroundColor = .white
        userNameTextfield.placeholder = "Full Name or Username"
        
        
        // Email textfieldView: UITextfieldView
        view.addSubview(emailTextfieldView)
        emailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextfieldView.topAnchor.constraint(equalTo: userNameTextfieldView.bottomAnchor, constant: 20).isActive = true
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
        
        
        view.addSubview(createAnAccountButton)
        createAnAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAnAccountButton.topAnchor.constraint(equalTo: passwordTextfieldView.bottomAnchor, constant: 20).isActive = true
        createAnAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        createAnAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        createAnAccountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        createAnAccountButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        createAnAccountButton.setTitle("Create an account", for: .normal)
        createAnAccountButton.setTitleColor(.white, for: .normal)
        createAnAccountButton.setTitleColor(.placeholderText, for: .highlighted)
        createAnAccountButton.backgroundColor = .systemGreen
        createAnAccountButton.layer.borderWidth = 1.0
        createAnAccountButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        createAnAccountButton.layer.cornerRadius = 5.0
        createAnAccountButton.addTarget(self, action: #selector(createAnAccountButtonClicked(sender:)), for: .touchUpInside)
        
        
    }
    
    @objc func createAnAccountButtonClicked(sender: UIButton) {
        // Add segue to MainViewController with Firebase loaded.
        print("createAnAccountButton button clicked")
        
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

}

extension SignUpViewController: UITextFieldDelegate {
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
