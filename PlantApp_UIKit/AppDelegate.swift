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


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var plants = [Plant]()
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 1: Ask for permission
        let center = UNUserNotificationCenter.current()
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
        
        self.registerNotificationAction()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        return true
    }
    
    
    func registerNotificationAction() {
        let center = UNUserNotificationCenter.current()
    
        let plantNotificationWateredAction = UNNotificationAction(identifier: "plantNotificationWateredActionID", title: "Watered", options: [])
        let plantNotificationCancelAction = UNNotificationAction(identifier: "plantNotificationCancelActionID", title: "Not yet" , options: [])
        let notificationActionsCategory = UNNotificationCategory(identifier: "categoryIdentifier", actions: [plantNotificationWateredAction, plantNotificationCancelAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories([notificationActionsCategory])
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
    }
    
    
}

extension AppDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        loadPlants()
        
        for plant in plants {
            
            if response.notification.request.identifier == plant.notificationRequestID?.uuidString {
                
                if response.notification.request.content.categoryIdentifier == "categoryIdentifier" {
                    
                    switch response.actionIdentifier {
                    case UNNotificationDefaultActionIdentifier:
                        print(response.actionIdentifier)
                        print("Default clicked.")
                    case "plantNotificationWateredActionID":
                        print(response.actionIdentifier)
                        print("Watered clicked")
                        
                        print("Notification request ID: \(response.notification.request.identifier)")
                        print("Plant Notification Request ID: \(plant.notificationRequestID!.uuidString)")
                        
                        plant.lastWateredDate = Date.now
                        plant.wateredBool = true
                        print("Updated to: \(plant.lastWateredDate!)")
                        
                        center.removeDeliveredNotifications(withIdentifiers: [plant.notificationRequestID!.uuidString])
                        saveContext()
                        
                        // Updates core data
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationResponseClickedID"), object: nil)
                        
//                        UIApplication.shared.applicationIconBadgeNumber = 0
                        let badgeCount = defaults.value(forKey: "NotificationBadgeCount") as! Int - 1
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
    
        completionHandler([.badge, .sound])
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
