//
//  AccountViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 2/13/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class AccountViewController: UIViewController {
    
    // Container View
    let containerView = UIView()
    let sectionView = UIView()
    
    // changeEmailButton
    let changeEmailButton = UIButton()
    // emailLogo
    let emailLogo = UIImageView()
    // emailLabel
    let emailLabel = UILabel()
    // Divider View
    let dividerView1 = UIView()
    
    // changeEmailButton
    let changePasswordButton = UIButton()
    // emailLogo
    let passwordLogo = UIImageView()
    // emailLabel
    let passwordLabel = UILabel()
    // Divider View
    let dividerView2 = UIView()
    
    // deleteAccountButton
    let deleteAccountButton = UIButton()
    // deleteAccountLogo
    let deleteAccountLogo = UIImageView()
    // deleteAccountLabel
    let deleteAccountLabel = UILabel()
    
//    var AccountVCUpdateFilloutDelegate: AccountVCUpdateFilloutDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account"

        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        containerView.backgroundColor = .secondarySystemBackground
        
        containerView.addSubview(sectionView)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 108).isActive = true
        sectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        sectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        sectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        sectionView.backgroundColor = .white
        sectionView.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        
        // changeEmailButton
        var changeEmailButtonConfig = UIButton.Configuration.plain()
        changeEmailButtonConfig.title = "Update"
        changeEmailButtonConfig.baseForegroundColor = .placeholderText
        changeEmailButton.configuration = changeEmailButtonConfig
       
        sectionView.addSubview(changeEmailButton)
        changeEmailButton.translatesAutoresizingMaskIntoConstraints = false
        changeEmailButton.leftAnchor.constraint(equalTo: sectionView.leftAnchor).isActive = true
        changeEmailButton.rightAnchor.constraint(equalTo: sectionView.rightAnchor).isActive = true
        changeEmailButton.topAnchor.constraint(equalTo: sectionView.topAnchor).isActive = true
        changeEmailButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        changeEmailButton.contentHorizontalAlignment = .trailing
        changeEmailButton.configuration?.image = UIImage(systemName: "chevron.right")
        changeEmailButton.configuration?.imagePlacement = .trailing
        changeEmailButton.addTarget(self, action:#selector(changeEmailButtonPressed), for: .touchUpInside)
     
        
        // Email logo
        sectionView.addSubview(emailLogo)
        emailLogo.translatesAutoresizingMaskIntoConstraints = false
        emailLogo.topAnchor.constraint(equalTo: changeEmailButton.topAnchor, constant: 10).isActive = true
        emailLogo.leftAnchor.constraint(equalTo: changeEmailButton.leftAnchor, constant: 20).isActive = true
        emailLogo.bottomAnchor.constraint(equalTo: changeEmailButton.bottomAnchor, constant: -10).isActive = true
        emailLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        emailLogo.image = UIImage(systemName: "envelope.fill")
        emailLogo.contentMode = .scaleAspectFit
        emailLogo.tintColor = .systemBlue
        // Email Label
        sectionView.addSubview(emailLabel)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.centerYAnchor.constraint(equalTo: emailLogo.centerYAnchor).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: emailLogo.rightAnchor, constant: 20).isActive = true
        emailLabel.text = "Email"
        
        // dividerView1
        sectionView.addSubview(dividerView1)
        dividerView1.frame = CGRect(x: 0, y: 0, width: sectionView.frame.width, height: 1.0)
        dividerView1.layer.borderWidth = 1.0
        dividerView1.layer.borderColor = UIColor.placeholderText.cgColor
        dividerView1.translatesAutoresizingMaskIntoConstraints = false
        dividerView1.topAnchor.constraint(equalTo: changeEmailButton.bottomAnchor, constant: 0).isActive = true
        dividerView1.bottomAnchor.constraint(equalTo: changeEmailButton.bottomAnchor, constant: 1).isActive = true
        dividerView1.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        dividerView1.rightAnchor.constraint(equalTo: sectionView.rightAnchor, constant: 0).isActive = true
        
        // changePasswordButton
        var changePasswordButtonConfig = UIButton.Configuration.plain()
        changePasswordButtonConfig.title = "Change"
        changePasswordButtonConfig.baseForegroundColor = .placeholderText
        changePasswordButton.configuration = changePasswordButtonConfig
        
        view.addSubview(changePasswordButton)
        changePasswordButton.translatesAutoresizingMaskIntoConstraints = false
        changePasswordButton.leftAnchor.constraint(equalTo: sectionView.leftAnchor).isActive = true
        changePasswordButton.rightAnchor.constraint(equalTo: sectionView.rightAnchor).isActive = true
        changePasswordButton.topAnchor.constraint(equalTo: dividerView1.bottomAnchor).isActive = true
        changePasswordButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        changePasswordButton.contentHorizontalAlignment = .trailing
        changePasswordButton.configuration?.image = UIImage(systemName: "chevron.right")
        changePasswordButton.configuration?.imagePlacement = .trailing
        changePasswordButton.addTarget(self, action:#selector(changePasswordButtonPressed), for: .touchUpInside)
        
        // Password logo
        sectionView.addSubview(passwordLogo)
        passwordLogo.translatesAutoresizingMaskIntoConstraints = false
        passwordLogo.topAnchor.constraint(equalTo: changePasswordButton.topAnchor, constant: 10).isActive = true
        passwordLogo.leftAnchor.constraint(equalTo: changePasswordButton.leftAnchor, constant: 20).isActive = true
        passwordLogo.bottomAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: -10).isActive = true
        passwordLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        passwordLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        passwordLogo.image = UIImage(systemName: "key.fill")
        passwordLogo.contentMode = .scaleAspectFit
        passwordLogo.tintColor = .systemYellow
        // Email Label
        sectionView.addSubview(passwordLabel)
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.centerYAnchor.constraint(equalTo: passwordLogo.centerYAnchor).isActive = true
        passwordLabel.leftAnchor.constraint(equalTo: passwordLogo.rightAnchor, constant: 20).isActive = true
        passwordLabel.text = "Password"
        
        // dividerView2
        sectionView.addSubview(dividerView2)
        dividerView2.frame = CGRect(x: 0, y: 0, width: sectionView.frame.width, height: 1.0)
        dividerView2.layer.borderWidth = 1.0
        dividerView2.layer.borderColor = UIColor.placeholderText.cgColor
        dividerView2.translatesAutoresizingMaskIntoConstraints = false
        dividerView2.topAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 0).isActive = true
        dividerView2.bottomAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 1).isActive = true
        dividerView2.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        dividerView2.rightAnchor.constraint(equalTo: sectionView.rightAnchor, constant: 0).isActive = true
        
        // deleteAccountButton
        sectionView.addSubview(deleteAccountButton)
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.leftAnchor.constraint(equalTo: sectionView.leftAnchor).isActive = true
        deleteAccountButton.rightAnchor.constraint(equalTo: sectionView.rightAnchor).isActive = true
        deleteAccountButton.topAnchor.constraint(equalTo: dividerView2.bottomAnchor).isActive = true
        deleteAccountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deleteAccountButton.contentHorizontalAlignment = .trailing
        deleteAccountButton.addTarget(self, action:#selector(deleteAccountButtonPressed), for: .touchUpInside)
        
        // deleteAccountLogo
        sectionView.addSubview(deleteAccountLogo)
        deleteAccountLogo.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountLogo.topAnchor.constraint(equalTo: deleteAccountButton.topAnchor, constant: 10).isActive = true
        deleteAccountLogo.leftAnchor.constraint(equalTo: deleteAccountButton.leftAnchor, constant: 20).isActive = true
        deleteAccountLogo.bottomAnchor.constraint(equalTo: deleteAccountButton.bottomAnchor, constant: -10).isActive = true
        deleteAccountLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        deleteAccountLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        deleteAccountLogo.image = UIImage(systemName: "hand.wave")
        deleteAccountLogo.contentMode = .scaleAspectFit
        deleteAccountLogo.tintColor = .systemGray
        
        // deleteAccountLabel
        sectionView.addSubview(deleteAccountLabel)
        deleteAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountLabel.centerYAnchor.constraint(equalTo: deleteAccountLogo.centerYAnchor).isActive = true
        deleteAccountLabel.leftAnchor.constraint(equalTo: deleteAccountLogo.rightAnchor, constant: 20).isActive = true
        deleteAccountLabel.text = "Delete account"
        deleteAccountLabel.textColor = .systemRed
        
        // ADJUST IF NEEDED: determines the constraint for the bottom of "sectionView"
        sectionView.heightAnchor.constraint(equalToConstant: 50 * 3).isActive = true
    }
    
    @objc func changeEmailButtonPressed() {
        print("changeEmailButtonPressed")
        let vc = ChangeEmailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func changePasswordButtonPressed() {
        print("changePasswordButtonPressed")
        let vc = AccountFilloutViewController(vcTitle: "Change Password", label1Text: getFBUserEmail(), instructionTitleText: "Please enter the following to update your password:", textfield1PlaceholderText: "Current Email", textfield2PlaceholderText: "Current Password", textfield3PlaceholderText: "New Password", button1TitleText: "Update")
        vc.delegate = self
//        AccountVCUpdateFilloutDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func deleteAccountButtonPressed() {
        print("deleteAccountButtonPressed")
    }


}

