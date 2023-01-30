//
//  ViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/19/22.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MainViewController: UIViewController {
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Google Firebase
    var userID_FB = ""
    var plants_FBLoaded = [QueryDocumentSnapshot]()
    var userSettings = [String: Any]()
    var updatedUserSettings = false
    
    
    // MARK: - UserDefaults for saving small data/settings
    let defaults = UserDefaults.standard
    
    // MARK: - UNUserNotificationCenter
    let center = UNUserNotificationCenter.current()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var plantsTableView: UITableView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherLogo = ""
    var weatherTemp = ""
    var weatherCity = ""
    
    let imageSetNames = K.imageSetNames
    
    // MARK: - UIViews added
    let opaqueView = UIView()
    let loadingSpinnerView = UIActivityIndicatorView(style: .large)
    
    
// MARK: - Views load state
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = K.title
        self.plantsTableView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.prefersLargeTitles = true
        
        plantsTableView.delegate = self
        plantsTableView.dataSource = self
        plantsTableView.layer.cornerRadius = 10
        
        // Register: PlantTableViewCell
        plantsTableView.register(UINib(nibName: K.plantTableViewCellID, bundle: nil), forCellReuseIdentifier: K.plantTableViewCellID)
        
        weatherManager.delegate = self
        
        loadFirebaseUser()
        
        if defaults.bool(forKey: "fbUserFirstLoggedIn") {
            loadPlantsFB {
                self.updateUserSettings()
            }
            defaults.set(false, forKey: "fbUserFirstLoggedIn")
        }
        
        if defaults.bool(forKey: "userDiscardedApp") {
            resetContext {
                self.loadPlants()
                self.defaults.set(false, forKey: "userDiscardedApp")
            }
        }
        
        // Load plants from Core Data
        if authenticateFBUser() == false {
            loadPlants()
        }
        
        print("View reload. Core Data: \(plants.count)")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: NSNotification.Name("triggerLoadPlants"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotificationReceived), name: NSNotification.Name("logoutTriggered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserNotification), name: NSNotification.Name("refreshUserNotification"), object: nil)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if updatedUserSettings == true {
            self.refreshUserNotification()
            print("DDD: \(defaults.integer(forKey: "NotificationBadgeCount"))")
            updatedUserSettings = false
        }
    }
    
    
    @objc func notificationReceived() {
        loadPlants()
    }
    
    
    @objc func logoutNotificationReceived() {
        print("Logout triggered")
        self.presentingViewController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadLogoView"), object: nil)
        })
    }

    
    
    // MARK: - Button IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        // Future feature: Edit button to allow re-order tableView.
        self.plantsTableView.isEditing.toggle()
        updateOrderNumber_FB()
        
        if self.plantsTableView.isEditing == true {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
    
    }
    
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        // lead to settings page
        let settingsVC = SettingsViewController()
        let settingsPlantNavVC = UINavigationController(rootViewController: settingsVC)
        settingsVC.userSettings = userSettings
        settingsVC.modalPresentationStyle = .formSheet
        present(settingsPlantNavVC, animated: true, completion: nil)

    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: K.mainToAddPlantID, sender: self)
    }
    
    
    //MARK: - Data Manipulation Methods
    func savePlants() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
    }
    
    func loadPlants() {
        
        DispatchQueue.main.async {
            self.addLoadingView()
        }
    
        do {
            let request = Plant.fetchRequest() as NSFetchRequest<Plant>
            let sort = NSSortDescriptor(key: "order", ascending: true)
            request.sortDescriptors = [sort]
            plants = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        DispatchQueue.main.async {
            self.plantsTableView.reloadData()
        }
        
        
        print("Plants loaded")
        print("Core Data count: \(plants.count)")
        
    }
    
    func deletePlant(indexPath: IndexPath) {
        let indexPathConst = indexPath
        deletePlant_FB(indexPath: indexPathConst)
        
        guard let unID = plants[indexPathConst.row].notificationRequestID else {
            return
        }
        
        center.removePendingNotificationRequests(withIdentifiers: [unID])
        center.getDeliveredNotifications { [self] deliveredNotifications in
            for d in deliveredNotifications {
                if d.request.identifier == unID {
                    center.removeDeliveredNotifications(withIdentifiers: [unID])
                    print("Delivered Notification removed: \(unID)")
                    let badgeCount = defaults.value(forKey: "NotificationBadgeCount") as! Int - 1
                    defaults.set(badgeCount, forKey: "NotificationBadgeCount")
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = badgeCount
                    }
                }
            }
        }
        
        context.delete(plants[indexPathConst.row])
        self.plants.remove(at: indexPathConst.row)
        self.plantsTableView.deleteRows(at: [indexPathConst], with: .automatic)
        self.savePlants()

        print("Core data deleted indexPath: \(indexPath)")
    }
    
    
    // MARK: - convert retrieved Data to UIImage
    func loadedImage(with imageData: Data?) -> UIImage {
        guard let imageData = imageData else {
            return UIImage(named: "UnknownPlant")!
        }
        let loadedImage = UIImage(data: imageData)
        return loadedImage!
    }
    
    // MARK: - Formatting displayedNextWaterDate
    func displayedNextWaterDate(lastWateredDate: Date, waterHabit: Int) -> String {
        var nextWaterDate: Date {
            let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabit, to: lastWateredDate.advanced(by: 86400))
            return calculatedDate!
        }
        
        var waterStatus: String {
            
            let dateIntervalFormat = DateComponentsFormatter()
            dateIntervalFormat.allowedUnits = .day
            dateIntervalFormat.unitsStyle = .short
            let formatted = dateIntervalFormat.string(from: Date.now, to: nextWaterDate) ?? ""
            if formatted == "0 days" || nextWaterDate < Date.now {
                return "due"
            } else if dateFormatter.string(from: lastWateredDate) == dateFormatter.string(from: Date.now) {
                return "\(waterHabit) days"
            } else {
                return "\(formatted)"
            }
            
        }
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }
    
        return waterStatus
    }
    
}


