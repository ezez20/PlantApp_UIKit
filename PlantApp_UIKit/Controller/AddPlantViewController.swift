//
//  AddPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/1/22.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AddPlantViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var plantName: UITextField!
    
    @IBOutlet weak var wateringLabel: UILabel!
    @IBOutlet weak var textFieldBottomWateringLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var wateringSectionView: UIView!
    @IBOutlet weak var waterHabitButton: UIButton!
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addPlantButton: UIButton!
    
    @IBOutlet weak var plantImageButton: UIButton!
    
    // MARK: - UIViews added
    let suggestionScrollView = UIScrollView()
    let suggestionTableView = UITableView()
    
    let opaqueView = UIView()
    let loadingSpinnerView = UIActivityIndicatorView(style: .large)
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    var filteredSuggestion = [String]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var selectedHabitDay = 7
    
    // ADD: add more plants and images
    let imageSetNames = K.imageSetNames
    private var plantImageString = ""
    private var inputImage: UIImage?
    private var sourceType: UIImagePickerController.SourceType = .camera
    let imagePicker = UIImagePickerController()
    
    
    
    // MARK: - Views load state
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Add Plant"
        plantName.delegate = self
        loadPlants()
        
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
        suggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "suggestionCell")
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.enableDismissKeyboardOnTapOutside()
        
        datePicker.maximumDate = Date.now
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    
    override func viewDidLayoutSubviews() {
        addCornerRadius(textFieldView)
        addCornerRadius(wateringSectionView)
        addCornerRadius(addPlantButton)
        plantImageButton.clipsToBounds = true
        addCornerRadius(plantImageButton)
        
        scrollView.isDirectionalLockEnabled = true
        
        waterHabitButton.configuration?.image = UIImage(systemName: "chevron.right")
        waterHabitButton.configuration?.imagePadding = 5
        waterHabitButton.configuration?.imagePlacement = .trailing
        waterHabitButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
    }
    
    
    
    // MARK: - UI Update Methods
    func addCornerRadius(_ appliedView: UIView) {
        appliedView.layer.cornerRadius = 10
    }
    
    func updateInputImage() {
        if imageSetNames.contains(plantName.text!.lowercased()) && inputImage == nil {
            plantImageButton.setImage(UIImage(named: plantName.text!.lowercased()), for: .normal)
        } else if imageSetNames.contains(plantName.text!) && inputImage != nil {
            plantImageButton.setImage(inputImage, for: .normal)
        } else if inputImage != nil  {
            plantImageButton.setImage(inputImage, for: .normal)
        } else {
            plantImageButton.setImage(UIImage(named: K.unknownPlant), for: .normal)
        }
        print("updateInputImage: triggered")
    }
    
    func customImageData () -> Data? {
        let pickedImage = inputImage?.jpegData(compressionQuality: 0.80)
        return pickedImage
    }
    
    func updateUI() {
        waterHabitButton.setTitle("Water every \(selectedHabitDay.formatted()) days", for: .normal)
    }
    
    
    //MARK: - IBActions Buttons
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    
    @IBAction func waterHabitButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: K.AddPlantToWaterHabitID, sender: self)
    }
    
    // MARK: - Handles DATA between: AddPlantViewController & WaterHabitDaysViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPlantToWaterHabit" {
            let secondVC: WaterHabitDaysViewController = segue.destination as! WaterHabitDaysViewController
            secondVC.selectedHabitDays = selectedHabitDay
            secondVC.delegate = self
        }
    }
    
    
    @IBAction func addPlantButtonPressed(_ sender: Any) {
        
        if authenticateFBUser() {
            
            // MARK: - Adding new plant with Firebase/Core Data
            let newPlantID = UUID()
            addPlant_FB(newPlantID)
            
        } else {
            
            // MARK: - Adding new plant to Core Data
            let newPlant = Plant(context: self.context)
            let newPlantID = UUID()
            newPlant.id = newPlantID
            newPlant.plant = self.plantName.text
            newPlant.waterHabit = Int16(selectedHabitDay)
            newPlant.dateAdded = Date.now
            newPlant.order = Int32(plants.endIndex)
            newPlant.lastWateredDate = datePicker.date
            
            var wateredBool: Bool
            if Date(timeInterval: TimeInterval(selectedHabitDay*86400), since: datePicker.date) < Date.now {
                wateredBool = false
            } else {
                wateredBool = true
            }
            
            newPlant.wateredBool = wateredBool
            
            // Saves "plantImageString" to be used later to retrieve plant set images.
            K.plantImageStringReturn(K.imageSetNames, plantImageString: plantImageString, inputImage: inputImage, newPlant: newPlant)
            
            print("Core data plant uuid: \(newPlantID.uuidString)")
            
            if customImageData() != nil {
                newPlant.imageData = customImageData()
            }
            
            // Saving to Core Data
            self.plants.append(newPlant)
            self.savePlant()
            
            // Tells MainViewController to "loadPlants"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
            
            //ADD: dismiss AddPlantView.
            dismiss(animated: true)
            
            // Debug area
            print("Plant added on \(String(describing: newPlant.dateAdded)): \(self.plantName.text!)")
            print("Plant order: \(newPlant.order)")
        }
        
    }
    
    @IBAction func plantImageButtonTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    //MARK: - Data Manipulation Methods
    func savePlant() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    func loadPlants() {
        let request : NSFetchRequest<Plant> = Plant.fetchRequest()
        
        do {
            //            let request = Plant.fetchRequest() as NSFetchRequest<Plant>
            //            let sort = NSSortDescriptor(key: "order", ascending: false)
            //            request.sortDescriptors = [sort]
            plants = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        print("Plants loaded")
    }
    
}




