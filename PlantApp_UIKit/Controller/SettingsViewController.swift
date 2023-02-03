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

class SettingsViewController: UIViewController {
    
    // Container View
    let containerView = UIView()
    let sectionView = UIView()
    
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
    
    // Login/Logout Button
    let logoutButton = UIButton()
    
    // UserNotification selected alert option
    var selectedAlertOption = 0
    let options = ["day of event", "1 day before", "2 days before", "3 day before"]
    
    // UserDefaults to hold current settings for app.
    let defaults = UserDefaults.standard
    // userSettings will be loaded in from MainVC(loaded from FB)
    var userSettings = [String: Any]()
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - UNUserNotificationCenter
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlants()
        updateUserSettings {
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
        
        containerView.addSubview(sectionView)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 108).isActive = true
        sectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        sectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
        sectionView.backgroundColor = .white
        sectionView.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        // notification section
        sectionView.addSubview(notificationBell)
        notificationBell.translatesAutoresizingMaskIntoConstraints = false
        notificationBell.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 10).isActive = true
        notificationBell.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        
        notificationBell.heightAnchor.constraint(equalToConstant: 30).isActive = true
        notificationBell.widthAnchor.constraint(equalToConstant: 30).isActive = true
        notificationBell.image = UIImage(systemName: "bell.fill")
        notificationBell.contentMode = .scaleAspectFit
        notificationBell.tintColor = .systemYellow
        
        sectionView.addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.centerYAnchor.constraint(equalTo: notificationBell.centerYAnchor).isActive = true
        notificationLabel.leftAnchor.constraint(equalTo: notificationBell.rightAnchor, constant: 20).isActive = true
        notificationLabel.text = "Notification Mode"
        
        sectionView.addSubview(notificationToggleSwitch)
        notificationToggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        notificationToggleSwitch.centerYAnchor.constraint(equalTo: notificationBell.centerYAnchor).isActive = true
        notificationToggleSwitch.rightAnchor.constraint(equalTo: sectionView.rightAnchor, constant: -20).isActive = true
        notificationToggleSwitch.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        
        // dividerView
        sectionView.addSubview(dividerView)
        dividerView.frame = CGRect(x: 0, y: 0, width: sectionView.frame.width, height: 1.0)
        dividerView.layer.borderWidth = 1.0
        dividerView.layer.borderColor = UIColor.placeholderText.cgColor
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constraint(equalTo: notificationBell.bottomAnchor, constant: 10).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: notificationBell.bottomAnchor, constant: 11).isActive = true
        dividerView.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        dividerView.rightAnchor.constraint(equalTo: sectionView.rightAnchor, constant: 0).isActive = true
        
        // alertTimeButton
        var config = UIButton.Configuration.plain()
        config.title = options[selectedAlertOption]
        config.baseForegroundColor = .placeholderText
        alertTimeButton.configuration = config
        
        sectionView.addSubview(alertTimeButton)
        alertTimeButton.translatesAutoresizingMaskIntoConstraints = false
        alertTimeButton.leftAnchor.constraint(equalTo: sectionView.leftAnchor).isActive = true
        alertTimeButton.rightAnchor.constraint(equalTo: sectionView.rightAnchor).isActive = true
        alertTimeButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor).isActive = true
        alertTimeButton.heightAnchor.constraint(equalTo: notificationBell.heightAnchor, constant: 20).isActive = true
        alertTimeButton.contentHorizontalAlignment = .trailing
        alertTimeButton.configuration?.image = UIImage(systemName: "chevron.right")
        alertTimeButton.configuration?.imagePlacement = .trailing
        
        alertTimeButton.addTarget(self, action:#selector(alertButtonPressed), for: .touchUpInside)
        
        sectionView.addSubview(alertLogo)
        alertLogo.translatesAutoresizingMaskIntoConstraints = false
        alertLogo.topAnchor.constraint(equalTo: alertTimeButton.topAnchor, constant: 10).isActive = true
        alertLogo.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        
        alertLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        alertLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        alertLogo.image = UIImage(systemName: "clock.fill")
        alertLogo.contentMode = .scaleAspectFit
        alertLogo.tintColor = .systemRed
        
        sectionView.addSubview(alertLabel)
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.centerYAnchor.constraint(equalTo: alertLogo.centerYAnchor).isActive = true
        alertLabel.leftAnchor.constraint(equalTo: alertLogo.rightAnchor, constant: 20).isActive = true
        alertLabel.text = "Alert"
        
        containerView.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        logoutButton.setTitle("Logout current account", for: .normal)
        logoutButton.setTitleColor(.systemCyan, for: .normal)
        logoutButton.setTitleColor(.placeholderText, for: .highlighted)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        
        
        // ADJUST IF NEEDED: determines the constraint for the bottom of "sectionView"
        sectionView.bottomAnchor.constraint(equalTo: alertTimeButton.bottomAnchor, constant: 0).isActive = true
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

extension SettingsViewController {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
}


// MARK: - Local User Notification
extension SettingsViewController: UNUserNotificationCenterDelegate {
    
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
    
    @objc func logoutButtonPressed(_ sender: UISwitch!) {
        print("LogoutButtonPressed")
        
        if defaults.bool(forKey: "useWithoutFBAccount") {
            if plants.count != 0 {
                for i in 0...plants.endIndex - 1 {
                    context.delete(plants[i])
                    updatePlant()
                }
            }
            self.defaults.set(false, forKey: "useWithoutFBAccount")
        }
        
        
        if authenticateFBUser() {
            
            updateUserSettings_FB()
            resetUserNotification()
            
            let firebaseAuth = Auth.auth()
            
            do {
                
                try firebaseAuth.signOut()
                
                // Ensures to delete in Core Data before signing out.
                if plants.count != 0 {
                    for i in 0...plants.endIndex - 1 {
                        context.delete(plants[i])
                        updatePlant()
                    }
                }
                
                defaults.set(false, forKey: "fbUserFirstLoggedIn")
                print("Successfully signed out of FB")
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            
        }
        

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutTriggered"), object: nil)
        defaults.set(true, forKey: "firstUpdateUserSettings")
        defaults.set(true, forKey: "loginVCReload")
        defaults.set(false, forKey: "userDiscardedApp")
        
        dismiss(animated: true)
        
    }
    
    func loadPlants() {

        do {
            let request = Plant.fetchRequest() as NSFetchRequest<Plant>
            let sort = NSSortDescriptor(key: "order", ascending: true)
            request.sortDescriptors = [sort]
            plants = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }

        print("Plants loaded")
    }

    func updatePlant() {
        do {
            try context.save()
        } catch {
            print("Error updating plant. Error: \(error)")
        }
    }
    
    func setupLocalUserNotification(selectedAlert: Int) {
        
        center.getNotificationSettings { [self] settings in
            
            // If user authorized/allowed user notification in the beginning of app.
            if settings.authorizationStatus == .authorized {
                
                loadPlants()
                
                let center = UNUserNotificationCenter.current()
                
                // For each/every plant, this will create a notification
                for plant in plants {
                    
                    if plant.notificationPending == false {
                        
                        // 2: Create the notification content
                        let content = UNMutableNotificationContent()
                        content.title = "Notification alert!"
                        content.body = "Make sure to water your plant: \(plant.plant!)"
                        
                        //Retreive the value from User Defaults and increase it by 1
                        let badgeCount = defaults.value(forKey: "NotificationBadgeCount") as! Int + 1
                        //Save the new value to User Defaults
                        defaults.set(badgeCount, forKey: "NotificationBadgeCount")
                        //Set the value as the current badge count
                        content.badge = badgeCount as NSNumber
                        content.sound = .default
                        content.categoryIdentifier = "categoryIdentifier"
                        
                        // 3: Create the notification trigger
                        // "5 seconds" added
                        var nextWaterDate: Date {
                            let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: Int(plant.waterHabit), to:  plant.lastWateredDate!)
                            return calculatedDate!
                        }
                        
                        var selectedNotificationTime = Date()
                        switch defaults.integer(forKey: "selectedAlertOption") {
                        case 0: // day of event
                            // For debug purpose: Notification time - 10 seconds
                            selectedNotificationTime = Date.now.advanced(by: 10)
                            
                            // Uncomment below when not debugging:
                            //                        selectedNotificationTime = nextWaterDate.advanced(by: 20)
                            print("selectedNotificationTime: \(selectedNotificationTime)")
                        case 1: // 1 day before
                            selectedNotificationTime = nextWaterDate.advanced(by: -86400)
                            print("Notification Time: \(selectedNotificationTime)")
                        case 2: // 2 days before
                            selectedNotificationTime = nextWaterDate.advanced(by: -86400*2)
                            print("Notification Time: \(selectedNotificationTime)")
                        default: // 3 days before
                            selectedNotificationTime = nextWaterDate.advanced(by: -86400*3)
                            print("Notification Time: \(selectedNotificationTime)")
                        }
                        
                        
                        let notificationDate = selectedNotificationTime
                        let notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
                        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)
                        
                        // 4: Create the request
                        let uuidString = UUID()
                        plant.notificationRequestID = uuidString.uuidString
                        
                        print("notificationActionID: \(uuidString)")
                        let notificationRequest = UNNotificationRequest(identifier: uuidString.uuidString, content: content, trigger: notificationTrigger)
                        
                        // 5: Register the request
                        center.add(notificationRequest) { (error) in
                            // check the error parameter or handle any errors
                            guard error == nil else {
                                print("NotificationRequest error: \(error.debugDescription)")
                                return
                            }
                            print("notificationRequest: \(notificationRequest.identifier)")
                        }
                        
                        updatePlant()
                        
                    }
                }
                
                // 6: Set UNNotificationActions
                let plantNotificationWateredAction = UNNotificationAction(identifier: "plantNotificationWateredActionID", title: "Watered", options: [])
                let plantNotificationCancelAction = UNNotificationAction(identifier: "plantNotificationCancelActionID", title: "Not yet" , options: [])
                let notificationActionsCategory = UNNotificationCategory(identifier: "categoryIdentifier", actions: [plantNotificationWateredAction, plantNotificationCancelAction], intentIdentifiers: [], options: [])
                center.setNotificationCategories([notificationActionsCategory])
                
             
            // Else, if user has yet to allow user notification in the beginning of app, this will request user to choose.
            } else if settings.authorizationStatus == .notDetermined {

                center.delegate = self
                center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    if granted {
                        // Access granted
                        print("UserNotifcation Granted")
                    } else {
                        // Access denied
                        print("UserNotifcation Denied")
                    }
                }
             
            // Else, if user selected "don't allow" in the beginning of the first download of the app and wants to later use User Notification, they will be presented with an alert popup that will lead them to user settings to grant access.
            } else {
                
                let alert = UIAlertController(title: "Error:", message: "Please enable push notification in settings to continue", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Go to Settings", style: .default) { (action) -> Void in
                    print("Go to Settings")
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    print("Cancel")
                }
                alert.addAction(ok)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    activeVC()?.present(alert, animated: true)
                }
              
            }
            
        }
        
        // This function will allow a UIALERTVIEWCONTROLLER to be presented on top of other stacked views.
        // Currently used in "func setupLocalUserNotification()"
        // Source Code: https://stackoverflow.com/questions/40991450/present-uialertcontroller-on-top-of-everything-regardless-of-the-view-hierarchy
        func activeVC() -> UIViewController? {
            // Use connectedScenes to find the .foregroundActive rootViewController
            var rootVC: UIViewController?
            for scene in UIApplication.shared.connectedScenes {
                if scene.activationState == .foregroundActive {
                    rootVC = (scene.delegate as? UIWindowSceneDelegate)?.window!!.rootViewController
                    break
                }
            }
            // Then, find the topmost presentedVC from it.
            var presentedVC = rootVC
            while presentedVC?.presentedViewController != nil {
                presentedVC = presentedVC?.presentedViewController
            }
            return presentedVC
        }
        
    }
    
    func refreshUserNotification() {
        center.removeAllDeliveredNotifications()
        
        setupLocalUserNotification(selectedAlert: defaults.integer(forKey: "selectedAlertOption"))
    }
    
    func resetUserNotification() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        defaults.set(0, forKey: "NotificationBadgeCount")
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Reset plant's notificationDelivered status, so plants that were scheduled for notification that has not been delievered yet may be re-scheduled once user logs back in next time.
        
        for p in plants {
            p.notificationPending = false
            updatePlant()
        }
        
        resetUndeliveredNotifications_FB()
        
    }
    
    
    // If user FB user is logged in, user last settings will be loaded in UserDefaults.
    func updateUserSettings(completion: @escaping () -> Void) {
        
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
            // If no FB logged in, any settings changed will just be stored in UserDefaults.
            notificationToggleSwitch.isOn = defaults.bool(forKey: "notificationOn")
            selectedAlertOption = defaults.integer(forKey: "selectedAlertOption")
        }
        
    }
    
    
    func updateUserSettings_FB() {
        
        let db = Firestore.firestore()
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
                    K.presentAlert(self, error!)
                }
            }
            
            // 6: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
            }
        }

        print("Plant successfully updated on Firebase")
    }
    
}

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