// MARK: - Extensions: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    // TableView cell selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.mainToPlantID, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // SwipeToDelete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") { [self]  (contextualAction, view, boolValue) in
            deletePlant(indexPath: indexPath)
            updateOrderNumber_FB()
        }
      
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
    
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PlantViewController {
            if let indexPath = plantsTableView.indexPathForSelectedRow {
                let vc = segue.destination as? PlantViewController
                vc?.inputLogoIn = weatherLogo
                vc?.inputTempIn = weatherTemp
                vc?.inputCityIn = weatherCity
                
                // pass selected Plant's data from tableView into PlantViewController
                let plant = plants[indexPath.row]
                vc?.currentPlant = plant
                
                // Assigns plant's image to tableView.
                if imageSetNames.contains(plant.plantImageString!) {
                    vc?.plantImageLoadedIn = UIImage(named: plant.plantImageString!)!
                } else {
                    vc?.plantImageLoadedIn = loadedImage(with: plant.imageData)
                }
                
            }
        }
        
    }
    
}

// MARK: - Extension: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    // Tells how many rows to list out in tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        removeLoadingView()
        
        return plants.count
    }
    
    // Inputs custom UITableViewCell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: K.plantTableViewCellID, for: indexPath) as! PlantTableViewCell
        
        // Later, assign values to cell's properties: EX below
        cell.plantName.text = plants[indexPath.row].plant
        
        if imageSetNames.contains(plants[indexPath.row].plantImageString!) {
            cell.plantImage.image = UIImage(named: plants[indexPath.row].plantImageString!)
        } else {
            cell.plantImage.image = loadedImage(with: plants[indexPath.row].imageData)
        }
        
        cell.waterInDays.text = displayedNextWaterDate(lastWateredDate: plants[indexPath.row].lastWateredDate!, waterHabit: Int(plants[indexPath.row].waterHabit))
        
        return cell
    }
    
    
// MARK: - methods needed for editing/deleting/re-ordering tableViews

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Re-Order tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.plants[sourceIndexPath.row]
        plants.remove(at: sourceIndexPath.row)
        plants.insert(movedObject, at: destinationIndexPath.row)
        
        for (index, item) in plants.enumerated() {
            item.order = Int32(index)
        }
        
        savePlants()
        
    }
    
}

// MARK: - Extension: weather call
extension MainViewController: WeatherManagerDelegate, CLLocationManagerDelegate   {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherLogo = weather.conditionName
            self.weatherTemp = weather.teperatureString
            self.weatherCity = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print("Error updating weather. Error: \(error)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error updating location. Error: \(error)")
    }
    
}


