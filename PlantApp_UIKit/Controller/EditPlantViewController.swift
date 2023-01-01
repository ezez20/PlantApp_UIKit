//
//  EditPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/23/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class EditPlantViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    
    let navController = UINavigationController()
    let navigationBar = UINavigationBar()
    
    let plantTextFieldView = UIView()
    let plantTextField = UITextField()
    
    let wateringLabel = UILabel()
    
    let wateringSectionView = UIView()
    let waterHabitLabel = UILabel()
    let waterHabitButton = UIButton()
    
    let dividerView = UIView()
    
    let lastWateredLabel = UILabel()
    let datePicker = UIDatePicker()
    
    let updatePlantButton = UIButton()
    
    let plantImageButton = UIButton()
    let imageSetNames = K.imageSetNames
    var filteredSuggestion = [String]()
  
    // MARK: - Variables
    var inputImage: UIImage?
    let imagePicker = UIImagePickerController()
    private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // MARK: - Addidional UIViews added
    let suggestionScrollView = UIScrollView()
    let suggestionTableView = UITableView()
    let opaqueView = UIView()
    let loadingSpinnerView = UIActivityIndicatorView(style: .large)
    
    private var plantImageString = ""
    private var selectedHabitDay = 7
    
    // MARK: - Delegates
    var delegate: ModalViewControllerDelegate?
    
    
    // MARK: - Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentPlant: Plant!
    
    
    override func viewWillAppear(_ animated: Bool) {
    
        print("View will appear")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonPressed))
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.modalControllerWillDisapear(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Edit Plant"
        self.enableDismissKeyboardOnTapOutside()
        
        loadPlant()
        updateInputImage()
        
        view.backgroundColor = .secondarySystemBackground
        // Do any additional setup after loading the view.
        
        // scrollView
        addView(viewIn: scrollView, addSubTo: view, top: view.topAnchor, topConst: 108, bottom: view.bottomAnchor, bottomConst: 0, left: view.leftAnchor, leftConst: 0, right: view.rightAnchor, rightConst: 0)
        
        scrollView.backgroundColor = .secondarySystemBackground
        scrollView.isDirectionalLockEnabled = true
        
        // containerView
        addView(viewIn: containerView, addSubTo: view, top: scrollView.topAnchor, topConst: 0, bottom: scrollView.bottomAnchor, bottomConst: 500, left: scrollView.leftAnchor, leftConst: 0, right: scrollView.rightAnchor, rightConst: 0)
        
        // plantTextFieldView
        containerView.addSubview(plantTextFieldView)
        plantTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        plantTextFieldView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        plantTextFieldView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        plantTextFieldView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        plantTextFieldView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        plantTextFieldView.backgroundColor = .white
        
        
        // plantTextField
        addView(viewIn: plantTextField, addSubTo: plantTextFieldView, top: plantTextFieldView.topAnchor, topConst: 5, bottom: plantTextFieldView.bottomAnchor, bottomConst: -5, left: plantTextFieldView.leftAnchor, leftConst: 20, right: plantTextFieldView.rightAnchor, rightConst: -20)
        
        plantTextField.backgroundColor = .white
        plantTextField.placeholder = "Type of plant"
        
        
        // wateringLabel
        containerView.addSubview(wateringLabel)
        wateringLabel.translatesAutoresizingMaskIntoConstraints = false
        wateringLabel.topAnchor.constraint(equalTo: plantTextFieldView.bottomAnchor, constant: 10).isActive = true
        wateringLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        wateringLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
        wateringLabel.text = "WATERING"
        wateringLabel.textColor = .darkGray
        wateringLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        
        // wateringSectionView
        containerView.addSubview(wateringSectionView)
        wateringSectionView.translatesAutoresizingMaskIntoConstraints = false
        wateringSectionView.topAnchor.constraint(equalTo: wateringLabel.bottomAnchor, constant: 10).isActive = true
        wateringSectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        wateringSectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        wateringSectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        wateringSectionView.backgroundColor = .white
        wateringSectionView.clipsToBounds = true
        
        
        // updatePlantButton
        containerView.addSubview(updatePlantButton)
        updatePlantButton.translatesAutoresizingMaskIntoConstraints = false
        updatePlantButton.topAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: 20).isActive = true
        updatePlantButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        updatePlantButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        updatePlantButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        updatePlantButton.addTarget(self, action: #selector(updatePlantButtonClicked(sender:)), for: .touchUpInside)
        updatePlantButton.setTitle("Update Plant", for: .normal)
        updatePlantButton.setTitleColor(.systemBlue, for: .normal)
        updatePlantButton.setTitleColor(.placeholderText, for: .disabled)
        updatePlantButton.backgroundColor = .white
        
        
        // inputImageButton
        containerView.addSubview(plantImageButton)
        plantImageButton.translatesAutoresizingMaskIntoConstraints = false
        plantImageButton.topAnchor.constraint(equalTo: updatePlantButton.bottomAnchor, constant: 20).isActive = true
        plantImageButton.heightAnchor.constraint(equalToConstant: 350).isActive = true
        plantImageButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        plantImageButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        plantImageButton.backgroundColor = .white
        plantImageButton.clipsToBounds = true
        
        
        plantImageButton.addTarget(self, action: #selector(plantImageButtonPressed), for: .touchUpInside)
        
        plantTextField.delegate = self
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
        suggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: K.suggestionCell)
        
        print("View did load")
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        plantTextFieldView.layer.cornerRadius = 10
        wateringSectionView.layer.cornerRadius = 10
        updatePlantButton.layer.cornerRadius = 10
        plantImageButton.layer.cornerRadius = 10
        
        
        // waterHabitButton
        wateringSectionView.addSubview(waterHabitButton)
        waterHabitButton.translatesAutoresizingMaskIntoConstraints = false
        waterHabitButton.topAnchor.constraint(equalTo: wateringSectionView.topAnchor, constant: 0).isActive = true
        waterHabitButton.bottomAnchor.constraint(equalTo: wateringSectionView.centerYAnchor, constant: 0).isActive = true
        waterHabitButton.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 0).isActive = true
        waterHabitButton.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: 0).isActive = true
        
        // Temporary Soluton: to add padding for button.
        //NOTE: 'contentEdgeInsets' was deprecated in iOS 15.0: This property is ignored when using UIButtonConfiguration
