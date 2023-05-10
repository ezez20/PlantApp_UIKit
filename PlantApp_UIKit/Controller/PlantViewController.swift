//
//  PlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/21/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class PlantViewController: UIViewController {
    
    // MARK: - Plant displayed variables
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantHappinessLevel: UILabel!
    
    // MARK: - Weather variables
    @IBOutlet weak var weatherLogo: UIImageView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherCity: UILabel!
    var inputLogoIn = ""
    var inputTempIn = ""
    var inputCityIn = ""
    
    // MARK: - Current Date Displayed Variable
    @IBOutlet weak var currentDateDisplayed: UILabel!
    @IBOutlet weak var weatherDateStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    // MARK: - waterButton variable
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var dropCircleImage: UIImageView!
    
    // MARK: - Watering Habit variable
    @IBOutlet weak var wateringHabitStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var waterStatusView: UILabel!
    
    var waterHabitIn = 7
    var lastWateredDateIn = Date()
   
    // TO DO: add more plants and images
    var currentDate = Date.now
    let imageSetNames = K.imageSetNames
    
    // MARK: - Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    var currentPlant: Plant!
    weak var currentPlant: Plant?
    
    let defaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()

    deinit {
        print("PlantVC has been deinitialized")
    }
    
// MARK: - VARIABLES: happinessLevelFormatted, nextWaterDate, waterStatus, dateFormatter
    var happinessLevelFormatted: Int {
        var happiness = 80.0
        
        if lastWateredDateIn != currentDate {
            if nextWaterDate < currentDate {
                happiness = 0
            } else {
                let happinessLevelCalc = ((Double(DateInterval(start: currentDate, end: nextWaterDate).duration))) / ((Double(DateInterval(start: lastWateredDateIn, end: nextWaterDate).duration))) * 100
                happiness = Double(happinessLevelCalc)
            }
        } else if lastWateredDateIn == currentDate {
            happiness = 100
        }
        return Int(happiness)
    }
    
    var nextWaterDate: Date {
        var date = Date()
        if let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabitIn, to:  lastWateredDateIn) {
            date = calculatedDate
        }
        return date
    }
    
    var waterStatus: String {
        
        let dateIntervalFormat = DateComponentsFormatter()
        dateIntervalFormat.allowedUnits = .day
        dateIntervalFormat.unitsStyle = .short
        let formatted = dateIntervalFormat.string(from: currentDate, to: nextWaterDate) ?? ""
        if formatted == "0 days" || nextWaterDate < currentDate {
            return "today"
        } else if dateFormatter.string(from:  lastWateredDateIn) == dateFormatter.string(from: currentDate) {
            return "Water in \(waterHabitIn) days"
        } else {
            return "Water in: \(formatted)"
        }
        
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
// MARK: - Views load state
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWeatherUI()
        loadData()
        updateUI()
        
        currentDateDisplayed.text = currentDate.formatted(date: .abbreviated, time: .omitted
        )
        // Configure datePicker
        datePicker.maximumDate = Date.now
        datePicker.timeZone = .current
        datePicker.locale = .current
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBadgeAndNotification), name: NSNotification.Name("refreshBadgeAndNotification"), object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // update the layers frame based on the frame of the view.
        
        // MARK: - UI: Shadow around Watering Habit StackView
        addShadow(wateringHabitStackView)
        
        // Update GradientContainerView between light/dark appearance.
        if traitCollection.userInterfaceStyle == .light {
            removeGradientContainerView()
            updateGradientContainerView(lightMode: true)
        } else {
            removeGradientContainerView()
            updateGradientContainerView(lightMode: false)
        }
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("notificationPending: \(String(describing: currentPlant?.notificationPending))")
        print("notificationPresented: \(String(describing: currentPlant?.notificationPresented))")
        print("Badge count: \(String(describing: defaults.value(forKey: "NotificationBadgeCount")))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("reloadPlantsTableViewTriggered"), object: nil)
    }
    

    // MARK: - IBActions functions
    @IBAction func editButtonPressed(_ sender: Any) {

        let editPlantVC = EditPlantViewController()
        editPlantVC.currentPlant = currentPlant
        let editPlantNavVC = UINavigationController(rootViewController: editPlantVC)
        editPlantNavVC.modalPresentationStyle = .formSheet
        present(editPlantNavVC, animated: true, completion: nil)
        
        editPlantVC.delegate = self
    }
    
    
    @IBAction func waterButtonPressed(_ sender: Any) {
        lastWateredDateIn = currentDate
        datePicker.date = lastWateredDateIn
        refreshBadgeAndNotification()
        savePlant()
        updateUI()
        editPlant_FB(currentPlant?.id)
        
        print("Water button pressed.")
    }

    // MARK: - objc functions
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        
        lastWateredDateIn = sender.date
        print("Last Watered Date changed to: \(sender.date.formatted(date: .abbreviated, time: .standard))")
        updateUI()
        refreshBadgeAndNotification()
        savePlant()
        editPlant_FB(currentPlant?.id!)
    
    }
    
    
    // MARK: - functions
    func updateGradientContainerView(lightMode: Bool) {
        if lightMode == true {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [UIColor(named: "customSkyBlue")?.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor(named: K.customGreenColor)?.cgColor ?? UIColor.green.cgColor]
            gradient.locations = [0.0 ,0.3, 0.5 , 1.0]
            gradient.frame = containerView.frame
            containerView.clipsToBounds = true
            containerView.layer.insertSublayer(gradient, at: 0)
            containerView.layer.cornerRadius = 40
            containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [UIColor(named: "customSkyBlue")?.cgColor, UIColor.black.cgColor, UIColor(named: "customSkylight")?.cgColor ,UIColor(named: K.customGreen2)?.cgColor ?? UIColor.green.cgColor]
            gradient.locations = [0.0, 0.3, 0.5, 1.0]
            gradient.frame = containerView.frame
            containerView.layer.insertSublayer(gradient, at: 0)
            containerView.layer.cornerRadius = 40
            containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] 
        }
    }
    
    func removeGradientContainerView() {
        containerView.layer.sublayers?.removeFirst()
    }
    
    func addShadow(_ appliedView: UIStackView) {
        appliedView.layer.shadowColor = UIColor.black.cgColor
        appliedView.layer.shadowOpacity = 0.5
        appliedView.layer.shadowRadius = 5
        appliedView.layer.shadowOffset = CGSize(width: 0, height: 0)
        appliedView.layer.cornerRadius = 10
    }
    
    func updateWeatherUI() {
        if inputLogoIn   == "" {
            weatherLogo.image = UIImage(systemName: "")
            weatherTemp.text = "n/a"
            weatherCity.text = "n/a"
        } else {
            weatherLogo.image = UIImage(systemName: inputLogoIn) ?? UIImage(systemName: "")
            weatherTemp.text = inputTempIn
            weatherCity.text = inputCityIn
        }
    }
    
    
    func loadedImage(with imageData: Data?) -> UIImage {
        guard let imageData = imageData else {
            print("loaded image = unknown")
            return UIImage(named: K.unknownPlant)!
            
        }
        let loadedImage = UIImage(data: imageData)
        return loadedImage!
    }
    
    func updateUI() {
        plantHappinessLevel.text = "\(String(happinessLevelFormatted))%"
        waterStatusView.text = waterStatus
    }
    
    func loadData() {
        plantName.text = currentPlant?.plant
        waterHabitIn = Int(currentPlant!.waterHabit)
        lastWateredDateIn = (currentPlant?.lastWateredDate!)!
        
        datePicker.date = lastWateredDateIn
        
        if imageSetNames.contains(currentPlant!.plantImageString!) {
            plantImage.image = UIImage(named: currentPlant!.plantImageString!)
        } else {
            plantImage.image = loadedImage(with: currentPlant?.imageData)
        }

        waterStatusView.text = waterStatus
    }
    
    func savePlant() {
        // update currentPlant on Core Data
        currentPlant!.lastWateredDate = lastWateredDateIn
        print("Plant: \(String(describing: currentPlant!.plant)) updated." )
 
        do {
            try context.save()
        } catch {
            print("Error updating plant. Error: \(error)")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
    }
    

}