// MARK: - Extension: Firebase functions
extension MainViewController {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    // Firestore: load user
    func loadFirebaseUser() {
        if authenticateFBUser() {
            let currentUser = Auth.auth().currentUser?.email
            // Add some kind of function to grab user's ID/Name to display in MainVC
            
            print("Current user logged in: \(String(describing: currentUser))")
        } else {
            print("No Firebase user logged in")
        }
    }

    func loadPlantsFB(completion: @escaping () -> Void) {
     
        if authenticateFBUser() {
            let currentUser = Auth.auth().currentUser?.email
            // Add some kind of function to grab user's ID/Name to display in MainVC

            //Get currentUser UID to use as document's ID.
            let db = Firestore.firestore()
            userID_FB = Auth.auth().currentUser!.uid
            print("userID_FB: \(userID_FB)")

            let currentUserCollection = db.collection("users").document(userID_FB)
            let plantsCollection = currentUserCollection.collection("plants")
    
            // Get all documents/plants and put it in "plants_FB"
            plantsCollection.getDocuments { (snapshot, error) in
                if error == nil && snapshot != nil {
                    
                    var plants_FB = [QueryDocumentSnapshot]()
                    
                    plants_FB = snapshot!.documents
                    self.plants_FBLoaded = plants_FB
                    
                    var plantDocIDsArray = [String]()

                    for d in snapshot!.documents {
                        plantDocIDsArray.append(d.documentID)
                    }
                    
                    self.parseAndSaveFBintoCoreData(plants_FB: plants_FB) {
                        self.loadPlants()
                        completion()
                    }
             
                    print("Core Data count after FB loaded: \(self.plants.count)")

                } else {
                    print("Error getting documents from plant collection from firebase")
                }
            }
            
            // Get user settings
            currentUserCollection.getDocument { (snapshot, error) in
                if error == nil && snapshot != nil {
                    let settingsSnapshot = snapshot!.data()
                    self.userSettings = settingsSnapshot!
                } else {
                    print("Error getting user Settings: \(String(describing: error))")
                }
            }
            
            print("Current user logged in: \(String(describing: currentUser))")
        } else {
            print("No Firebase user logged in")
        }

    }
    
