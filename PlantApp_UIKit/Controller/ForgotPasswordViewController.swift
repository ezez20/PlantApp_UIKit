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
        emailTextfieldView.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        emailTextfieldView.addSubview(emailTextfield)
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.topAnchor.constraint(equalTo: emailTextfieldView.topAnchor, constant: 5).isActive = true
        emailTextfield.leftAnchor.constraint(equalTo: emailTextfieldView.leftAnchor, constant: 20).isActive = true
        emailTextfield.rightAnchor.constraint(equalTo: emailTextfieldView.rightAnchor, constant: -20).isActive = true
        emailTextfield.bottomAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: -5).isActive = true
        emailTextfield.backgroundColor = .white
        emailTextfield.placeholder = "Email address"
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
        Auth.auth().sendPasswordReset(withEmail: emailTextfield.text ?? "") { error in
            if error != nil {
                print("Error sending password reset link. Error: \(String(describing: error))")
                self.instructionTitle.text = "Oops! Looks like you typed your email incorrectly or this email is not in our record."
            } else {
                print("No error")
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