extension PlantViewController: ModalViewControllerDelegate {
    
    func modalControllerWillDisapear(_ modal: EditPlantViewController) {
            // This is called when your modal will disappear. You can reload your data.
            print("reload")
            loadData()
            updateUI()
        }
    
}


extension PlantViewController {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func editPlant_FB(_ currentPlantID: UUID?) {
        if authenticateFBUser() {
            
            guard let currentPlantIDString = currentPlantID?.uuidString else { return }
            
            let db = Firestore.firestore()
            
            //2: FIREBASE: Get currentUser UID to use as document's ID.
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            
            let userFireBase = db.collection("users").document(currentUser)
            
            //3: FIREBASE: Declare collection("plants)
            let plantCollection =  userFireBase.collection("plants")
            
            
            //4: FIREBASE: Plant entity input
            let plantEditedData: [String: Any] = [
                "lastWatered": datePicker.date
//                "wateredBool": wateredBool,
            ]
            
            // 5: FIREBASE: Set doucment name(use index# to later use in core data)
            let plantDoc = plantCollection.document("\(currentPlantIDString)")
            print("plantDoc edited uuid: \(currentPlantIDString)")
            
            // 6: Edited data for "Plant entity input"
            plantDoc.updateData(plantEditedData) { error in
                if error != nil {
                    print("FB Update Data error. Error: \(String(describing: error))")
                }
            }
            
            // 7: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    print("FB error setting data. Error: \(String(describing: error))")
                }
            }
            
