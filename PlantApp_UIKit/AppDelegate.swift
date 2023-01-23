//
//  AppDelegate.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/19/22.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseAnalytics


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var plants = [Plant]()
    let defaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set UNUserNotificationCenter delegate
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        

        return true
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PlantApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        print("Context saved")
    }
    
    
    func loadPlants() {
        let context = persistentContainer.viewContext
        
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
    
    
}

extension AppDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        UIApplication.shared.applicationIconBadgeNumber = 0
     
        loadPlants()
        
        for plant in plants {
            
            if response.notification.request.identifier == plant.notificationRequestID {
                
                if response.notification.request.content.categoryIdentifier == "categoryIdentifier" {
                    
                    switch response.actionIdentifier {
                        
                    case UNNotificationDefaultActionIdentifier:
                        print(response.actionIdentifier)
                        print("Default clicked.")
                    case "plantNotificationWateredActionID":
                        print(response.actionIdentifier)
                        print("Watered clicked")
                        
                        print("Notification request ID: \(response.notification.request.identifier)")
                        print("Plant Notification Request ID: \(plant.notificationRequestID!)")
                        
                        plant.lastWateredDate = Date.now
                        plant.wateredBool = true
                        plant.notificationDelivered = false
                        print("Updated to: \(plant.lastWateredDate!)")
                        editPlant_FB(plant.id!)
                        center.removeDeliveredNotifications(withIdentifiers: [plant.notificationRequestID!])
                        saveContext()
                        
                        // Updates core data: refreshes plants with updated watered date.
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
                        
                        let badgeCount = defaults.value(forKey: "NotificationBadgeCount") as! Int - 1
                        print("Badge Count: \(badgeCount)")
                        //Save the new value to User Defaults
                        defaults.set(badgeCount, forKey: "NotificationBadgeCount")
                        UIApplication.shared.applicationIconBadgeNumber = badgeCount
                        
                    default:
                        break;
                        
                    }
                    
                }
                
            }
            
        }
        
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner])
    }
    
    
    
    
    func setupLocalUserNotification(selectedAlert: Int) {
        
        center.getNotificationSettings { [self] settings in
            if settings.authorizationStatus == .authorized {
                
                loadPlants()
                
                let center = UNUserNotificationCenter.current()
                defaults.set(0, forKey: "NotificationBadgeCount")
                
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
                    }
                    
               
                }
                
                // 6: Set UNNotificationActions
                let plantNotificationWateredAction = UNNotificationAction(identifier: "plantNotificationWateredActionID", title: "Watered", options: [])
                let plantNotificationCancelAction = UNNotificationAction(identifier: "plantNotificationCancelActionID", title: "Not yet" , options: [])
                let notificationActionsCategory = UNNotificationCategory(identifier: "categoryIdentifier", actions: [plantNotificationWateredAction, plantNotificationCancelAction], intentIdentifiers: [], options: [])
                center.setNotificationCategories([notificationActionsCategory])
                
                
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
              
            }
            
        }
        
    }

    
    func refreshUserNotification() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        setupLocalUserNotification(selectedAlert: defaults.integer(forKey: "selectedAlertOption"))
    }
 
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func editPlant_FB(_ currentPlantID: UUID) {
        if authenticateFBUser() {
            let db = Firestore.firestore()
            
            //2: FIREBASE: Get currentUser UID to use as document's ID.
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            
            let userFireBase = db.collection("users").document(currentUser)
            
            //3: FIREBASE: Declare collection("plants)
            let plantCollection =  userFireBase.collection("plants")
            
            //4: FIREBASE: Plant entity input
            let plantEditedData: [String: Any] = [
                "lastWatered": Date.now,
                "wateredBool": true,
                "notificationDelivered": false
            ]
            
            // 5: FIREBASE: Set doucment name(use index# to later use in core data)
            let plantDoc = plantCollection.document("\(currentPlantID)")
            print("plantDoc edited uuid: \(currentPlantID.uuidString)")
            
            // 6: Edited data for "Plant entity input"
            plantDoc.updateData(plantEditedData) { error in
                if error != nil {
                    print("Error updating data on FB. Error: \(String(describing: error))")
                }
            }
            
            // 7: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    print("Error updating data on FB. Error: \(String(describing: error))")
                }
            }
            
            print("Plant successfully edited on Firebase")
        }
    }
    
    
}

