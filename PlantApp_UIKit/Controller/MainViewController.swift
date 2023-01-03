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
  
    
    // MARK: - UserDefaults for saving small data/settings
    let defaults = UserDefaults.standard
    
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
        
        if defaults.bool(forKey: "userFirstLoggedIn") {
            loadPlantsFB()
            defaults.set(false, forKey: "userFirstLoggedIn")
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
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: NSNotification.Name("notificationResponseClickedID"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotificationReceived), name: NSNotification.Name("logoutTriggered"), object: nil)
        
        
    }
    
    
    @objc func notificationReceived() {
        loadPlants()
    }
    
    
    @objc func logoutNotificationReceived() {
        print("Logout triggered")
        self.navigationController?.popViewController(animated: true)
//        let loginVC = LoginViewController()
//        self.navigationController?.pushViewController(loginVC, animated: true)
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
        
        addLoadingView()
        
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
        
        
        resetUserNotification()
        print("Plants loaded")
        print("Core Data count: \(plants.count)")
        
    }
    
    func deletePlant(indexPath: IndexPath) {
        let indexPathConst = indexPath
        deletePlant_FB(indexPath: indexPathConst)
        
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
    
    func resetUserNotification() {
        
        print("reset triggered")
        let notificationCount = 0

        print("Notification count: \(notificationCount)")
        //Save the new value to User Defaults
        defaults.set(notificationCount, forKey: "NotificationBadgeCount")
        UIApplication.shared.applicationIconBadgeNumber = notificationCount
        
    }
    
}


// MARK: - Extensions: UITableViewDelegate, UITableViewDataSource, WeatherManagerDelegate, CLLocationManagerDelegate
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

// MARK: - extension for weather call
extension MainViewController: WeatherManagerDelegate {
    
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
    
}

extension MainViewController: CLLocationManagerDelegate {
    
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

// MARK: - Firebase functions
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
        if Auth.auth().currentUser?.uid != nil {
            let currentUser = Auth.auth().currentUser?.email
            // Add some kind of function to grab user's ID/Name to display in MainVC
            
            print("Current user logged in: \(String(describing: currentUser))")
        } else {
            print("No Firebase user logged in")
        }
    }

    func loadPlantsFB() {
     
        if Auth.auth().currentUser?.uid != nil {
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
                    }
             
                    print("Core Data count after FB loaded: \(self.plants.count)")

                } else {
                    print("Error getting documents from plant collection from firebase")
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
            
            // MARK: - Below will save parse'd data from Firebase into Core Data.
            let loadedPlant_FB = Plant(context: self.context)
            loadedPlant_FB.id = plantUUID_FBCasted
            loadedPlant_FB.plant = plantName_FB
            loadedPlant_FB.waterHabit = Int16(waterHabit_FB)
            loadedPlant_FB.dateAdded = dateAdded_FB
            loadedPlant_FB.order = Int32(plantOrder_FB)
            loadedPlant_FB.lastWateredDate = lastWatered_FB
            loadedPlant_FB.plantImageString = plantImageString_FB
            
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
        if Auth.auth().currentUser?.uid != nil {

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
    
    func addLoadingView() {
        print("addLoadingView")
        loadingSpinnerView.color = .gray
        loadingSpinnerView.startAnimating()
        loadingSpinnerView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: plantsTableView.bounds.width, height: CGFloat(44))

        plantsTableView.tableFooterView = loadingSpinnerView
    }
    
    func removeLoadingView() {
        if plants.count != 0 {
            self.plantsTableView.tableFooterView?.removeFromSuperview()
            print("removeLoadingView")
        } else {
            self.plantsTableView.tableFooterView?.removeFromSuperview()
        }
    }
    
}

