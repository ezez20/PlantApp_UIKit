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
import UniformTypeIdentifiers


class MainViewController: UIViewController {
 
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Google Firebase
    var userID_FB = ""
    var plants_FBLoaded = [QueryDocumentSnapshot]()
    var userSettings = [String: Any]()
    
    // MARK: - UserDefaults for saving small data/settings
    let defaults = UserDefaults.standard
    
    // MARK: - UNUserNotificationCenter
    let center = UNUserNotificationCenter.current()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var plantsTableView: UITableView!
    @IBOutlet weak var viewChangeButton: UIBarButtonItem!
    @IBOutlet weak var qrButton: UIBarButtonItem!
    
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherLogo = ""
    var weatherTemp = ""
    var weatherCity = ""
    
    let imageSetNames = K.imageSetNames
    
    // MARK: - UIViews added
    let opaqueView = UIView()
    let loadingSpinnerView = UIActivityIndicatorView()
    
    let dispatchGroup = DispatchGroup()
    
    var collectionViewBool = false
    var collectionView: UICollectionView?
    
    deinit {
        print("MainVC has been deinitialized")
    }
    
// MARK: - Views load state
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        title = K.title
        viewChangeButton.image = collectionViewBool == true ? UIImage(systemName: "list.bullet") : UIImage(systemName: "square.grid.3x2")
        
        self.plantsTableView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.prefersLargeTitles = true
        
        plantsTableView.delegate = self
        plantsTableView.dataSource = self
        plantsTableView.layer.cornerRadius = 10
        
        
        // Register: PlantTableViewCell
        plantsTableView.register(UINib(nibName: K.plantTableViewCellID, bundle: nil), forCellReuseIdentifier: K.plantTableViewCellID)
       
        
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        loadFirebaseUser()
        
        view.addSubview(loadingSpinnerView)
        loadingSpinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingSpinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserNotification), name: NSNotification.Name("refreshUserNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPlantsNotification), name: NSNotification.Name("triggerLoadPlants"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotificationReceived), name: NSNotification.Name("logoutTriggered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlantsTableViewNotification), name: NSNotification.Name("reloadPlantsTableViewTriggered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(qrVCDismissedOpenPlantVC), name: NSNotification.Name("qrVCDismissToPlantVC"), object: nil)
        
        // Load plants from Core Data
        if authenticateFBUser() == false {
            addLoadingSpinner()
            loadPlants {
                self.refreshUserNotification()
                self.passPlantsDataToQRVC()
                self.removeLoadingView()
                print("PlantsTableview reloaded")
            }
        }
        
        // Load plants if user discarded app.
        if defaults.bool(forKey: "userDiscardedApp") {
            addLoadingSpinner()
            self.loadPlants {
                print("Plants Loaded. Core Data count: \(self.plants.count)")
                self.refreshUserNotification()
                self.removeLoadingView()
                self.defaults.set(false, forKey: "userDiscardedApp")
            }
            
        }
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        if traitCollection.userInterfaceStyle == .light {
            collectionView?.backgroundColor = .secondarySystemBackground
        } else {
            collectionView?.backgroundColor = .black
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
       
        // Load plants if FB user is logged in.
        if defaults.bool(forKey: "fbUserFirstLoggedIn") {
            addLoadingSpinner()
            loadPlantsFB {
                self.updateUserSettings {
                    print("updateUserSettings completed")
                    self.refreshUserNotification()
                    self.passPlantsDataToQRVC()
                    self.defaults.set(false, forKey: "fbUserFirstLoggedIn")
                    self.removeLoadingView()
                }
            }
        }
        
        
        // Reload FB images if internet connection was interupted.
        if !plants.isEmpty {
            reloadImageDataFB {
                self.loadPlants {
                    print("Reloading plants after reloadImageDataFB.")
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        passPlantsDataToQRVC()
    }
    
    
    // MARK: - Sets color based on Light/Dark Appearance switch.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .light {
            collectionView?.backgroundColor = .secondarySystemBackground
        } else {
            collectionView?.backgroundColor = .black
        }
        
    }
    
    
    @objc func loadPlantsNotification() {
        loadPlants {
            print("Plants Loaded. Core Data count: \(self.plants.count)")
            self.updateUnpresentedNotification()
        }
    }
    
    @objc func reloadPlantsTableViewNotification() {
        print("reloadPlantsTableViewNotification triggered")
        addLoadingSpinner()
        loadPlants {
            self.removeLoadingView()
        }
    }
    
    
    @objc func logoutNotificationReceived() {
        print("Logout triggered")
        
        self.presentingViewController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadLogoView"), object: nil)
        })
        
    }
    
    @objc func qrVCDismissedOpenPlantVC(_ notification: NSNotification) {
        print("qrVCDismissedOpenPlantVC")
        
        if let userInfo = notification.userInfo {
             if let value = userInfo["qrScannedPlantUUID"] as? String {
                  print("qrScannedPlantUUID: \(value)")
                 performSegue(withIdentifier: K.mainToPlantID, sender: value)
              }
          }
    }
    
    // MARK: - Button IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        // Future feature: Edit button to allow re-order tableView.
        self.plantsTableView.isEditing.toggle()
        updateOrderNumber_FB()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleDeleteViewNoti"), object: nil)

        if self.plantsTableView.isEditing == true {
            editButton.title = "Done"
            viewChangeButton.isEnabled = false
        } else {
            editButton.title = "Edit"
            viewChangeButton.isEnabled = true
        }
        
    }
    
    
