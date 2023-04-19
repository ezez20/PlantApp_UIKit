//
//  SettingsViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 10/10/22.
//

import UIKit
import UserNotifications
import CoreData
import FirebaseAuth
import FirebaseFirestore
import WebKit

class SettingsViewController: UIViewController {
    
    // Container View
    let containerView = UIView()
    
    // MARK: - Notification Settings View
    let section1View = UIView()
    
    // notification Settings Label View
    let notificationSettingsLabel = UILabel()
    
    // Notification Section View
    let notificationLabel = UILabel()
    let notificationBell = UIImageView()
    let notificationToggleSwitch = UISwitch()
    
    // Divider View
    let dividerView = UIView()
    
    // alertTimeButton
    let alertTimeButton = UIButton()
    let alertLogo = UIImageView()
    let alertLabel = UILabel()
    
    
    // MARK: - Terms and Agreement / Privacy Policy View
    let section2View = UIView()
    let aboutLabel = UILabel()
    
    // Notification Section View
    let privacyPolicyLabel = UILabel()
    let privacyImage = UIImageView()
    let privacyPolicyButton = UIButton()
    
    // Divider View
    let divider2View = UIView()
    
    // termsButton
    let termsButton = UIButton()
    let termsLogo = UIImageView()
    let termsLabel = UILabel()
    
    
    // MARK: - logoutButton / accountSettingsButton
    // Login/Logout Button
    let logoutButton = UIButton()
    // Account Settings Button
    let accountSettingsButton = UIButton()
    
    
    
    // UserNotification selected alert option
    var selectedAlertOption = 0
    let options = ["day of event", "1 day before", "2 days before", "3 day before"]
    
    // UserDefaults to hold current settings for app.
    let defaults = UserDefaults.standard
    // userSettings will be loaded in from MainVC(loaded from FB)
    var userSettings = [String: Any]()
    
    // MARK: - Core Data - Persisting data
    var plants: [Plant]!
    var context : NSManagedObjectContext!
    
    // MARK: - UNUserNotificationCenter
    let center = UNUserNotificationCenter.current()
    
    let dispatchGroup = DispatchGroup()
    
    deinit {
        print("SettingsVC has been deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(named: K.customGreen2)
        
        saveUserSettings {
            self.selectedAlertOption = self.defaults.integer(forKey: "selectedAlertOption")
            self.defaults.set(false, forKey: "firstUpdateUserSettings")
        }
        
        // Do any additional setup after loading the view.
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        containerView.backgroundColor = .secondarySystemBackground
        
        containerView.addSubview(section1View)
        section1View.translatesAutoresizingMaskIntoConstraints = false
//        sectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 108).isActive = true
        section1View.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        section1View.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
        containerView.addSubview(notificationSettingsLabel)
        notificationSettingsLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationSettingsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        notificationSettingsLabel.bottomAnchor.constraint(equalTo: section1View.topAnchor, constant: -5).isActive = true
        notificationSettingsLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        notificationSettingsLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        notificationSettingsLabel.text = "NOTIFICATION SETTINGS"
        notificationSettingsLabel.textColor = .gray
        notificationSettingsLabel.adjustsFontForContentSizeCategory = true
        
        section1View.backgroundColor = UIColor(named: "customWhite")
        section1View.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        
        // MARK: - Notification Settings Section
        
        // notification section
        section1View.addSubview(notificationBell)
        notificationBell.translatesAutoresizingMaskIntoConstraints = false
        notificationBell.topAnchor.constraint(equalTo: section1View.topAnchor, constant: 10).isActive = true
        notificationBell.leftAnchor.constraint(equalTo: section1View.leftAnchor, constant: 20).isActive = true
        
        notificationBell.heightAnchor.constraint(equalToConstant: 30).isActive = true
        notificationBell.widthAnchor.constraint(equalToConstant: 30).isActive = true
        notificationBell.image = UIImage(systemName: "bell.fill")
        notificationBell.contentMode = .scaleAspectFit
        notificationBell.tintColor = .systemYellow
        
        section1View.addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.centerYAnchor.constraint(equalTo: notificationBell.centerYAnchor).isActive = true
        notificationLabel.leftAnchor.constraint(equalTo: notificationBell.rightAnchor, constant: 20).isActive = true
        notificationLabel.text = "Notification Mode"
        
        section1View.addSubview(notificationToggleSwitch)
        notificationToggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        notificationToggleSwitch.centerYAnchor.constraint(equalTo: notificationBell.centerYAnchor).isActive = true
        notificationToggleSwitch.rightAnchor.constraint(equalTo: section1View.rightAnchor, constant: -20).isActive = true
        notificationToggleSwitch.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        
        // dividerView
        section1View.addSubview(dividerView)
        dividerView.frame = CGRect(x: 0, y: 0, width: section1View.frame.width, height: 1.0)
        dividerView.layer.borderWidth = 1.0
        dividerView.layer.borderColor = UIColor.placeholderText.cgColor
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constraint(equalTo: notificationBell.bottomAnchor, constant: 10).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: notificationBell.bottomAnchor, constant: 11).isActive = true
        dividerView.leftAnchor.constraint(equalTo: section1View.leftAnchor, constant: 20).isActive = true
        dividerView.rightAnchor.constraint(equalTo: section1View.rightAnchor, constant: 0).isActive = true
        
        // alertTimeButton
        var alertTimeButtonConfig = UIButton.Configuration.plain()
        alertTimeButtonConfig.title = options[selectedAlertOption]
        alertTimeButtonConfig.baseForegroundColor = .placeholderText
        alertTimeButton.configuration = alertTimeButtonConfig
        
        section1View.addSubview(alertTimeButton)
        alertTimeButton.translatesAutoresizingMaskIntoConstraints = false
        alertTimeButton.leftAnchor.constraint(equalTo: section1View.leftAnchor).isActive = true
        alertTimeButton.rightAnchor.constraint(equalTo: section1View.rightAnchor).isActive = true
        alertTimeButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor).isActive = true
        alertTimeButton.heightAnchor.constraint(equalTo: notificationBell.heightAnchor, constant: 20).isActive = true
        alertTimeButton.contentHorizontalAlignment = .trailing
        alertTimeButton.configuration?.image = UIImage(systemName: "chevron.right")
        alertTimeButton.configuration?.imagePlacement = .trailing
        
