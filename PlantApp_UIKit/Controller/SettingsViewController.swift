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
    
    let containerView = UIView()
    let sectionView = UIView()
    
    // notification section
    let notificationLabel = UILabel()
    let notificationBell = UIImageView()
    let notificationToggleSwitch = UISwitch()
    
    //divider
    let dividerView = UIView()
    
    // alertTimeButton
    let alertTimeButton = UIButton()
    let alertLogo = UIImageView()
    let alertLabel = UILabel()
    
    // Login/Logout Button
    let logoutButton = UIButton()
    
    let center = UNUserNotificationCenter.current()
    var selectedAlertOption = 0
    let options = ["day of event", "1 day before", "2 days before", "3 day before"]
    // Need to assign from Core Data: plant's water date
    let defaults = UserDefaults.standard
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Settings"
        
        loadPlants()
        notificationToggleSwitch.isOn = defaults.bool(forKey: "notificationOn")
        
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
        
        //        sectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -200).isActive = true
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
    
    @objc func alertButtonPressed() {
        print("alertButtonPressed")
        // add segue to "alertTime" view controller.
        let alertTimeVC = AlertTimeViewController()
        alertTimeVC.alertOption = selectedAlertOption
        alertTimeVC.delegate = self
        self.navigationController?.pushViewController(alertTimeVC, animated: true)
        //        present(alertTimeVC, animated: true)
    }

    
}


// MARK: - Local User Notification
extension SettingsViewController: UNUserNotificationCenterDelegate {
    
    @objc func switchStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            center.removeAllPendingNotificationRequests()
            setupLocalUserNotification(selectedAlert: selectedAlertOption)
            defaults.set(true, forKey: "notificationOn")
            print("UISwitch state is now ON")
        } else {
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
            defaults.set(false, forKey: "notificationOn")
            defaults.set(0, forKey: "NotificationBadgeCount")
            UIApplication.shared.applicationIconBadgeNumber = 0
            print("UISwitch state is now Off")
        }
    }
    
    @objc func logoutButtonPressed(_ sender:UISwitch!) {
        print("LogoutButtonPressed")
        
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
            
            defaults.set(false, forKey: "userFirstLoggedIn")
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutTriggered"), object: nil)
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
    
        loadPlants()
        
        let center = UNUserNotificationCenter.current()
        
        // For each/every plant, this will create a notification
        for plant in plants {
        
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
            
            switch selectedAlertOption {
            case 0: // day of event
                // For debug purpose: Notification time - 10 seconds
                selectedNotificationTime = Date.now.advanced(by: 10)
                
//                selectedNotificationTime = nextWaterDate.advanced(by: 20)
                print("selectedNotificationTime: \(selectedNotificationTime)")
                print("current time: \(Date.now)")
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
            plant.notificationRequestID = uuidString
            print("notificationActionID: \(uuidString)")
            let notificationRequest = UNNotificationRequest(identifier: uuidString.uuidString, content: content, trigger: notificationTrigger)
            
            // 5: Register the request
            center.add(notificationRequest) { (error) in
                // check the error parameter or handle any errors
                guard error == nil else {
                    print("NotificationRequest error: \(error.debugDescription)")
                    return
                }
            }
            
            updatePlant()
            
        }
      
    }
    
}

extension SettingsViewController: PassAlertDelegate {
    
    func passAlert(Alert: Int) {
        selectedAlertOption = Alert
        if notificationToggleSwitch.isOn {
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
            setupLocalUserNotification(selectedAlert: selectedAlertOption)
            print("Notification Time switched")
        }
    }
    
}