// MARK: - Extensions
extension AddPlantViewController: PassDataDelegate {
    func passData(Data: Int) {
        selectedHabitDay = Data
        print("User selected day: \(selectedHabitDay)")
    }
    
}

extension AddPlantViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - tableView section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredSuggestion.isEmpty {
            return filteredSuggestion.count
        } else {
            removeSuggestionScrollView()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: K.suggestionCell, for: indexPath)
        if !filteredSuggestion.isEmpty {
            cell.textLabel?.text = filteredSuggestion[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        plantName.text = filteredSuggestion[indexPath.row]
        updateInputImage()
        removeSuggestionScrollView()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        // Updates plantImageButton.Image if textfield contains imageSetNames
        updateInputImage()
        
        // Ensure there is at least one character in textfield. If not, addPlantButton.isEnabled = false.
        let trimmedAndLoweredText = plantName.text?.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard plantName.text!.count >= 1, trimmedAndLoweredText != "" else {
            plantImageString = ""
            addPlantButton.isEnabled = false
            removeSuggestionScrollView()
            print("has no text")
            return
        }
        
        if validateEntry() {
            addPlantButton.isEnabled = true
            textField.clearButtonMode = .whileEditing
        }
        
        func validateEntry() -> Bool {
            if plantName.text!.isEmpty {
                return false
            } else {
                return true
            }
        }
        
        plantImageString = trimmedAndLoweredText!
        print(plantImageString)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        func filterText(_ query: String) {
            
            filteredSuggestion.removeAll()
            
            for plant in imageSetNames {
                
                if plant.lowercased().starts(with: query.lowercased()) {
                    filteredSuggestion.append(plant)
                    showSuggestionScrollView()
                }
                
            }
            
            suggestionTableView.reloadData()
            print(filteredSuggestion)
        }
        
        if let text = textField.text {
            filterText(text + string)
        }
        
        return true
    }
    
    func showSuggestionScrollView() {
        suggestionScrollView.backgroundColor = UIColor.white
        containerView.addSubview(suggestionScrollView)
        addSuggestionTableView()
        
        suggestionScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .leftMargin, relatedBy: .equal, toItem: textFieldView, attribute: .leftMargin, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .rightMargin, relatedBy: .equal, toItem: textFieldView, attribute: .rightMargin, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .topMargin, relatedBy: .equal, toItem: textFieldView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .bottomMargin, relatedBy: .equal, toItem: wateringSectionView, attribute: .top, multiplier: 1.0, constant: 10)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        containerView.updateConstraints()
    }
    
    func removeSuggestionScrollView() {
        suggestionScrollView.removeFromSuperview()
        suggestionTableView.removeFromSuperview()
    }
    
    func addSuggestionTableView() {
        // Setup tableview
        suggestionTableView.backgroundColor = UIColor.white
        containerView.addSubview(suggestionTableView)
        
        suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
        
        suggestionTableView.topAnchor.constraint(equalTo: suggestionScrollView.topAnchor).isActive = true
        suggestionTableView.bottomAnchor.constraint(equalTo: suggestionScrollView.bottomAnchor).isActive = true
        suggestionTableView.leftAnchor.constraint(equalTo: suggestionScrollView.leftAnchor).isActive = true
        suggestionTableView.rightAnchor.constraint(equalTo: suggestionScrollView.rightAnchor).isActive = true
        
    }
    
    func addLoadingView() {
        view.addSubview(opaqueView)
        opaqueView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        opaqueView.translatesAutoresizingMaskIntoConstraints = false
        opaqueView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        opaqueView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        opaqueView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        opaqueView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        opaqueView.addSubview(loadingSpinnerView)
        loadingSpinnerView.color = .white
        loadingSpinnerView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingSpinnerView.centerXAnchor.constraint(equalTo: opaqueView.centerXAnchor).isActive = true
        loadingSpinnerView.centerYAnchor.constraint(equalTo: opaqueView.centerYAnchor).isActive = true
        
        loadingSpinnerView.startAnimating()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeSuggestionScrollView()
        self.view.endEditing(true)
        return false
    }
    
    func enableDismissKeyboardOnTapOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action:    #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
    
    
}

