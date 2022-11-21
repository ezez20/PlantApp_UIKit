//
//  ViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/19/22.
//

import UIKit
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
    var plants_FB = [QueryDocumentSnapshot]()
    var plantImages_FB = [QueryDocumentSnapshot]()
    
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
        
        // Load plants from Core Data
        loadPlants()
        
        loadFirebaseUser()
        loadPlantsFB()
        retrieveFBCloudStorage()
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
        loadPlantsFB()
    }
    
    @objc func logoutNotificationReceived() {
        print("Logout triggered")
//        let viewController = LoginViewController()
//        let navigation = UINavigationController(rootViewController: viewController)
        self.navigationController?.popToRootViewController(animated: true)
    }

    
    
    // MARK: - Button IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        // Future feature: Edit button to allow re-order tableView.
        self.plantsTableView.isEditing.toggle()
        
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
        
        loadPlants()
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
        
        plantsTableView.reloadData()
        print("Plants loaded")
        refreshUserNotification()
        
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
    
    func refreshUserNotification() {
        print("refreshUserNotification triggered")
        var notificationCount = 0
        
        for plant in plants {

            var nextWaterDate: Date {
                let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: Int(plant.waterHabit), to: plant.lastWateredDate!.advanced(by: 86400))
                return calculatedDate!
            }

            var waterStatus: String {

                let dateIntervalFormat = DateComponentsFormatter()
                dateIntervalFormat.allowedUnits = .day
                dateIntervalFormat.unitsStyle = .short
                let formatted = dateIntervalFormat.string(from: Date.now, to: nextWaterDate) ?? ""
                if formatted == "0 days" || nextWaterDate < Date.now {
                    plant.wateredBool = false
                    notificationCount += 1
                    return "due"
                } else {
                    plant.wateredBool = true
                    return "\(formatted)"
                }
            }
            print(waterStatus)
        }
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
//        print("You tapped on \(indexPath.description)")
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
        //        return 3
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
    
    
    // MARK: - methods needed for editing/re-ordering tableViews
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
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


extension MainViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.sync {
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
            
            let currentUserCollection = db.collection("users").document(userID_FB)
            let plantsCollection = currentUserCollection.collection("plants")
       
            // Get all documents/plants and put it in "plants_FB"
            plantsCollection.getDocuments { (snapshot, error) in
                if error == nil && snapshot != nil {
                    let data = snapshot!.documents
                    self.plants_FB = data
                    print("FB: Plant Collection count: \(data.count)")
                } else {
                    print("Error getting documents from plant collection from firebase")
                }
            }
            print("Current user logged in: \(String(describing: currentUser))")
        } else {
            print("No Firebase user logged in")
        }
        
        
        
    }
    
    func retrieveFBCloudStorage() {
        let db = Firestore.firestore()

        db.collection("customSavedPlantImages").getDocuments { snapshot, error in

            if error == nil && snapshot != nil {
                self.plants_FB = snapshot!.documents
            } else {
                print("Error retrieving data from FBCloudStorage")
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
                    self.loadPlantsFB()
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
                            self.loadPlantsFB()
                        }
                    }
                } else {
                    print("Plants array index has reached 0")
                }
            }
            
        }
        
    }
    
}