        alertTimeButton.addTarget(self, action:#selector(alertButtonPressed), for: .touchUpInside)
        
        section1View.addSubview(alertLogo)
        alertLogo.translatesAutoresizingMaskIntoConstraints = false
        alertLogo.topAnchor.constraint(equalTo: alertTimeButton.topAnchor, constant: 10).isActive = true
        alertLogo.leftAnchor.constraint(equalTo: section1View.leftAnchor, constant: 20).isActive = true
        
        alertLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        alertLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        alertLogo.image = UIImage(systemName: "clock.fill")
        alertLogo.contentMode = .scaleAspectFit
        alertLogo.tintColor = .systemRed
        
        section1View.addSubview(alertLabel)
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.centerYAnchor.constraint(equalTo: alertLogo.centerYAnchor).isActive = true
        alertLabel.leftAnchor.constraint(equalTo: alertLogo.rightAnchor, constant: 20).isActive = true
        alertLabel.text = "Alert"
        
        section1View.bottomAnchor.constraint(equalTo: alertTimeButton.bottomAnchor, constant: 0).isActive = true
        
        // MARK: - About section
        containerView.addSubview(aboutLabel)
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.topAnchor.constraint(equalTo: section1View.bottomAnchor, constant: 10).isActive = true
        aboutLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        aboutLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        aboutLabel.text = "ABOUT"
        aboutLabel.textColor = .gray
        aboutLabel.adjustsFontForContentSizeCategory = true
        
        containerView.addSubview(section2View)
        section2View.translatesAutoresizingMaskIntoConstraints = false
        section2View.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 5).isActive = true
        section2View.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        section2View.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        section2View.heightAnchor.constraint(equalToConstant: 100).isActive = true
        section2View.backgroundColor = UIColor(named: "customWhite")
        section2View.layer.cornerRadius = 10
        
        
        var privacyPolicyButtonConfig = UIButton.Configuration.plain()
        privacyPolicyButtonConfig.baseForegroundColor = .placeholderText
        privacyPolicyButton.configuration = privacyPolicyButtonConfig
        