    func parseAndSaveFBintoCoreData(plants_FB: [QueryDocumentSnapshot], completion: @escaping () -> Void) {
        
        // MARK: - Parse plants from Firebase to Core Data
        for doc in plants_FB {
            
            let data = doc.data()
            
            print("Doc ID: \(doc.documentID)")
            print(doc.data())
            
            //dateAdded
            var dateAdded_FB = Date.now
            if let timestamp = data["dateAdded"] as? Timestamp {
                dateAdded_FB = timestamp.dateValue()
                print("dateAdded_FB: \(dateAdded_FB)")
            }

            //lastWatered
            var lastWatered_FB = Date.now
            if let timestamp = data["lastWatered"] as? Timestamp {
                lastWatered_FB = timestamp.dateValue()
                print("lastWatered_FB: \(lastWatered_FB)")
            }

            //plantDocId
            let plantDocId_FB = data["plantDocId"] as? String ?? "Missing plantDocID"
            print("plantDocId_FB: \(plantDocId_FB)")

            //plantImageString
            let plantImageString_FB = data["plantImageString"] as? String ?? ""
            print("plantImageString_FB: \(plantImageString_FB)")

            //plantName
            let plantName_FB = data["plantName"] as? String ?? ""
            print("plantName_FB: \(plantName_FB)")

            //plantOrder
            let plantOrder_FB = data["plantOrder"] as? Int ?? 0
            print("plantOrder_FB: \(plantOrder_FB)")

            //plantUUID
            let plantUUID_FB = data["plantUUID"]
            let plantUUID_FBCasted = UUID(uuidString: plantUUID_FB as? String ?? "")
            print("plantUUID_FB: \(String(describing: plantUUID_FBCasted))")

            //waterHabit
            let waterHabit_FB = data["waterHabit"] as? Int ?? 0
            print("waterHabit_FB: \(waterHabit_FB)")
            
            //wateredBool
            let wateredBool_FB = data["wateredBool"] as? Bool ?? false
            print("wateredBool_FB: \(wateredBool_FB)")
            
            //notificationRequestID
            let notificationRequestID_FB = data["notificationRequestID"] as? String ?? ""
            print("notificationRequestID_FB: \(notificationRequestID_FB)")
            
            //notificationPending
            let notificationPending_FB = data["notificationPending"] as? Bool ?? false
            print("notificationPending_FB: \(notificationPending_FB)")
            
            // MARK: - Below will save parse'd data from Firebase into Core Data.
            let loadedPlant_FB = Plant(context: self.context)
            loadedPlant_FB.id = plantUUID_FBCasted
            loadedPlant_FB.plant = plantName_FB
            loadedPlant_FB.waterHabit = Int16(waterHabit_FB)
            loadedPlant_FB.dateAdded = dateAdded_FB
            loadedPlant_FB.order = Int32(plantOrder_FB)
            loadedPlant_FB.lastWateredDate = lastWatered_FB
            loadedPlant_FB.plantImageString = plantImageString_FB
            loadedPlant_FB.wateredBool = wateredBool_FB
            loadedPlant_FB.notificationRequestID = notificationRequestID_FB
            loadedPlant_FB.notificationPending = notificationPending_FB
            
            let customPlantImageUUID_FB = data["customPlantImageUUID"] as? String

            if customPlantImageUUID_FB != nil {
               
                    print("customPlantImageUUID_FB path: \(customPlantImageUUID_FB!)")
                    
                    let fileRef = Storage.storage().reference(withPath: customPlantImageUUID_FB!)
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if error == nil && data != nil {
                            loadedPlant_FB.customPlantImageID = customPlantImageUUID_FB!
                            loadedPlant_FB.imageData = data!
                            print("FB Storage imageData has been retrieved successfully: \(data!)")
                            self.plants.append(loadedPlant_FB)
                            self.savePlants()
                            completion()
                        } else {
                            print("Error retrieving data from cloud storage. Error: \(String(describing: error))")
                        }
                    }
                
                
            } else {
                print("customPlantImage_FB is nil.")
                self.plants.append(loadedPlant_FB)
                self.savePlants()
                completion()
            }
            
        }

    }
    
    
    func deletePlant_FB(indexPath: IndexPath) {
        
        if authenticateFBUser() {
            
            let db = Firestore.firestore()
            userID_FB = Auth.auth().currentUser!.uid
            
            let currentUserCollection = db.collection("users").document(userID_FB)
            let plantsCollection = currentUserCollection.collection("plants")
            
            let plantUUID = self.plants[indexPath.row].id!.uuidString
            
            plantsCollection.document("\(plantUUID)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    print("FB deleted plant: \(plantUUID)")
                }
            }
            
            if let plantToDeleteImageID = self.plants[indexPath.row].customPlantImageID {
                let path = plantToDeleteImageID
                let plantRef = Storage.storage().reference(withPath: path)
                
                // Delete the file
                plantRef.delete { error in
                    if let error = error {
                        print("Error deleting image from FB Storage. Error: \(error)")
                    } else {
                        print("Successfully delete image from FB Storage")
                    }
                }
            }
        
        }
    
        
    }
    
    func updateOrderNumber_FB() {
        
        if authenticateFBUser() {
            
            let db = Firestore.firestore()
            userID_FB = Auth.auth().currentUser!.uid
            let currentUserCollection = db.collection("users").document(userID_FB)
            
            let plantsCollection = currentUserCollection.collection("plants")
            
            // Ensures range doesn't reach negative when used in for loop.
            var range = plants.endIndex - 1
            if range < 0 {
                range = 0
            }
            
            // loop through plants
            for i in 0...range {
                //ensures index number doesn't go out of range.
                if range >= plants.startIndex && range < plants.endIndex {
                    let plantUUID = self.plants[i].id!.uuidString
                    
                    let plantArray_FB = plantsCollection.document("\(plantUUID)")
                    
                    plantArray_FB.updateData(["plantOrder": i]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Plants order number have been successfully updated")
                        }
                    }
                    
                } else {
                    print("Plants array index has reached 0")
                }
            }
            
        }
        
    }
    
    func resetContext(completion: @escaping () -> Void) {
        if authenticateFBUser() {

            if plants.count != 0 {
                for i in 0...plants.endIndex - 1 {
                    context.delete(plants[i])
                    savePlants()
                }
            }
            
            if plants.count == 0 {
                savePlants()
                completion()
            }
            
        }
    }
    
    func editPlant_FB(_ currentPlantID: UUID, plantEditedData: [String: Any] ) {
        if authenticateFBUser() {
            let db = Firestore.firestore()
            
            //2: FIREBASE: Get currentUser UID to use as document's ID.
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            
            let userFireBase = db.collection("users").document(currentUser)
            
            //3: FIREBASE: Declare collection("plants)
            let plantCollection =  userFireBase.collection("plants")
            
            //4: FIREBASE: Plant entity input
        
            
            // 5: FIREBASE: Set doucment name(use index# to later use in core data)
            let plantDoc = plantCollection.document("\(currentPlantID.uuidString)")
            
            // 6: Edited data for "Plant entity input"
            plantDoc.updateData(plantEditedData) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
                print("plantDoc edited uuid: \(currentPlantID.uuidString)")
            }
            
            // 7: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
                print("Plant successfully updated on Firebase")
            }
            
        }
    }
    
}