//        waterHabitButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
   
        waterHabitButton.configuration?.imagePlacement = .trailing
        waterHabitButton.setTitleColor(.placeholderText, for: .normal)
        waterHabitButton.contentHorizontalAlignment = .trailing
        waterHabitButton.backgroundColor = .white
        waterHabitButton.addTarget(self, action: #selector(waterHabitButtonClicked(sender:)), for: .touchUpInside)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.right")
        config.contentInsets = NSDirectionalEdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)
        config.imagePlacement = .trailing
        waterHabitButton.configuration = config
        waterHabitButton.tintColor = .placeholderText
        updateWaterButtonSelectionUI()
        
        // waterHabit label
        wateringSectionView.addSubview(waterHabitLabel)
        waterHabitLabel.translatesAutoresizingMaskIntoConstraints = false
        waterHabitLabel.topAnchor.constraint(equalTo: waterHabitButton.topAnchor, constant: 0).isActive = true
        waterHabitLabel.bottomAnchor.constraint(equalTo: waterHabitButton.bottomAnchor, constant: 0).isActive = true
        waterHabitLabel.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 20).isActive = true
        
        waterHabitLabel.text = "Water Habit:"
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: NSNotification.Name("habitDaysNotification"), object: nil)
        
        // dividerView
        dividerView.frame = CGRect(x: 10, y: wateringSectionView.frame.height/2, width: wateringSectionView.frame.width - 20, height: 1.0)
        dividerView.layer.borderWidth = 1.0
        dividerView.layer.borderColor = UIColor.placeholderText.cgColor
        wateringSectionView.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constraint(equalTo: wateringSectionView.topAnchor, constant: 49).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: -wateringSectionView.frame.height/2).isActive = true
        dividerView.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 5).isActive = true
        dividerView.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: -5).isActive = true
        
        // lastWateredLabel
        wateringSectionView.addSubview(lastWateredLabel)
        lastWateredLabel.translatesAutoresizingMaskIntoConstraints = false
        lastWateredLabel.topAnchor.constraint(equalTo: wateringSectionView.centerYAnchor, constant: 0).isActive = true
        lastWateredLabel.bottomAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: 0).isActive = true
        lastWateredLabel.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 20).isActive = true
        
        lastWateredLabel.backgroundColor = .white
        lastWateredLabel.text = "Last watered:"
        
        // datePicker
        wateringSectionView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 0).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: 0).isActive = true
        datePicker.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: -20).isActive = true
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        print("View did layout subviews")
    }
    
    
    // MARK: - Custom addView func template
    func addView(viewIn: UIView, addSubTo: UIView, top: NSLayoutAnchor<NSLayoutYAxisAnchor>, topConst: Double, bottom: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomConst: Double, left: NSLayoutAnchor<NSLayoutXAxisAnchor>, leftConst: Double, right: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightConst: Double) {
        
        addSubTo.addSubview(viewIn)
        
        viewIn.translatesAutoresizingMaskIntoConstraints = false
        
        viewIn.topAnchor.constraint(equalTo: top, constant: topConst).isActive = true
        viewIn.bottomAnchor.constraint(equalTo: bottom, constant: bottomConst).isActive = true
        viewIn.leftAnchor.constraint(equalTo: left, constant: leftConst).isActive = true
        viewIn.rightAnchor.constraint(equalTo: right, constant: rightConst).isActive = true
    }
    
    // MARK: - functions/objc funcs
    
    @objc func waterHabitButtonClicked(sender: UIButton) {
        // Add segue to WaterHabitDaysViewController
        print("Water Habit button clicked")
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "waterHabitStoryboardID")  as! WaterHabitDaysViewController
        resultVC.selectedHabitDays = selectedHabitDay
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
    
    
    @objc func updatePlantButtonClicked(sender: UIButton) {
        
        if authenticateFBUser() {
            // MARK: - Editing new plant with Firebase/Core Data
            editPlant_FB(currentPlant.id!)
        } else {
            // MARK: - Adding new plant to Core Data
            currentPlant.plant = plantTextField.text
            currentPlant.waterHabit = Int16(selectedHabitDay)
            currentPlant.dateAdded = Date.now
            currentPlant.lastWateredDate = datePicker.date
            
            K.plantImageStringReturn(K.imageSetNames, plantImageString: plantImageString, inputImage: inputImage, newPlant: currentPlant)
            
            if customImageData() != nil {
                currentPlant.imageData = customImageData()
            }
            
            self.savePlant()
            dismiss(animated: true)
            
        }
        
        print("Update Plant button clicked")
        
    }
    
    @objc func cameraButtonPressed(sender: UIBarButtonItem) {
        print("camera button pressed")
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @objc func plantImageButtonPressed() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc func onNotification(notification: Notification) {
        let data = notification.object
        selectedHabitDay = data as! Int
        
    }
    
    func updateWaterButtonSelectionUI() {
        waterHabitButton.setTitle("Water every \(selectedHabitDay.formatted()) days", for: .normal)
        print("WaterButton title updated to: \(selectedHabitDay)")
    }
    
    
    func loadPlant() {
        plantTextField.text = currentPlant.plant
        selectedHabitDay = Int(currentPlant.waterHabit)
        datePicker.date = currentPlant.lastWateredDate!
        plantImageString = currentPlant.plantImageString!
    }
    
    //MARK: - Data Manipulation Methods
    func savePlant() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    func updateInputImage() {
        
        // loads currentPlant's image if imageData has data.
        if currentPlant.imageData != nil {
            plantImageButton.setImage(loadedImage(with: currentPlant.imageData), for: .normal)
        } else if imageSetNames.contains(plantTextField.text!.lowercased()) && inputImage == nil {
            plantImageButton.setImage(UIImage(named: plantTextField.text!.lowercased()), for: .normal)
        } else if imageSetNames.contains(plantTextField.text!) && inputImage != nil {
            plantImageButton.setImage(loadedImage(with: currentPlant.imageData), for: .normal)
        } else if inputImage != nil  {
            plantImageButton.setImage(inputImage, for: .normal)
        } else {
            plantImageButton.setImage(UIImage(named: K.unknownPlant), for: .normal)
        }
    }
    
    func customImageData() -> Data? {
        let pickedImage = inputImage?.jpegData(compressionQuality: 0.80)
        return pickedImage
    }
    
    func loadedImage(with imageData: Data?) -> UIImage {
        guard let imageData = imageData else {
            return UIImage(named: K.unknownPlant)!
        }
        let loadedImage = UIImage(data: imageData)
        return loadedImage!
    }
    
}


