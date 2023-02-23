//
//  SceneDelegate.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/19/22.
//

import UIKit
import UserNotifications
import FirebaseAuth
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let defaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()
    
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /// 2. Create a new UIWindow using the windowScene constructor which takes in a window scene.
        let window = UIWindow(windowScene: windowScene)
        
        /// 3. Create a view hierarchy programmatically
        let viewController = LogoViewController()

        /// 4. Set the root view controller of the window with your view controller
        window.rootViewController = viewController
        
        
        /// 5. Set the window and call makeKeyAndVisible()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        // Below will
        defaults.set(true, forKey: "userDiscardedApp")
        defaults.set(true, forKey: "loginVCReload")
        defaults.set(true, forKey: "logoVCReload")
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        print("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        print("DID BECOME ACTIVE")
        getDeliveredNotifications()
      

    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("Scene did enter foreground")

        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    
}


extension SceneDelegate {
    
    func loadPlants() {
        
        do {
            let request = Plant.fetchRequest() as NSFetchRequest<Plant>
            let sort = NSSortDescriptor(key: "order", ascending: true)
            request.sortDescriptors = [sort]
            plants = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        print("SceneDelegate: Plants loaded")
        print("SceneDelegate: Core Data count: \(plants.count)")
        
    }
    
    func savePlants() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
    }
    
    func getDeliveredNotifications() {
        
        if defaults.bool(forKey: "notificationOn") {
            
            loadPlants()
            
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
                                    savePlants()
                                }
                                
                                print("Scene: Plant: \(String(describing: p.plant)), ID: \(String(describing: p.notificationRequestID)) notificationPresented\(p.notificationPresented)")
                            }
                            
                        }
                        
                    }
                    
                }
                
                for p in plants {
                    let waterHabitIn = p.waterHabit
                    let lastWateredDateIn = p.lastWateredDate
                    var nextWaterDate: Date {
                        let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: Int(waterHabitIn), to:  (lastWateredDateIn)!)
                        return calculatedDate!
                    }

                    if nextWaterDate < Date.now {
                        p.notificationPresented = true
                        savePlants()
                    }
                }

            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
            
        }
        
    }
    
}