//    @IBAction func settingButtonPressed(_ sender: Any) {
//        // lead to settings page
//        let settingsVC = SettingsViewController()
//        let settingsPlantNavVC = UINavigationController(rootViewController: settingsVC)
//        settingsVC.context = context
//        settingsVC.plants = plants
//        settingsVC.userSettings = userSettings
//        settingsVC.modalPresentationStyle = .formSheet
//        present(settingsPlantNavVC, animated: true, completion: nil)
//
//    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: K.mainToAddPlantID, sender: self)
        
    }
    
  
    @IBAction func viewChangeButtonPressed(_ sender: Any) {
        
        collectionViewBool.toggle()
        
        viewChangeButton.image = collectionViewBool == true ? UIImage(systemName: "list.bullet") : UIImage(systemName: "square.grid.3x2")
        
        if collectionViewBool == true {
            addCollectionView()
        } else {
            removeCollectionView()
        }
        
        loadPlants {
            
        }
        
    }
    
//    @IBAction func qrButtonPressed(_ sender: Any) {
//        print("QR buttton pressed")
//        let qrVC = QRScannerViewController(plants: plants)
//        present(qrVC, animated: true)
//    }
    
    
    //MARK: - Data Manipulation Methods
    func savePlants() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    func loadPlants(_ completion: @escaping () -> Void) {
        print("Loading plants")
        do {
            let request = Plant.fetchRequest() as NSFetchRequest<Plant>
            let sort = NSSortDescriptor(key: "order", ascending: true)
            request.sortDescriptors = [sort]
            plants = try context.fetch(request)
         
        } catch {
            print("Error loading categories \(error)")
        }
        
        DispatchQueue.main.async {
            print("plants reloaded")
            
            self.plantsTableView.reloadData()
            
            if self.collectionViewBool {
                self.collectionView?.reloadData()
            }
            
            completion()
        }
    
    }
    
    func deletePlant(indexPath: IndexPath) {
        let indexPathConst = indexPath
        
        deletePlant_FB(indexPath: indexPathConst)
        deleteNotification(indexPath: indexPath)
        
        context.delete(plants[indexPathConst.row])
        self.plants.remove(at: indexPathConst.row)
      
        self.savePlants()
        
        loadPlants {
            print("Plants Loaded. Core Data count: \(self.plants.count)")
            self.refreshUserNotification()
            self.passPlantsDataToQRVC()
        }
        
        if collectionViewBool {
            collectionView?.deleteItems(at: [indexPath])
        } else {
            self.plantsTableView.deleteRows(at: [indexPathConst], with: .automatic)
        }
        
       

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
            let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabit, to: lastWateredDate)
            return calculatedDate!
        }
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }
        
        var waterStatus: String {
            
            let dateIntervalFormat = DateComponentsFormatter()
            dateIntervalFormat.allowedUnits = .day
            dateIntervalFormat.unitsStyle = .short
            let formatted = dateIntervalFormat.string(from: Date.now, to: nextWaterDate) ?? ""
            if formatted == "0 days" || nextWaterDate < Date.now {
                return "today"
            } else if dateFormatter.string(from: lastWateredDate) == dateFormatter.string(from: Date.now) {
                return "\(waterHabit) days"
            } else {
                return "\(formatted)"
            }
            
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
    
    
  
    // PREPARE SEGUE for "K.mainToPlantID" used in storyboard for both:
        // 1: TABLEVIEW
        // 2: COLLECTIONVIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // TABLEVIEW
        if collectionViewBool == false {
            if segue.destination is PlantViewController {
                if let indexPath = plantsTableView.indexPathForSelectedRow {
                    let vc = segue.destination as? PlantViewController
                    vc?.inputLogoIn = weatherLogo
                    vc?.inputTempIn = weatherTemp
                    vc?.inputCityIn = weatherCity
                    
                    // pass selected Plant's data from tableView into PlantViewController
                    let plant = plants[indexPath.row]
                    vc?.currentPlant = plant
                    
                }
            }
            
        // COLLECTIONVIEW
        } else {
            if segue.identifier == K.mainToPlantID {
                if let cell = sender as? CollectionViewCell {
                    if let collectionView = collectionView {
                        if let indexPath = collectionView.indexPath(for: cell){
                            let vc = segue.destination as! PlantViewController
                            vc.inputLogoIn = weatherLogo
                            vc.inputTempIn = weatherTemp
                            vc.inputCityIn = weatherCity
                            vc.currentPlant = plants[indexPath.row]
                            
                        }
                    }
                }
            }
        }
        
        // User clicks on scanned plant from "QRScannerViewController"
        if ((sender as? String) != nil) {
            let plantUUID = sender as? String ?? ""
            if segue.destination is PlantViewController {
                for p in plants {
                    if p.id?.uuidString == plantUUID {
                        let vc = segue.destination as? PlantViewController
                        vc?.inputLogoIn = weatherLogo
                        vc?.inputTempIn = weatherTemp
                        vc?.inputCityIn = weatherCity
                    
                        vc?.currentPlant = p
                    }
                }
            }
          
        }

    }
    
}