extension AddPlantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            inputImage = image
            plantImageButton.setImage(inputImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension AddPlantViewController {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func addPlant_FB(_ newPlantID: UUID) {
        
        addLoadingView()
        
        let db = Firestore.firestore()
        
        //2: FIREBASE: Get currentUser UID to use as document's ID.
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        let userFireBase = db.collection("users").document(currentUser)
        
        //3: FIREBASE: Declare collection("plants)
        let plantCollection =  userFireBase.collection("plants")
        
        var wateredBool: Bool
        if Date(timeInterval: TimeInterval(selectedHabitDay*86400), since: datePicker.date) < Date.now {
            wateredBool = false
        } else {
            wateredBool = false
        }
        
        
        let plantAddedData = PlantDataModel_FB(
            dateAdded: Date.now,
            plantUUID: newPlantID.uuidString,
            plantName: self.plantName.text!,
            waterHabit: Int16(selectedHabitDay),
            plantOrder: Int32(plants.endIndex),
            lastWatered: datePicker.date,
            plantImageString: K.plantImageStringReturn_FB(K.imageSetNames, plantImageString: plantImageString, inputImage: inputImage),
            wateredBool: wateredBool,
            notificationPending: false
        )
        
        // 5: FIREBASE: Set doucment name(use index# to later use in core data)
        let plantDoc = plantCollection.document("\(newPlantID.uuidString)")
        print("plantDoc added uuid: \(newPlantID.uuidString)")
        
        // 6: Set data for "Plant entity input"
        plantDoc.setData(plantAddedData) { error in
            if error != nil {
                K.presentAlert(self, error!)
            }
        }
        
        // 6: FIREBASE: Set data in Plant/plantAddedDoc - documentID
        plantDoc.setData(["plantDocId": plantDoc.documentID], merge: true) { error in
            if error != nil {
                K.presentAlert(self, error!)
            }
        }
        
        // FIREBASE STORAGE: if customImage is used, upload to cloud storage as well.
        if customImageData() != nil {
            print("customImageData not nil")
            // Handle Firebase Storage upload
            uploadPhotoToFirebase(plantDoc) {
                print("Upload image to FB complete")
                self.loadPlantsFB(newPlantUUID: newPlantID)
            }
        } else {
            print("customImageData is nil")
            self.loadPlantsFB(newPlantUUID: newPlantID)
        }
        
        print("Plant successfully added on Firebase")
    }
    
    func loadPlantsFB(newPlantUUID: UUID) {
        
        //Get currentUser UID to use as document's ID.
        let db = Firestore.firestore()
        let userID_FB = Auth.auth().currentUser!.uid
        
        let currentUserCollection = db.collection("users").document(userID_FB)
        let plantsCollection = currentUserCollection.collection("plants")
        
        // Get all documents/plants and put it in "plants_FB"
        plantsCollection.getDocuments { (snapshot, error) in
            
            if error == nil && snapshot != nil {
                
                var plants_FB = [QueryDocumentSnapshot]()
                plants_FB = snapshot!.documents
                
                var plantDocIDsArray = [String]()
                
                for d in snapshot!.documents {
                    plantDocIDsArray.append(d.documentID)
                }
                
                self.parseAndSaveFBintoCoreData(plants_FB: plants_FB, newPlantUUID: newPlantUUID) {
                    print("Data has been parsed to Core Data")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                    self.dismiss(animated: true)
                }
                
            } else {
                print("Error getting documents from plant collection from firebase")
            }
            
        }
        
    }
    
    func parseAndSaveFBintoCoreData(plants_FB: [QueryDocumentSnapshot], newPlantUUID: UUID, completion: @escaping () -> Void) {
        // MARK: - Parse "plant being added" from Firebase to Core Data
        for doc in plants_FB {
            
            let data = doc.data()
            
            if let plantID = doc["plantUUID"] {
                
                let plantUUIDCasted = UUID(uuidString: plantID as? String ?? "")
                
                if plantUUIDCasted == newPlantUUID {
                    
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
                    
                    //notificationPending
                    let notificationPending_FB = data["notificationPending"] as? Bool ?? false
                    print("notificationPending_FB: \(notificationPending_FB)")
                    
                    let loadedPlant_FB = Plant(context: self.context)
                    loadedPlant_FB.id = plantUUID_FBCasted
                    loadedPlant_FB.plant = plantName_FB
                    loadedPlant_FB.waterHabit = Int16(waterHabit_FB)
                    loadedPlant_FB.dateAdded = dateAdded_FB
                    loadedPlant_FB.order = Int32(plantOrder_FB)
                    loadedPlant_FB.lastWateredDate = lastWatered_FB
                    loadedPlant_FB.plantImageString = plantImageString_FB
                    loadedPlant_FB.wateredBool = wateredBool_FB
                    loadedPlant_FB.notificationPending = notificationPending_FB
                    
                    // Retrieve "customPlantImage" data from FB Storage.
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
                                self.savePlant()
                                completion()
                            } else {
                                print("Error retrieving data from cloud storage. Error: \(String(describing: error))")
                            }
                        }
                     
                        
                        
                    } else {
                        print("customPlantImage_FB is nil.")
                        self.plants.append(loadedPlant_FB)
                        self.savePlant()
                        completion()
                    }
                }
            }
        }
        print("Data from FB has been successfully parse'd into Core Data. Core Data count: \(plants.count)")
    }
    
    
    func uploadPhotoToFirebase(_ plantAddedDoc: DocumentReference, completion: @escaping () -> Void) {
        let randomID = UUID.init().uuidString
        let path = "customSavedPlantImages/\(randomID).jpg"
        let uploadRef = Storage.storage().reference(withPath: path)
        
        guard let imageData = customImageData() else { return }
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpeg"
        
        
        uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetadata, error) in
            
            if error != nil {
                K.presentAlert(self, error!)
            }
            
            // customPlantImageUUID: for identifying on cloud storage/Firestore
            plantAddedDoc.setData(["customPlantImageUUID": path], merge: true) { error in
                if error != nil {
                    print("Firebase Error setting data for - customPlantImageUUID. Error: \(String(describing: error))")
                }
            }
            
            print("Firebase Storage: putData is complete. Meta Data info: \(String(describing: downloadMetadata))")
            completion()
            
        }
    }
    
}