        section2View.addSubview(privacyPolicyButton)
        privacyPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyButton.leftAnchor.constraint(equalTo: section2View.leftAnchor).isActive = true
        privacyPolicyButton.rightAnchor.constraint(equalTo: section2View.rightAnchor).isActive = true
        privacyPolicyButton.topAnchor.constraint(equalTo: section2View.topAnchor).isActive = true
        privacyPolicyButton.heightAnchor.constraint(equalTo: notificationBell.heightAnchor, constant: 20).isActive = true
        privacyPolicyButton.contentHorizontalAlignment = .trailing
        privacyPolicyButton.configuration?.image = UIImage(systemName: "chevron.right")
        privacyPolicyButton.configuration?.imagePlacement = .trailing
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyButtonPressed), for: .touchUpInside)
        
        
        section2View.addSubview(privacyImage)
        privacyImage.translatesAutoresizingMaskIntoConstraints = false
        privacyImage.topAnchor.constraint(equalTo: privacyPolicyButton.topAnchor, constant: 10).isActive = true
        privacyImage.leftAnchor.constraint(equalTo: section2View.leftAnchor, constant: 20).isActive = true
        
        privacyImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        privacyImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        privacyImage.image = UIImage(systemName: "lock.shield")
        privacyImage.contentMode = .scaleAspectFit
        privacyImage.tintColor = .blue
        
        section2View.addSubview(privacyPolicyLabel)
        privacyPolicyLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyLabel.centerYAnchor.constraint(equalTo: privacyImage.centerYAnchor).isActive = true
        privacyPolicyLabel.leftAnchor.constraint(equalTo: privacyImage.rightAnchor, constant: 20).isActive = true
        privacyPolicyLabel.text = "Privacy Policy"
        
        // dividerView
        section2View.addSubview(divider2View)
        divider2View.frame = CGRect(x: 0, y: 0, width: section2View.frame.width, height: 1.0)
        divider2View.layer.borderWidth = 1.0
        divider2View.layer.borderColor = UIColor.placeholderText.cgColor
        divider2View.translatesAutoresizingMaskIntoConstraints = false
        divider2View.topAnchor.constraint(equalTo: privacyPolicyButton.bottomAnchor).isActive = true
        divider2View.leftAnchor.constraint(equalTo: section2View.leftAnchor, constant: 20).isActive = true
        divider2View.rightAnchor.constraint(equalTo: section2View.rightAnchor, constant: 0).isActive = true
        divider2View.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        var termsButtonConfig = UIButton.Configuration.plain()
        termsButtonConfig.baseForegroundColor = .placeholderText
        privacyPolicyButton.configuration = termsButtonConfig
        
        section2View.addSubview(termsButton)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.leftAnchor.constraint(equalTo: section2View.leftAnchor).isActive = true
        termsButton.rightAnchor.constraint(equalTo: section2View.rightAnchor).isActive = true
        termsButton.topAnchor.constraint(equalTo: divider2View.bottomAnchor).isActive = true
        termsButton.heightAnchor.constraint(equalTo: notificationBell.heightAnchor, constant: 20).isActive = true
        termsButton.contentHorizontalAlignment = .trailing
        termsButton.configuration?.image = UIImage(systemName: "chevron.right")
        termsButton.configuration?.imagePlacement = .trailing
        termsButton.addTarget(self, action: #selector(termsButtonPressed), for: .touchUpInside)
        
        
        section2View.addSubview(termsLogo)
        termsLogo.translatesAutoresizingMaskIntoConstraints = false
        termsLogo.topAnchor.constraint(equalTo: termsButton.topAnchor, constant: 10).isActive = true
        termsLogo.leftAnchor.constraint(equalTo: section2View.leftAnchor, constant: 20).isActive = true
        termsLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        termsLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        termsLogo.image = UIImage(systemName: "doc.plaintext")
        termsLogo.contentMode = .scaleAspectFit
        termsLogo.tintColor = .blue
        
        section2View.addSubview(termsLabel)
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.centerYAnchor.constraint(equalTo: termsLogo.centerYAnchor).isActive = true
        termsLabel.leftAnchor.constraint(equalTo: termsLogo.rightAnchor, constant: 20).isActive = true
        termsLabel.text = "Terms and Conditions"
        
        
        containerView.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        logoutButton.setTitle("Logout current account", for: .normal)
        logoutButton.setTitleColor(.systemCyan, for: .normal)
        logoutButton.setTitleColor(.placeholderText, for: .highlighted)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        
        // MARK: - Add "accountSettingsButton" if user logged in with an email account
        authenticateFBUser() { [self] db in
            containerView.addSubview(accountSettingsButton)
            accountSettingsButton.translatesAutoresizingMaskIntoConstraints = false
            accountSettingsButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            accountSettingsButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -10).isActive = true
            accountSettingsButton.setTitle("Account settings", for: .normal)
            accountSettingsButton.setTitleColor(.systemCyan, for: .normal)
            accountSettingsButton.setTitleColor(.placeholderText, for: .highlighted)
            accountSettingsButton.addTarget(self, action: #selector(accountSettingsButtonPressed), for: .touchUpInside)
        }
        
        
        // ADJUST IF NEEDED: determines the constraint for the bottom of "sectionView"
//        section1View.bottomAnchor.constraint(equalTo: alertTimeButton.bottomAnchor, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Settings"
    }
    
    @objc func alertButtonPressed() {
        print("alertButtonPressed")
        // add segue to "alertTime" view controller.
        let alertTimeVC = AlertTimeViewController()
        alertTimeVC.alertOption = selectedAlertOption
        alertTimeVC.delegate = self
        self.navigationController?.pushViewController(alertTimeVC, animated: true)
   
    }

    
}


