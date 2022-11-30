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
    var plantNameIn = ""
    var plantImageStringIn = ""
    var plantImageLoadedIn = UIImage()
    
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
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentPlant: Plant!
    
    
    
    
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
        let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabitIn, to:  lastWateredDateIn.advanced(by: 86400))
        return calculatedDate!
    }
    
    var waterStatus: String {
        
        let dateIntervalFormat = DateComponentsFormatter()
        dateIntervalFormat.allowedUnits = .day
        dateIntervalFormat.unitsStyle = .short
        let formatted = dateIntervalFormat.string(from: currentDate, to: nextWaterDate) ?? ""
        if formatted == "0 days" || nextWaterDate < currentDate {
            currentPlant.wateredBool = false
            return "):"
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
        datePicker.maximumDate = Date.now
        datePicker.timeZone = .current
        datePicker.locale = .current
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        
    }
   
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        lastWateredDateIn = sender.date
        print("Last Watered Date changed to: \(sender.date)")
        updateUI()
        editPlant_FB(currentPlant.id!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // update the layers frame based on the frame of the view.
        // MARK: - UI: Shadow around Watering Habit StackView
        updateGradientContainerView()
        addShadow(wateringHabitStackView)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updatePlant()
        
        // Will reload plants in MainVC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
    }

    // MARK: - IBActions functions
    
    @IBAction func editButtonPressed(_ sender: Any) {

        let editPlantVC = EditPlantViewController()
        editPlantVC.currentPlant = currentPlant
//        editPlantVC.inputImage = plantImageLoadedIn
        let editPlantNavVC = UINavigationController(rootViewController: editPlantVC)
        editPlantNavVC.modalPresentationStyle = .formSheet
        present(editPlantNavVC, animated: true, completion: nil)
        
        editPlantVC.delegate = self
    }
    
    
    @IBAction func waterButtonPressed(_ sender: Any) {
        lastWateredDateIn = currentDate
        datePicker.date = lastWateredDateIn
        currentPlant.wateredBool = true
        updatePlant()
        updateUI()
        editPlant_FB(currentPlant.id!)
        print("Water button pressed.")
    }
    
    
    // MARK: - functions
    func updateGradientContainerView() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor(named: K.customGreenColor)?.cgColor ?? UIColor.green.cgColor]
        gradient.locations = [0.5 , 1.0]
        gradient.frame = containerView.frame
        gradient.cornerRadius = 40
        containerView.layer.insertSublayer(gradient, at: 0)
        containerView.layer.cornerRadius = 40
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
            weatherLogo.image = UIImage(systemName: "questionmark")
            weatherTemp.text = "loading.."
            weatherCity.text = "loading.."
        } else {
            weatherLogo.image = UIImage(systemName: inputLogoIn)
            weatherTemp.text = inputTempIn
            weatherCity.text = inputCityIn
        }
    }
    
    func updateInputImage() {
        
        if imageSetNames.contains(currentPlant.plantImageString!) {
            plantImage.image = UIImage(named: currentPlant.plantImageString!)
        } else {
            plantImage.image = loadedImage(with: currentPlant.imageData)
            plantImage.layer.cornerRadius = 10
        }
        print("plantImageString: \(currentPlant.plantImageString!)")
        print("updateInputImage: triggered")
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
        updateInputImage()
        updatePlant()
    }
    
    func loadData() {
        plantName.text = currentPlant.plant
        waterHabitIn = Int(currentPlant.waterHabit)
        lastWateredDateIn = currentPlant.lastWateredDate!
        
        datePicker.date = lastWateredDateIn
        plantImage.image = plantImageLoadedIn
        waterStatusView.text = waterStatus
    }
    
    func updatePlant() {
        // update currentPlant on Core Data
        currentPlant.lastWateredDate = lastWateredDateIn
        print("Plant: \(currentPlant.plant!) updated." )
 
        do {
            try context.save()
        } catch {
            print("Error updating plant. Error: \(error)")
        }
    }
    
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
                "lastWatered": datePicker.date,
            ]
            
            // 5: FIREBASE: Set doucment name(use index# to later use in core data)
            let plantDoc = plantCollection.document("\(currentPlant.id!.uuidString)")
            print("plantDoc edited uuid: \(currentPlantID.uuidString)")
            
            // 6: Edited data for "Plant entity input"
            plantDoc.updateData(plantEditedData) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
            }
            
            // 7: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
            }
            
            // FIREBASE STORAGE: if customImage is used, upload to cloud storage as well.
//            if customImageData() != nil {
//                // Authenticate Firebase User
//                if authenticateFBUser() {
//                    // Handle Firebase Storage upload
//                    uploadPhotoToFirebase(plantDoc)
//                } else {
//                    print("Firebase: Error saving custom image.")
//                }
//            }
            
            print("Plant successfully edited on Firebase")
        }
    }
    
//    func uploadPhotoToFirebase(_ plantAddedDoc: DocumentReference) {
//        let randomID = UUID.init().uuidString
//        let uploadRef = Storage.storage().reference(withPath: "customSavedPlantImages/\(randomID).jpg")
//
//        guard let imageData = customImageData() else { return }
//        let uploadMetaData = StorageMetadata.init()
//        uploadMetaData.contentType = "image/jpeg"
//
//        uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetadata, error) in
//            if error != nil {
//                K.presentAlert(self, error!)
//            }
//            print("Firebase Storage: putData is complete. Meta Data info: \(String(describing: downloadMetadata))")
//        }
//
//        // customPlantImageUUID: for identifying on cloud storage/Firestore
//        plantAddedDoc.setData(["customPlantImageUUID": randomID], merge: true) { error in
//            if error != nil {
//                print("Firebase Error saving: customPlantImageUUID")
//            }
//        }
//    }
    
}
