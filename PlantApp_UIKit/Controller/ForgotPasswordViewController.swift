//
//  ForgotPasswordViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 2/9/23.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    let instructionTitle = UILabel()
    let emailTextfieldView = UIView()
    let emailTextfield = UITextField()
    
    let sendLinkButton = UIButton()
    
    deinit {
        print("ForgotPasswordVC has been deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissButtonPressed))
        title = "Forgot password?"
        
        view.addSubview(instructionTitle)
        instructionTitle.translatesAutoresizingMaskIntoConstraints = false
        instructionTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        instructionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instructionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        instructionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        instructionTitle.sizeToFit()
        instructionTitle.numberOfLines = 2
        instructionTitle.text = "Please enter the email address you’d like your password reset sent to:"
        instructionTitle.tintColor = .lightText
        
        view.addSubview(emailTextfieldView)
        emailTextfieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextfieldView.topAnchor.constraint(equalTo: instructionTitle.bottomAnchor, constant: 10).isActive = true
        emailTextfieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextfieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailTextfieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        emailTextfieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextfieldView.backgroundColor = UIColor(named: "customWhite")
        // Do any additional setup after loading the view.
        
        emailTextfieldView.addSubview(emailTextfield)
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.topAnchor.constraint(equalTo: emailTextfieldView.topAnchor, constant: 5).isActive = true
        emailTextfield.leftAnchor.constraint(equalTo: emailTextfieldView.leftAnchor, constant: 20).isActive = true
        emailTextfield.rightAnchor.constraint(equalTo: emailTextfieldView.rightAnchor, constant: -20).isActive = true
        emailTextfield.bottomAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: -5).isActive = true
        emailTextfield.backgroundColor = .clear
        emailTextfield.placeholder = "Email address"
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.autocorrectionType = .no
        emailTextfield.autocapitalizationType = .none
        emailTextfield.delegate = self
        
        view.addSubview(sendLinkButton)
        sendLinkButton.translatesAutoresizingMaskIntoConstraints = false
        sendLinkButton.topAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: 20).isActive = true
        sendLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendLinkButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        sendLinkButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendLinkButton.backgroundColor = .systemYellow
        sendLinkButton.layer.cornerRadius = 15
        sendLinkButton.setTitle("Send link", for: .normal)
        sendLinkButton.addTarget(self, action: #selector(sendLinkButtonPressed), for: .touchUpInside)
        

    }
    

    @objc func dismissButtonPressed() {
        print("Dismiss button clicked")
        dismiss(animated: true)
    }
    
    @objc func sendLinkButtonPressed() {
        
        print("Email: \(emailTextfield.text ?? "")")
        Auth.auth().useAppLanguage()
     
        if let userEmail = emailTextfield.text {
            let actionCodeSettings =  ActionCodeSettings.init()
            actionCodeSettings.handleCodeInApp = false
            actionCodeSettings.url = URL(string: "https://wyyeohplntapp.page.link/")
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.dynamicLinkDomain = "wyyeohplntapp.page.link"
            
            Auth.auth().sendPasswordReset(withEmail: userEmail, actionCodeSettings: actionCodeSettings) { [weak self] error in
                if error != nil {
                    print("Error sending password reset link. Error: \(String(describing: error))")
                    self?.instructionTitle.text = "Oops! Looks like you typed your email incorrectly or this email is not in our record."
                } else {
                    print("Password reset link successfully sent")
                    self?.instructionTitle.text = "A password reset link has been sent to your email!"
                    self?.sendLinkButton.setTitle("", for: .disabled)
                    self?.sendLinkButton.isEnabled = false
                    self?.emailTextfield.text = ""
                    if let checkMarkImage = UIImage(systemName: "checkmark") {
                        self?.sendLinkButton.setImage(checkMarkImage, for: .disabled)
                        self?.sendLinkButton.tintColor = .white
                    }
                    
                    self?.view.endEditing(true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.dismiss(animated: true)
                    }
                }
            }
        }
        
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
}