extension AccountViewController: AccountFilloutVCButtonDelegate {
    
    func buttonPressed(textfield1Text: String?, textfield2Text: String?, textfield3Text: String?) {
        print("AccountFilloutVCButton pressed")
        
        updateFBPassword(currentEmail: textfield1Text!, currentPassword: textfield2Text!, newPassword: textfield3Text!) { message in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAccountFilloutViewController"), object: nil, userInfo: ["message" : message])
            
            //            self.AccountVCUpdateFilloutDelegate?.updateAccountFilloutVC(data: message)
        }
        
        
        
    }
    
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
    
    func updateFBPassword(currentEmail: String, currentPassword: String, newPassword: String, completion: @escaping (String) -> ()) {
        
        let user = Auth.auth().currentUser
        //        var returnedMessage: String
        // Prompt the user to re-provide their sign-in credentials
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)
        user?.reauthenticate(with: credential) { result, error in
            
            if result != nil {
                // User re-authenticated.
                print("User re-authenticated")
                
                user?.updatePassword(to: newPassword) { error in
                    if error != nil {
                        print("Error updating FB password. Error: \(String(describing: error))")
                        let message = "Error updating email. Please try again. ):"
                        completion(message)
                    } else {
                        let message = "Your password has updated successfuly!"
                        completion(message)
                    }
                }
                
            } else {
                // An error happened.
                print(error)
                if let nsError = error as? NSError {
                    
                    switch AuthErrorCode(_nsError: nsError).code {
                    case AuthErrorCode.wrongPassword:
                        let message = "Wrong password"
                        print(message)
                        completion(message)
                    case AuthErrorCode.invalidEmail:
                        let message = "Invalid Email"
                        print(message)
                        completion(message)
                    case AuthErrorCode.accountExistsWithDifferentCredential:
                        let message = "Account exists with different credential"
                        print(message)
                        completion(message)
                    default:
                        print("unknown error: \(nsError.localizedDescription)")
                        
                    }

                }
            }
            
        }

    }
    
}

//protocol AccountVCUpdateFilloutDelegate {
//    func updateAccountFilloutVC(data: String)
//}