protocol ModalViewControllerDelegate {
    func modalControllerWillDisapear(_ modal: EditPlantViewController)
}


// MARK: - extensions
extension EditPlantViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    
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
        let cell  = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath)
        if !filteredSuggestion.isEmpty {
            cell.textLabel?.text = filteredSuggestion[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        plantTextField.text = filteredSuggestion[indexPath.row]
        removeSuggestionScrollView()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        // Updates plantImageButton.Image if textfield contains imageSetNames
        updateInputImage()
        
        // Ensure there is at least one character in textfield. If not, addPlantButton.isEnabled = false.
        let trimmedAndLoweredText = plantTextField.text?.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard plantTextField.text!.count >= 1, trimmedAndLoweredText != "" else {
            plantImageString = ""
            updatePlantButton.isEnabled = false
            removeSuggestionScrollView()
            print("has no text")
            return
        }
        
        if validateEntry() {
            updatePlantButton.isEnabled = true
        }
        
        if validateEntry() == false {
            inputImage = nil
        }
        
        func validateEntry() -> Bool {
            if plantTextField.text!.isEmpty {
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
        
        let leftConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .leftMargin, relatedBy: .equal, toItem: plantTextFieldView, attribute: .leftMargin, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .rightMargin, relatedBy: .equal, toItem: plantTextFieldView, attribute: .rightMargin, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .topMargin, relatedBy: .equal, toItem: plantTextFieldView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .bottomMargin, relatedBy: .equal, toItem: wateringSectionView, attribute: .top, multiplier: 1.0, constant: 10)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        containerView.updateConstraints()
        
        print("showSuggestionScrollView ran")
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

extension EditPlantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditPlantViewController {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func editPlant_FB(_ currentPlantID: UUID) {
        addLoadingView()
        
        if authenticateFBUser() {
            let db = Firestore.firestore()
            
            //2: FIREBASE: Get currentUser UID to use as document's ID.
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            
            let userFireBase = db.collection("users").document(currentUser)
            
            //3: FIREBASE: Declare collection("plants)
            let plantCollection =  userFireBase.collection("plants")
            
            //4: FIREBASE: Plant entity input
            let plantEditedData: [String: Any] = [
                "dateAdded": Date.now,
                "plantUUID": currentPlantID.uuidString,
                "plantName": plantTextField.text!,
                "waterHabit": Int16(selectedHabitDay),
                "lastWatered": datePicker.date,
                "plantImageString": K.plantImageStringReturn_FB(K.imageSetNames, plantImageString: plantImageString, inputImage: inputImage)
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
            
            // FIREBASE STORAGE: if customImage is used, update photo on cloud storage as well.
            if customImageData() != nil {
                // Handle Firebase Storage upload/update
                updatePhotoOnFirebase(plantDoc) {
                    print("Update photo on Firebase/Storage completed.")
                    self.loadPlantsFB(currentPlantUUID: currentPlantID)
                }
            } else {
                self.loadPlantsFB(currentPlantUUID: currentPlantID)
            }
            
            print("Plant successfully edited on Firebase")
        }
    }
    
    func loadPlantsFB(currentPlantUUID: UUID) {
        
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
                
                self.parseAndSaveFBintoCoreData(plants_FB: plants_FB, currentPlantUUID: currentPlantUUID) {
                    print("Data has been parsed to Core Data")
                    self.savePlant()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
                    self.dismiss(animated: true)
                }
                
            } else {
                print("Error getting documents from plant collection from firebase")
            }
            
        }
        
    }
    
    func parseAndSaveFBintoCoreData(plants_FB: [QueryDocumentSnapshot], currentPlantUUID: UUID, completion: @escaping () -> Void) {
        // MARK: - Parse "plant being added" from Firebase to Core Data
        for doc in plants_FB {
            
            let data = doc.data()
            
            if let plantID = doc["plantUUID"] {
                
                let plantUUIDCasted = UUID(uuidString: plantID as? String ?? "")
                
                if plantUUIDCasted == currentPlantUUID {
                    
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
                    
                    //                    let loadedPlant_FB = Plant(context: self.context)
                    
                    currentPlant.id = plantUUID_FBCasted
                    currentPlant.plant = plantName_FB
                    currentPlant.waterHabit = Int16(waterHabit_FB)
                    currentPlant.dateAdded = dateAdded_FB
                    currentPlant.order = Int32(plantOrder_FB)
                    currentPlant.lastWateredDate = lastWatered_FB
                    currentPlant.plantImageString = plantImageString_FB
                    
                    // Retrieve "customPlantImage" data from FB Storage.
                    let customPlantImageUUID_FB = data["customPlantImageUUID"] as? String
                    
                    if customPlantImageUUID_FB != nil {
                        
                        print("customPlantImageUUID_FB path: \(customPlantImageUUID_FB!)")
                        
                        let fileRef = Storage.storage().reference(withPath: customPlantImageUUID_FB!)
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if error == nil && data != nil {
                                self.currentPlant.customPlantImageID = customPlantImageUUID_FB!
                                self.currentPlant.imageData = data!
                                print("FB Storage imageData has been retrieved successfully: \(data!)")
                                completion()
                            } else {
                                print("Error retrieving data from cloud storage. Error: \(String(describing: error))")
                            }
                        }
                        
                    } else {
                        print("customPlantImage_FB is nil.")
                        completion()
                    }
                }
            }
        }
    }
    
    func updatePhotoOnFirebase(_ plantDoc: DocumentReference, completion: @escaping () -> Void) {
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
            plantDoc.updateData(["customPlantImageUUID": path]) { error in
                if error != nil {
                    K.presentAlert(self, error!)
                }
            }
            
            print("Firebase Storage: putData is complete. Meta Data info: \(String(describing: downloadMetadata))")
            completion()
            
        }
    }
    
}