            print("Plant successfully edited on Firebase")
        }
    }
    
    @objc func refreshBadgeAndNotification() {
        
        if defaults.bool(forKey: "notificationOn") {
            
            // 1: If notification is already presented for this plant
            if currentPlant!.notificationPresented == true {
                
                // MARK: - OPTION 1, when PLANT'S USER NOTIFICATION IS ALREADY PRESENTED
                
                // 2: And if notification request was made for this plant
                if let notificationToRemoveID = currentPlant!.notificationRequestID {
                   
                    // 3: Get the deliveredNotificationsStored from User Defaults
                    let deliveredNotifications = defaults.object(forKey: "deliveredNotificationsStored") as? [String] ?? []
                    
                    // 4: If deliveredNotificationsStored array is not empty, print.
                    if !deliveredNotifications.isEmpty {
                        print("deliveredNotificationsStored: \(deliveredNotifications)")
                    }
                    
                    // 5: If deliveredNotificationsStored array contains this plant's notification ID, remove the delivered notification.
                    if deliveredNotifications.contains(notificationToRemoveID) {
                        
                        center.removeDeliveredNotifications(withIdentifiers: [notificationToRemoveID])
                        print("Pending Notification removed: \(notificationToRemoveID)")
                        
                        
                    }
                    
                    // 6: Then, update the badge count by subtracting 1.
                    DispatchQueue.main.async {
                        let count = UIApplication.shared.applicationIconBadgeNumber - 1
                        
                        var safeCount = 0
                        if count < 0 {
                            safeCount = 0
                        } else {
                            safeCount = count
                        }
                        UIApplication.shared.applicationIconBadgeNumber = safeCount
                    }
                    
                    // 7: Lastly, update plant's notificationPresented to false, so it can be setup for notification again. Save context, then RefreshUserNotification.
                    currentPlant!.notificationPresented = false
                    savePlant()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                
                // MARK: - OPTION 2, when PLANT NEVER HAD A NOTIFICATION REQUEST SETUP because it had a water time passed its water date.
                } else {
                    DispatchQueue.main.async {
                        let count = UIApplication.shared.applicationIconBadgeNumber - 1
                        
                        var safeCount = 0
                        if count < 0 {
                            safeCount = 0
                        } else {
                            safeCount = count
                        }
                        UIApplication.shared.applicationIconBadgeNumber = safeCount
                    }
                    
                    currentPlant!.notificationPresented = false
                    savePlant()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                }
            
            }
            
            // If notification is pending, remove pending notification and refreshUserNotification.
            // For cases while notification was already created previously: user water plant early. user changes water date/water habit.
            var pendingNotifications = [String]()
            center.getPendingNotificationRequests { [self] unNotification in
                guard let notificationToRemoveID = currentPlant!.notificationRequestID else {
                   
                    return
                }
                
                for pendingNoti in unNotification {
                    pendingNotifications.append(pendingNoti.identifier)
                    print("Pending Notifications list:\(pendingNotifications)")
                }
                
                
                if pendingNotifications.contains(notificationToRemoveID) {
                    
                    center.removePendingNotificationRequests(withIdentifiers: [notificationToRemoveID])
                    currentPlant!.notificationPresented = false
                    print("Pending Notification Removed: \(notificationToRemoveID)")
                    savePlant()
        
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                    
                }
            }
            
        }
        
    }
    
    
}
