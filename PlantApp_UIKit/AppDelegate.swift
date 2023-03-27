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
    
    // When user provides a response/action on the presented notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
     
        loadPlants()
        
        getDeliveredNotifications()
        
        for plant in plants {
            
            if response.notification.request.identifier == plant.notificationRequestID {
                
                if response.notification.request.content.categoryIdentifier == "categoryIdentifier" {
                    print("Response: \(response.actionIdentifier)")
                    switch response.actionIdentifier {
                        
                    case UNNotificationDefaultActionIdentifier:
                        print(response.actionIdentifier)
                        print("Default clicked.")
                    case "plantNotificationWateredActionID":
                        print(response.actionIdentifier)
                        print("Watered clicked")
                        print("Response Notification request ID: \(response.notification.request.identifier)")
                        print("Plant Notification Request ID: \(plant.notificationRequestID!)")
                        
                        plant.lastWateredDate = Date.now
                        plant.wateredBool = true
                        plant.notificationPending = false
                        plant.notificationPresented = false
                       
                        print("Plant: \(plant.plant!) lastWateredDate - updated to: \(plant.lastWateredDate!)")
                        editPlant_FB(plant.id!)
                        center.removeDeliveredNotifications(withIdentifiers: [plant.notificationRequestID!])
                        saveContext()
                        
                        // Updates core data: refreshes plants with updated watered date.
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                        
                        
                        DispatchQueue.main.async {
                            UIApplication.shared.applicationIconBadgeNumber =  UIApplication.shared.applicationIconBadgeNumber - 1
                            print("UIAppNumber: \(UIApplication.shared.applicationIconBadgeNumber)")
                        }
                        
                    case UNNotificationDismissActionIdentifier:
                        print("UNNotificationDismissActionIdentifier triggered")
                        plant.notificationPending = false
                        plant.notificationPresented = true
                        saveContext()
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)

                    default:
                        break;
                        
                    }
                    
                }
                
                
            }
            
        }
        
        completionHandler()
    }
    
    // Asks the delegate how to handle a notification that arrived while the app was running in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification presented: \(notification.request.identifier)")
        loadPlants()
        getDeliveredNotifications()

        completionHandler([.badge, .sound, .banner])
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
                "notificationPending": false
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
    
    func getDeliveredNotifications() {
        center.getDeliveredNotifications { [self] unNotification in
            print("DDD: \(unNotification.count)")
            var deliveredNotifications = [String]()
            for deliveredNoti in unNotification {
                
                deliveredNotifications.append(deliveredNoti.request.identifier)
                print("Delivered Notifications list: \(deliveredNoti.request.identifier)")
                
                if !deliveredNotifications.isEmpty {
                    
                    defaults.set(deliveredNotifications, forKey: "deliveredNotificationsStored")
                    
                    let deliveredNotificationsStored = defaults.object(forKey: "deliveredNotificationsStored") as? [String] ?? []
                    
                    if !deliveredNotificationsStored.isEmpty {
                        
                        print("deliveredNotificationsStored: \(deliveredNotificationsStored)")
                        
                        for p in plants {
                            guard let notificationID = p.notificationRequestID else { return }
                            if deliveredNotifications.contains(notificationID) {
                                p.notificationPresented = true
                                saveContext()
                            }
                        }
                        
                    }
                    
                }
                
            }

        }
    }
    

    
}

