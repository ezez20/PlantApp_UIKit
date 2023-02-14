//
//  ChangeEmailViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 2/14/23.
//

import UIKit
import FirebaseAuth

class ChangeEmailViewController: UIViewController {
    
    let instructionTitle = UILabel()
    let currentEmailLabel = UILabel()
    let emailTextfieldView = UIView()
    let emailTextfield = UITextField()
    
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
        currentEmailLabel.text = "Current Email:"
        
        view.addSubview(instructionTitle)
        instructionTitle.translatesAutoresizingMaskIntoConstraints = false
        instructionTitle.topAnchor.constraint(equalTo: currentEmailLabel.bottomAnchor, constant: 10).isActive = true
        instructionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instructionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        instructionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        instructionTitle.sizeToFit()
        instructionTitle.font = .systemFont(ofSize: 15)
        instructionTitle.numberOfLines = 2
        instructionTitle.text = "Please enter the new email address you’d like you change to:"
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
        
        view.addSubview(updateEmailButton)
        updateEmailButton.translatesAutoresizingMaskIntoConstraints = false
        updateEmailButton.topAnchor.constraint(equalTo: emailTextfieldView.bottomAnchor, constant: 20).isActive = true
        updateEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateEmailButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        updateEmailButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        updateEmailButton.backgroundColor = .systemYellow
        updateEmailButton.layer.cornerRadius = 15
        updateEmailButton.setTitle("Save", for: .normal)
        updateEmailButton.addTarget(self, action: #selector(updateEmailButtonPressed), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func updateEmailButtonPressed() {
        print("Email: \(emailTextfield.text ?? "")")
        
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

extension ChangeEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
}