// MARK: - Extension: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    // Tells how many rows to list out in tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return plants.count
    }
    
    // Inputs custom UITableViewCell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: K.plantTableViewCellID, for: indexPath) as! PlantTableViewCell
        
        // 1: Set Plant's name
        cell.plantName.text = plants[indexPath.row].plant
        
        // 2: Set image
        if imageSetNames.contains(plants[indexPath.row].plantImageString!) {
            cell.plantImage.image = UIImage(named: plants[indexPath.row].plantImageString!)
        } else {
            cell.plantImage.image = loadedImage(with: plants[indexPath.row].imageData)
        }
        
        // 3: Set water days
        cell.waterInDays.text = displayedNextWaterDate(lastWateredDate: plants[indexPath.row].lastWateredDate!, waterHabit: Int(plants[indexPath.row].waterHabit))
        
        // 4: Set Water level status
        let waterStatus = displayedNextWaterDate(lastWateredDate: plants[indexPath.row].lastWateredDate!, waterHabit: Int(plants[indexPath.row].waterHabit))
        
        if waterStatus.localizedStandardContains("today") {
            cell.tintColor = .systemRed
        } else if waterStatus.localizedStandardContains("1") || waterStatus.localizedStandardContains("2") || waterStatus.localizedStandardContains("3"){
            cell.tintColor = .systemYellow
        } else {
            cell.tintColor = .systemGreen
        }
        
        
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
            userID_FB = Auth.auth().currentUser!.uid
            // Add some kind of function to grab user's ID/Name to display in MainVC
            print("Current user logged in: \(String(describing: currentUser))")
        } else {
            print("No Firebase user logged in")
        }
    }

    func loadPlantsFB(completion: @escaping () -> Void) {
     
        if authenticateFBUser() {
            
            guard let currentUser = Auth.auth().currentUser?.email else { return }
            // Add some kind of function to grab user's ID/Name to display in MainVC

            //Get currentUser UID to use as document's ID.
            let db = Firestore.firestore()

            let currentUserCollection = db.collection("users").document(userID_FB)
            let plantsCollection = currentUserCollection.collection("plants")
    
            // Get all documents/plants and put it in "plants_FB"
            plantsCollection.getDocuments { [weak self] (snapshot, error) in
                if error == nil && snapshot != nil {
                  
                    var plants_FB: [QueryDocumentSnapshot]
                    
                    plants_FB = snapshot!.documents
                    self?.plants_FBLoaded = plants_FB
                    
                    self?.parseAndSaveFBintoCoreData(plants_FB: plants_FB) {
                        print("parseAndSaveFBintoCoreData completed")
                        
                        self?.loadPlants {
                            print("Plants Loaded. Core Data count: \(String(describing: self?.plants.count))")
                            completion()
                        }
                        
                    }

                } else {
                    print("Error getting documents from plant collection from firebase")
                    completion()
                }
            }
            
            // Get user settings
            currentUserCollection.getDocument { [weak self] (snapshot, error) in
                if error == nil && snapshot != nil {
                    let settingsSnapshot = snapshot!.data()
                    self?.userSettings = settingsSnapshot!
                } else {
                    print("Error getting user Settings: \(String(describing: error))")
                }
            }
            
            print("Current user logged in: \(String(describing: currentUser))")
        } else {
            print("No Firebase user logged in")
            completion()
        }

    }
    
    func parseAndSaveFBintoCoreData(plants_FB: [QueryDocumentSnapshot], completion: @escaping () -> Void) {
        
        // MARK: - Parse plants from Firebase to Core Data
    
        for doc in plants_FB {
            
            dispatchGroup.enter()
            print("DDD - enter")
            
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
            let loadedPlant_FB = Plant(context: context)
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
                
                dispatchGroup.enter()
                    print("customPlantImageUUID_FB path: \(customPlantImageUUID_FB!)")
                    
                    let fileRef = Storage.storage().reference(withPath: customPlantImageUUID_FB!)
                    fileRef.getData(maxSize: 5 * 1024 * 1024)  { [weak self] data, error in
                      
                        print("DDD inner 1 - Enter")
                        if error == nil && data != nil {
                            loadedPlant_FB.customPlantImageID = customPlantImageUUID_FB!
                            loadedPlant_FB.imageData = data!
                            print("FB Storage imageData has been retrieved successfully: \(data!)")
                            self?.plants.append(loadedPlant_FB)
                            self?.savePlants()
                            self?.dispatchGroup.leave()
                            print("DDD inner 1 - Leave")

                        } else {
                            print("Error retrieving data from cloud storage. Error: \(String(describing: error))")
                            loadedPlant_FB.customPlantImageID = customPlantImageUUID_FB!
                            loadedPlant_FB.imageData = nil
                            self?.savePlants()
                            self?.dispatchGroup.leave()
                            print("DDD inner 1 - Leave")
                        }
                    }
                
                
            } else {
                
                dispatchGroup.enter()
                print("DDD inner 2 - Enter")
                print("customPlantImage_FB is nil.")
                plants.append(loadedPlant_FB)
                savePlants()
                dispatchGroup.leave()
                print("DDD inner 2 - Leave")

            }
            
            dispatchGroup.leave()
            print("DDD - leave")
    
        }
        
        // Notify dispatchGroup when all work is done.
        dispatchGroup.notify(queue: .main) {
            print("DispatchGroup work done")
            completion()
        }
        

    }
    
    
    func deletePlant_FB(indexPath: IndexPath) {
        
        if authenticateFBUser() {
            
            let db = Firestore.firestore()
            
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
                print("plantDoc edited uuid: \(currentPlantID.uuidString)")
            }
            
            // 7: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                print("Plant successfully updated on Firebase")
            }
            
        }
    }
    
    func reloadImageDataFB(_ completion: @escaping () -> Void) {
        
        for p in plants {
            if p.customPlantImageID != nil && p.imageData == nil {
                //Get data from Firestore
                dispatchGroup.enter()
                
                guard let customPlantImageIDUnwrapped = p.customPlantImageID else { return }
                
                
                let fileRef = Storage.storage().reference(withPath: customPlantImageIDUnwrapped)
                fileRef.getData(maxSize: 5 * 1024 * 1024)  { [weak self] data, error in
                    
                    print("DDD inner 1 - Enter")
                    if error == nil && data != nil {
                        
                        p.imageData = data!
                        print("FB Storage imageData has been retrieved successfully: \(data!)")
                        self?.savePlants()
                        self?.dispatchGroup.leave()
                        print("DDD inner 1 - Leave")
                        
                    } else {
                        print("Error retrieving data from cloud storage. Error: \(String(describing: error))")
                        self?.dispatchGroup.leave()
                        print("DDD inner 1 - Leave")
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("DispatchGroup work done")
            completion()
        }
        
    }
    
    
}

// MARK: - Extension: UNUserNotificationCenter functions
extension MainViewController: UNUserNotificationCenterDelegate {
    
    func updateUserSettings(_ completion: @escaping () -> Void) {
    
        let notificationOn = userSettings["Notification On"] as? Bool ?? nil
        print("notificationOn: \(String(describing: notificationOn))")
        self.defaults.set(notificationOn, forKey: "notificationOn")
        
        // Set setting: Notification Alert Time
        let notificationAlertTime = userSettings["Notification Alert Time"] as? Int ?? nil
        print("notificationAlertTime: \(String(describing: notificationAlertTime))")
        self.defaults.set(notificationAlertTime, forKey: "selectedAlertOption")
        
        if notificationOn != nil && notificationAlertTime != nil {
            completion()
        }
        
    }
    
    @objc func refreshUserNotification() {
        if defaults.bool(forKey: "notificationOn") {
            setupLocalUserNotification(selectedAlert: defaults.integer(forKey: "selectedAlertOption"))
        }
    }
    
    
    func setupLocalUserNotification(selectedAlert: Int) {
        
        center.getNotificationSettings { [self] settings in
            
            // If user already authorized/allowed user notification in the beginning of app, User Notification setup may proceed.
            if settings.authorizationStatus == .authorized {
                
                // First, load plants into plant's context.
                loadPlants { [self] in
                    
                    updateNotificationBadgeCount()
                    center.removeAllPendingNotificationRequests()
                    
                    // For each/every plant, this will create a notification
                    for plant in plants {
                        
                        
                        if let plantUUIDUnwrapped = plant.id {
                            
                            print("Plant notification set: \(String(describing: plant.plant))")
                            
                            // 2: Create the notification content
                            let content = UNMutableNotificationContent()
                            content.title = "Notification alert!"
                            content.body = "Make sure to water your plant: \(plant.plant!)"
                            
                            // NEW METHOD FOR SETTING BADGE COUNT:
                            content.badge = (plant.notificationBadgeCount) as NSNumber
                            content.sound = .default
                            content.categoryIdentifier = "categoryIdentifier"
                            
                            // 3: Create the notification trigger
                            // "5 seconds" added
                            var nextWaterDate: Date {
                                let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: Int(plant.waterHabit), to:  plant.lastWateredDate!)
                                return calculatedDate ?? Date.now
                            }
                            
                            var selectedNotificationTime = Date()
                            switch defaults.integer(forKey: "selectedAlertOption") {
                            case 0: // day of event
                                // For debug purpose: Notification time - 10 seconds
                                //                            selectedNotificationTime = Date.now.advanced(by: 10)
                                
                                // Uncomment below when not debugging:
                                selectedNotificationTime = nextWaterDate.advanced(by: 100)
                                print("Plant: \(String(describing: plant.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                            case 1: // 1 day before
                                selectedNotificationTime = nextWaterDate.advanced(by: -86400 + 50)
                                print("Plant: \(String(describing: plant.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                            case 2: // 2 days before
                                selectedNotificationTime = nextWaterDate.advanced(by: -86400*2)
                                print("Plant: \(String(describing: plant.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                            default: // 3 days before
                                selectedNotificationTime = nextWaterDate.advanced(by: -86400*3)
                                print("Plant: \(String(describing: plant.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                            }
                            
                            
                            let notificationDate = selectedNotificationTime
                            let notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
                            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)
                            
                            // 4: Create the request
                            let uuidString = UUID()
                            plant.notificationRequestID = uuidString.uuidString
                            plant.notificationPending = true
                            print("notificationRequestID: \(uuidString)")
                            let notificationRequest = UNNotificationRequest(identifier: uuidString.uuidString, content: content, trigger: notificationTrigger)
                            
                            // 5: Register the request
                            center.add(notificationRequest) { [self] (error) in
                                // check the error parameter or handle any errors
                                guard error == nil else {
                                    print("NotificationRequest error: \(error.debugDescription)")
                                    return
                                }
                                
                                savePlants()
                                editPlant_FB(plantUUIDUnwrapped, plantEditedData: [
                                    "notificationPending": true,
                                    "notificationRequestID": uuidString.uuidString as Any,
                                    "notificationBadgeCount": plant.notificationBadgeCount
                                ])
                                
                                print("Notification Request successfully added for ID: \(notificationRequest.identifier)")
                            }
                            
                        }
                        
                    }
                    
                    // Set UNNotificationActions
                    let plantNotificationWateredAction = UNNotificationAction(identifier: "plantNotificationWateredActionID", title: "Watered", options: [])
                    let plantNotificationCancelAction = UNNotificationAction(identifier: "plantNotificationCancelActionID", title: "Not yet" , options: [])
                
                    let notificationActionsCategory = UNNotificationCategory(identifier: "categoryIdentifier", actions: [plantNotificationWateredAction, plantNotificationCancelAction], intentIdentifiers: [], options: [.customDismissAction])
                    center.setNotificationCategories([notificationActionsCategory])
                    
                }
                
             
            // Else, if user has yet to allow user notification in the beginning of app, this will request user to choose.
            } else if settings.authorizationStatus == .notDetermined {

                center.delegate = self
                center.requestAuthorization(options: [.alert, .sound, .badge]) { [self] (granted, error) in
                    if granted {
                        // Access granted
                        print("UserNotifcation Granted")
                        loadPlants {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                        }
                    } else {
                        // Access denied
                        print("UserNotification Denied")
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
                
                DispatchQueue.main.async { [self] in
                    activeVC()?.present(alert, animated: true)
                }
            }
            
        }
    
    }
    
    func deleteNotification(indexPath: IndexPath) {
        if defaults.bool(forKey: "notificationOn") {
            
            if let unID = plants[indexPath.row].notificationRequestID {
                center.removePendingNotificationRequests(withIdentifiers: [unID])
                
                if plants[indexPath.row].notificationPresented == true {
                    center.removeDeliveredNotifications(withIdentifiers: [unID])
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
                    }
                }
                
            } else if plants[indexPath.row].notificationPresented == true {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
                }
            }
            
        }
    }
    
    func updateNotificationBadgeCount() {
        
        guard plants.count != 0 else { return }
        
        let sortedPlantsByWatered = plants.sorted {
            $0.lastWateredDate! < $1.lastWateredDate!
        }
       
        
        for i in 0...sortedPlantsByWatered.count - 1 {
            let plant = sortedPlantsByWatered[i]
            plant.notificationBadgeCount = Int16(i + 1)
            savePlants()
        }
        
    }
    
    
    func updateUnpresentedNotification() {
        
        if defaults.bool(forKey: "notificationOn") {
            
            print("updateUnpresentedNotification")
            
            var count = 0
            
            guard plants.count != 0 else { return }
            
            for p in plants {
                
                let waterHabitIn = p.waterHabit
                let lastWateredDateIn = p.lastWateredDate
                var nextWaterDate: Date {
                    let calculatedDate  = Calendar.current.date(byAdding: Calendar.Component.day, value: Int(waterHabitIn), to:  (lastWateredDateIn)!)
                    return calculatedDate!
                }
                
                var selectedNotificationTime = Date()
                switch defaults.integer(forKey: "selectedAlertOption") {
                case 0: // day of event
                    // For debug purpose: Notification time - 10 seconds
                    //                            selectedNotificationTime = Date.now.advanced(by: 10)
                    
                    // Uncomment below when not debugging:
                    selectedNotificationTime = nextWaterDate.advanced(by: 100)
                    //                    print("Plant: \(String(describing: p.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                case 1: // 1 day before
                    selectedNotificationTime = nextWaterDate.advanced(by: -86400 + 50)
                    //                    print("Plant: \(String(describing: p.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                case 2: // 2 days before
                    selectedNotificationTime = nextWaterDate.advanced(by: -86400*2)
                    //                    print("Plant: \(String(describing: p.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                default: // 3 days before
                    selectedNotificationTime = nextWaterDate.advanced(by: -86400*3)
                    //                    print("Plant: \(String(describing: p.plant)), Notification Time: \(selectedNotificationTime.formatted(date: .abbreviated, time: .standard))")
                }
                
                if selectedNotificationTime < Date.now {
                    p.notificationPresented = true
                    count += 1
                    savePlants()
                }
                
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = count
            }
            
        }
        
    }
    
    func passPlantsDataToQRVC() {
        if let tabBarController = self.tabBarController {
          
            if let qrVC = tabBarController.viewControllers?[2] as? QRScannerViewController {
                // Assign the data to ViewController2
                qrVC.plants = plants
                print("DDD: data passed")
            }
            
            if let navigationController = tabBarController.viewControllers?[4] as? UINavigationController,
               let settingsProfileVC = navigationController.topViewController as? SettingsViewController {
                // Assign the data to SettingsViewController
                print("Data passed to SettingsViewController")
                settingsProfileVC.context = context
                settingsProfileVC.plants = plants
                settingsProfileVC.userSettings = userSettings
            }
            
        }
    }
    
}

// MARK: - Additional added Views
extension MainViewController {
    
    func addLoadingSpinner() {
        DispatchQueue.main.async { [self] in
            view.addSubview(loadingSpinnerView)
            loadingSpinnerView.translatesAutoresizingMaskIntoConstraints = false
            loadingSpinnerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            loadingSpinnerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            loadingSpinnerView.style = .large
            loadingSpinnerView.hidesWhenStopped = true
            loadingSpinnerView.startAnimating()
            print("addLoadingView")
        }
    }
    
    func removeLoadingView() {
        DispatchQueue.main.async {
            self.loadingSpinnerView.stopAnimating()
            print("removedLoadingView")
        }
    }
    
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func addCollectionView() {
        
        plantsTableView.removeFromSuperview()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (view.frame.size.width / 3) - 4, height: 150)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 5, y: 150, width: view.frame.size.width - 10, height: view.frame.size.height - 150 - 60)
        if traitCollection.userInterfaceStyle == .light {
            collectionView.backgroundColor = .secondarySystemBackground
        } else {
            collectionView.backgroundColor = .black
        }
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.reloadData()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    
    func removeCollectionView() {
        
        collectionView?.removeFromSuperview()
        
        view.addSubview(plantsTableView)
        plantsTableView.translatesAutoresizingMaskIntoConstraints = false
        plantsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        plantsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        plantsTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        plantsTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("User tapped collection view cell")
        
        // In edit mode, if user taps, alert will be presented to user if they want to delete their cell.
        if editButton.title == "Done" {
            presentDeleteCellConfirmation(self, indexPath: indexPath)
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            collectionView.deselectItem(at: indexPath, animated: true)
            performSegue(withIdentifier: K.mainToPlantID, sender: cell)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        
        cell.plant = plants[indexPath.row]
      
        return cell
    }
    
    func presentDeleteCellConfirmation(_ viewController: UIViewController, indexPath: IndexPath) {
        
        if let plant = plants[indexPath.row].plant {
            
            let alert = UIAlertController(title: "You are about to delete: \(plant)", message: "Are you sure you want to continue?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .default, handler: { _ in
                NSLog("The \"Delete\" alert occured.")
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Default action"), style: .destructive, handler: { [self] _ in
                NSLog("The \"OK\" alert occured.")
                deletePlant(indexPath: indexPath)
                updateOrderNumber_FB()
            }))
           
            viewController.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        guard let collectionView = collectionView else { return }
        guard self.editButton.title == "Done" else { return }
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
        
    }
     
    // Adjust CollectionView cell's width/height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.frame.size.width / 3) - 4, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.plants[sourceIndexPath.row]
        plants.remove(at: sourceIndexPath.row)
        plants.insert(movedObject, at: destinationIndexPath.row)
        
        for (index, item) in plants.enumerated() {
            item.order = Int32(index)
        }
        
        savePlants()
    }
    
}