// MARK: - Local User Notification
extension SettingsViewController {
    
    // Core Data: Save context
    func updatePlant() {
        do {
            try context.save()
        } catch {
            print("Error updating plant. Error: \(error)")
        }
    }
    
    // Authenticate FB user
    func authenticateFBUser(completion: @escaping (Firestore) -> Void) {
        if Auth.auth().currentUser?.uid != nil {
            let db = Firestore.firestore()
            completion(db)
        }
    }
    
    @objc func switchStateDidChange(_ sender: UISwitch!) {
        if sender.isOn == true {
            defaults.set(true, forKey: "notificationOn")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
            updateUserSettings_FB()
            print("UISwitch state is now ON")
        } else {
            resetUserNotification()
            defaults.set(false, forKey: "notificationOn")
            updateUserSettings_FB()
            print("UISwitch state is now Off")
        }
    }
    
    @objc func privacyPolicyButtonPressed(_ sender: UISwitch!)  {
        print("privacyPolicyButtonPressed")
    }
    
    @objc func termsButtonPressed(_ sender: UISwitch!)  {
        print("termsButtonPressed")
    }
    
    @objc func logoutButtonPressed(_ sender: UISwitch!) {
        
        print("LogoutButtonPressed")
        resetUserNotification()
        
        if defaults.bool(forKey: "useWithoutFBAccount") {
            
            if plants.count != 0 {
                for i in 0...plants.endIndex - 1 {
                    dispatchGroup.enter()
                    print("Dispatch group enter - 2")
                    context.delete(plants[i])
                    updatePlant()
                    dispatchGroup.leave()
                    print("Dispatch group enter leave - 2")
                }
            }
            
            print("Trigger dismiss")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutTriggered"), object: nil)
            defaults.set(true, forKey: "loginVCReload")
            defaults.set(false, forKey: "userDiscardedApp")
            defaults.set(false, forKey: "notificationOn")
            defaults.set(0, forKey: "selectedAlertOption")
            defaults.set(false, forKey: "useWithoutFBAccount")
            dismiss(animated: true)
        }
        
        authenticateFBUser() { [self] db in
            
            resetUndeliveredNotifications_FB()
            updateUserSettings_FB()
            
            let firebaseAuth = Auth.auth()
            
            dispatchGroup.enter()
            print("Dispatch group enter - 1")
            do {
                
                try firebaseAuth.signOut()
                
                defaults.set(false, forKey: "fbUserFirstLoggedIn")
                print("Successfully signed out of FB")
                dispatchGroup.leave()
                print("Dispatch group leave - 1")
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                dispatchGroup.leave()
                print("Dispatch group leave - 1")
            }
            
            // Ensures to delete in Core Data before signing out.
            if plants.count != 0 {
                for i in 0...plants.endIndex - 1 {
                    dispatchGroup.enter()
                    print("Dispatch group enter - 2")
                    context.delete(plants[i])
                    updatePlant()
                    dispatchGroup.leave()
                    print("Dispatch group enter leave - 2")
                }
            }
            
            print("Trigger dismiss")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutTriggered"), object: nil)
            defaults.set(true, forKey: "firstUpdateUserSettings")
            defaults.set(true, forKey: "loginVCReload")
            defaults.set(false, forKey: "userDiscardedApp")
            defaults.set(false, forKey: "notificationOn")
            defaults.set(0, forKey: "selectedAlertOption")
            
            dismiss(animated: true)
            
        }
        
    }
    