// MARK: - Extension: UNUserNotificationCenter functions
extension MainViewController: UNUserNotificationCenterDelegate {
    
    func updateUserSettings() {
    
        let notificationOn = userSettings["Notification On"] as? Bool ?? nil
        print("notificationOn: \(notificationOn)")
        self.defaults.set(notificationOn, forKey: "notificationOn")
        
        // Set setting: Notification Alert Time
        let notificationAlertTime = userSettings["Notification Alert Time"] as? Int ?? nil
        print("notificationAlertTime: \(notificationAlertTime)")
        self.defaults.set(notificationAlertTime, forKey: "selectedAlertOption")
        
//        let notificationBadgeCount = userSettings["Notification Badge Count"] as? Int ?? nil
//        print("notificationBadgeCount: \(notificationBadgeCount)")
//        self.defaults.set(notificationBadgeCount, forKey: "NotificationBadgeCount")
//        UIApplication.shared.applicationIconBadgeNumber = defaults.integer(forKey: "NotificationBadgeCount")
        
        if notificationOn != nil && notificationAlertTime != nil {
            updatedUserSettings = true
        
        }
        
    }
    
    func setupLocalUserNotification(selectedAlert: Int) {
        
        center.getNotificationSettings { [self] settings in
            
            // If user already authorized/allowed user notification in the beginning of app, User Notification setup may proceed.
            if settings.authorizationStatus == .authorized {
                
                // First, load plants into plant's context.
                loadPlants()
                
                let center = UNUserNotificationCenter.current()
                
                // For each/every plant, this will create a notification
                for plant in plants {
                    
                    if plant.notificationPending == false {
                        
                        print("Plant notification set: \(plant.plant)")
                        
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
//                            selectedNotificationTime = Date.now.advanced(by: 10)
                            
                            // Uncomment below when not debugging:
                            selectedNotificationTime = nextWaterDate.advanced(by: 100)
                            print("Notification Time:: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
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
                        plant.notificationPresented = false
                        plant.notificationPending = true
                        print("notificationRequestID: \(uuidString)")
                        let notificationRequest = UNNotificationRequest(identifier: uuidString.uuidString, content: content, trigger: notificationTrigger)
                        
                        // 5: Register the request
                        center.add(notificationRequest) { (error) in
                            // check the error parameter or handle any errors
                            guard error == nil else {
                                print("NotificationRequest error: \(error.debugDescription)")
                                return
                            }
                            
                            self.savePlants()
                            self.editPlant_FB(plant.id!, plantEditedData: [
                                "notificationPending": true,
                                "notificationRequestID": plant.notificationRequestID as Any
                            ])
                            
                            print("Notification Request successfully added for ID: \(notificationRequest.identifier)")
                        }
                        
                    }
                    
                }
                
                // Set UNNotificationActions
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
             
            }
            
        }
    
    }
    
    @objc func refreshUserNotification() {
        if defaults.bool(forKey: "notificationOn") {
            setupLocalUserNotification(selectedAlert: defaults.integer(forKey: "selectedAlertOption"))
            print("DEEZ")
        }
    }
    
}

// MARK: - Additional added Views
extension MainViewController {
    
    func addLoadingView() {
        print("addLoadingView")
        loadingSpinnerView.color = .gray
        loadingSpinnerView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: plantsTableView.bounds.width, height: CGFloat(44))
        plantsTableView.tableFooterView = loadingSpinnerView
        loadingSpinnerView.startAnimating()
    }
    
    func removeLoadingView() {
        if plants.count != 0 {
            self.plantsTableView.tableFooterView?.removeFromSuperview()
            print("removeLoadingView")
        }
    }
    
}