    @objc func accountSettingsButtonPressed(_ sender: UISwitch!) {
     print("accountSettingsButtonPressed")
        let accountVC = AccountViewController()
        accountVC.context = context
        accountVC.plants = plants
        self.navigationController?.pushViewController(accountVC, animated: true)
    }
    
    
    // If user FB user is logged in, user last settings will be loaded in UserDefaults.
    func saveUserSettings(completion: @escaping () -> Void) {
        
        if Auth.auth().currentUser?.uid != nil {
            
            // When user first logged in, their last settings will be loaded from FB.
            if defaults.bool(forKey: "firstUpdateUserSettings") {
                // Set setting: Notification On
                let notificationOn = userSettings["Notification On"] as? Bool ?? false
                print("notificationOn: \(notificationOn)")
                self.notificationToggleSwitch.isOn = notificationOn
                self.defaults.set(notificationOn, forKey: "notificationOn")
                
                // Set setting: Notification Alert Time
                let notificationAlertTime = userSettings["Notification Alert Time"] as? Int ?? 0
                print("notificationAlertTime: \(notificationAlertTime)")
                self.defaults.set(notificationAlertTime, forKey: "selectedAlertOption")
                completion()
            } else {
                // From last fb log in, any further settings changed will just be stored in UserDefaults.
                notificationToggleSwitch.isOn = defaults.bool(forKey: "notificationOn")
                selectedAlertOption = defaults.integer(forKey: "selectedAlertOption")
            }
            
        } else {
            // If user logged in with useWithoutFBAccount, any settings changed will just be stored in UserDefaults.
            notificationToggleSwitch.isOn = defaults.bool(forKey: "notificationOn")
            selectedAlertOption = defaults.integer(forKey: "selectedAlertOption")
        }
        
    }
    
    // FB: updates last user settings to FB
    func updateUserSettings_FB() {
        
        authenticateFBUser() { [self] db in
            
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            let userFireBase = db.collection("users").document(currentUser)
            
            // FIREBASE: Plant entity input
            let userSettingEditedData: [String: Any] = [
                "Notification On": defaults.bool(forKey: "notificationOn"),
                "Notification Alert Time": defaults.integer(forKey: "selectedAlertOption"),
                "Notification Badge Count": defaults.integer(forKey: "NotificationBadgeCount")
            ]
            
            userFireBase.updateData(userSettingEditedData) { error in
                if error != nil {
                    print("Error updating User Seetings to FB. Error: \(String(describing: error))")
                }
            }
            
            print("User Settings successfully updated to Firebase")
            
        }
        
    }
    
    // Resets: UserNotification/UserDefaults/applicationIconBadgeNumber/notificationPending for plants
    func resetUserNotification() {
        // 1: Resets UserNotification/
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        // 2: Resets UserDefaults to 0 for "NotificationBadgeCount"
        defaults.set(0, forKey: "NotificationBadgeCount")
        
        // Reset applicationIconBadgeNumber to 0
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
      
        // Reset plant's notificationDelivered status, so plants that were scheduled for notification that has not been delievered yet may be re-scheduled once user logs back in next time.
        for p in plants {
            p.notificationPending = false
            updatePlant()
        }
    }
    
    func resetUndeliveredNotifications_FB() {
        let db = Firestore.firestore()
        
        //2: FIREBASE: Get currentUser UID to use as document's ID.
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        let userFireBase = db.collection("users").document(currentUser)
        
        //3: FIREBASE: Declare collection("plants)
        let plantCollection =  userFireBase.collection("plants")
        
        for p in plants {
            guard let plantID = p.id?.uuidString else { return }
            print("plantID: \(plantID)")
            let plantDoc = plantCollection.document(plantID)
            print("plantDoc edited uuid: \(plantID)")
            
            let plantEditedData: [String: Any] = ["notificationPending": false]
            
            // 5: Edited data for "Plant entity input"
            plantDoc.updateData(plantEditedData) { error in
                if error != nil {
                    print("FB Error updating data: \(String(describing: error))")
                }
            }
            
            // 6: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    print("FB Error updating data: \(String(describing: error))")
                }
            }
        }

        print("Plant successfully updated on Firebase")
    }
    
    
}

// MARK: - Passing data delegate pattern: Between - SettingsVC & AletTimeVC
extension SettingsViewController: PassAlertDelegate {
    
    func passAlert(Alert: Int) {
        
        selectedAlertOption = Alert
        defaults.set(selectedAlertOption, forKey: "selectedAlertOption")
        updateUserSettings_FB()
        
        if notificationToggleSwitch.isOn {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
            print("Notification Time switched")
        }
        
    }
    
}
