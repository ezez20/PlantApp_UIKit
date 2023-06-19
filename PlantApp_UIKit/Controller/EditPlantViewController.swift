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
import Network
import CoreImage
import CoreImage.CIFilterBuiltins

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
    
    let networkMonitor = NWPathMonitor()
    
    deinit {
        networkMonitor.cancel()
        print("EditPlantVC has been deinitialized")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("View will appear")
        
        imagePicker.delegate = self
        plantImageButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.modalControllerWillDisapear(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableDismissKeyboardOnTapOutside()
        
        loadPlant()
        updateInputImage()
        
        view.backgroundColor = .secondarySystemBackground
        title = "Edit Plant"
        
        // NavigationItems
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "qrcode"), style: .plain, target: self, action: #selector(tappedQRButton))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonPressed))
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.backgroundColor = .secondarySystemBackground
        scrollView.isDirectionalLockEnabled = true
        scrollView.isScrollEnabled = true
        
        // containerView
//        addView(viewIn: containerView, addSubTo: scrollView, top: scrollView.topAnchor, topConst: 0, bottom: scrollView.bottomAnchor, bottomConst: 500, left: scrollView.leftAnchor, leftConst: 0, right: scrollView.rightAnchor, rightConst: 0)
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 700).isActive = true
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        // plantTextFieldView
        containerView.addSubview(plantTextFieldView)
        plantTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        plantTextFieldView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        plantTextFieldView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        plantTextFieldView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        plantTextFieldView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        plantTextFieldView.backgroundColor = UIColor(named: "customWhite")
        
        // plantTextField
//        addView(viewIn: plantTextField, addSubTo: plantTextFieldView, top: plantTextFieldView.topAnchor, topConst: 5, bottom: plantTextFieldView.bottomAnchor, bottomConst: -5, left: plantTextFieldView.leftAnchor, leftConst: 20, right: plantTextFieldView.rightAnchor, rightConst: -20)
        plantTextFieldView.addSubview(plantTextField)
        plantTextField.translatesAutoresizingMaskIntoConstraints = false
        plantTextField.topAnchor.constraint(equalTo: plantTextFieldView.topAnchor, constant: 8).isActive = true
        plantTextField.leftAnchor.constraint(equalTo: plantTextFieldView.leftAnchor, constant: 20).isActive = true
        plantTextField.rightAnchor.constraint(equalTo: plantTextFieldView.rightAnchor, constant: -20).isActive = true
        plantTextField.bottomAnchor.constraint(equalTo: plantTextFieldView.bottomAnchor, constant: -8).isActive = true
        
        plantTextField.backgroundColor = .clear
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
        
        wateringSectionView.backgroundColor = UIColor(named: "customWhite")
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
        updatePlantButton.backgroundColor = UIColor(named: "customWhite")
        
        
        // inputImageButton
        containerView.addSubview(plantImageButton)
        plantImageButton.translatesAutoresizingMaskIntoConstraints = false
        plantImageButton.topAnchor.constraint(equalTo: updatePlantButton.bottomAnchor, constant: 20).isActive = true
        plantImageButton.heightAnchor.constraint(equalToConstant: 350).isActive = true
        plantImageButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        plantImageButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        plantImageButton.backgroundColor = UIColor(named: "customWhite")
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
        waterHabitButton.backgroundColor = UIColor(named: "customWhite")
        waterHabitButton.addTarget(self, action: #selector(waterHabitButtonClicked(sender:)), for: .touchUpInside)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.right")
        config.contentInsets = NSDirectionalEdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)
        config.imagePlacement = .trailing
        waterHabitButton.configuration = config
        waterHabitButton.tintColor = .lightGray
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
        
        lastWateredLabel.backgroundColor = UIColor(named: "customWhite")
        lastWateredLabel.text = "Last watered:"
        
        // datePicker
        wateringSectionView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 0).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: 0).isActive = true
        datePicker.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: -20).isActive = true
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date.now
        
        
        
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
        if let resultVC = storyboard.instantiateViewController(withIdentifier: "waterHabitStoryboardID")  as? WaterHabitDaysViewController {
            resultVC.selectedHabitDays = selectedHabitDay
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        
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
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
            
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
    
    @objc func tappedQRButton() {
        print("tappedQRButton")
        shareQRCodeButton(currentPlant: currentPlant)
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
        plantImageString = filteredSuggestion[indexPath.row]
        updateInputImage()
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
            textField.clearButtonMode = .whileEditing
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
                }
                
            }
            
            suggestionTableView.reloadData()
            print(filteredSuggestion)
        }
        
        if let text = textField.text {
            
            filterText(text + string)
            
            removeSuggestionScrollView()
            
            if !filteredSuggestion.isEmpty {
                showSuggestionScrollView(filteredSuggestion.count)
            }
            
        }
        
        return true
    }
    
    func showSuggestionScrollView(_ itemsCount: Int) {
  
        containerView.addSubview(suggestionScrollView)
        addSuggestionTableView()
        
        suggestionScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .leftMargin, relatedBy: .equal, toItem: plantTextFieldView, attribute: .leftMargin, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .rightMargin, relatedBy: .equal, toItem: plantTextFieldView, attribute: .rightMargin, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .topMargin, relatedBy: .equal, toItem: plantTextField, attribute: .bottom, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: suggestionScrollView, attribute: .height, relatedBy: .equal, toItem: plantTextFieldView, attribute: .height, multiplier: CGFloat(itemsCount), constant: 0)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint])
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
    
    func removeLoadingView() {
        DispatchQueue.main.async {
            self.loadingSpinnerView.stopAnimating()
            self.loadingSpinnerView.removeFromSuperview()
            self.opaqueView.removeFromSuperview()
            print("removedLoadingView")
        }
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
        
//        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
//            inputImage = image
//            plantImageButton.setImage(inputImage, for: .normal)
//        }
        
        // If source type is CAMERA
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
           
            inputImage = image
            plantImageButton.setImage(inputImage, for: .normal)
        }
      
        
        // If source type is PHOTO LIBRARY
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
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
        
        networkConnectionBool { [self] boolIn in
            if boolIn {
                print("boolIn: true")
                
                DispatchQueue.main.async { [self] in
                    
                    
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
                        "plantImageString": K.plantImageStringReturn_FB(K.imageSetNames, plantImageString: plantImageString, inputImage: inputImage),
                        "notificationPending": true
                    ]
                    
                    // 5: FIREBASE: Set doucment name(use index# to later use in core data)
                    let plantDoc = plantCollection.document("\(currentPlant.id!.uuidString)")
                    print("plantDoc edited uuid: \(currentPlantID.uuidString)")
                    
                    // 6: Edited data for "Plant entity input"
                    plantDoc.updateData(plantEditedData) { error in
                        if error != nil {
                            K.presentAlert(self, error!)
                            print("Error updating data on FB: \(String(describing: error))")
                        }
                    }
                    
                    // 7: Add edited doc date on FB
                    plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                        if error != nil {
                            K.presentAlert(self, error!)
                            print("Error updating data on FB: \(String(describing: error))")
                        }
                    }
                    
                    // FIREBASE STORAGE: if customImage is used, update photo on cloud storage as well.
                    if customImageData() != nil && currentPlant.customPlantImageID != nil {
                        
                        // Delete old photo from FB
                        deleteOldPhotoOnFB(customPlantImageID: currentPlant.customPlantImageID) {
                            // Handle Firebase Storage upload/update
                            self.uploadPhotoToFirebase(plantDoc) { stringIn in
                                
                                print("Update photo on Firebase/Storage completed.")
                                
                                if stringIn == "success" {
                                    print("uploadPhotoToFirebase success")
                                    self.loadPlantsFB(currentPlantUUID: currentPlantID)
                                } else {
                                    print("uploadPhotoToFirebase error")
                                    self.loadPlantsFB(currentPlantUUID: currentPlantID)
                                }
                            }
                        }
                        // If there was no previous customImage and user uploaded a new image, upload photo to Firebase.
                    } else if customImageData() != nil {
                        
                        self.uploadPhotoToFirebase(plantDoc) { stringIn in
                            print("Update photo on Firebase/Storage completed.")
                            
                            if stringIn == "success" {
                                print("uploadPhotoToFirebase success")
                                self.loadPlantsFB(currentPlantUUID: currentPlantID)
                            } else {
                                print("uploadPhotoToFirebase error")
                                self.loadPlantsFB(currentPlantUUID: currentPlantID)
                            }
                        }
                        // If there is no customimage uploaded or edited, just load plants.
                    } else {
                        self.loadPlantsFB(currentPlantUUID: currentPlantID)
                    }
                    
                    print("Plant successfully edited on Firebase")
                    
                }
                
            } else {
                print("boolIn: false")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error uploading plant:", message: "Please try again or check your network.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                        self.removeLoadingView()
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func loadPlantsFB(currentPlantUUID: UUID) {
        
        //Get currentUser UID to use as document's ID.
        let db = Firestore.firestore()
        guard let userID_FB = Auth.auth().currentUser?.uid else { return }
        
        let currentUserCollection = db.collection("users").document(userID_FB)
        let plantsCollection = currentUserCollection.collection("plants")
        
        // Get all documents/plants and put it in "plants_FB"
        plantsCollection.getDocuments { [weak self] (snapshot, error) in
            
            if error == nil && snapshot != nil {
                
                var plants_FB = [QueryDocumentSnapshot]()
                plants_FB = snapshot!.documents
                
                var plantDocIDsArray = [String]()
                
                for d in snapshot!.documents {
                    plantDocIDsArray.append(d.documentID)
                }
                
                
                
                self?.parseAndSaveFBintoCoreData(plants_FB: plants_FB, currentPlantUUID: currentPlantUUID) {
                    
                    print("Data has been parsed to Core Data")
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBadgeAndNotification"), object: nil)
                    
                    self?.dismiss(animated: true)
                    
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
                    
                    //notificationPending
                    let notificationPending_FB = data["notificationPending"] as? Bool ?? false
                    print("notificationPending_FB: \(notificationPending_FB)")
                    
                    currentPlant.id = plantUUID_FBCasted
                    currentPlant.plant = plantName_FB
                    currentPlant.waterHabit = Int16(waterHabit_FB)
                    currentPlant.dateAdded = dateAdded_FB
                    currentPlant.order = Int32(plantOrder_FB)
                    currentPlant.lastWateredDate = lastWatered_FB
                    currentPlant.plantImageString = plantImageString_FB
                    currentPlant.notificationPending = notificationPending_FB
                    
                    // Retrieve "customPlantImage" data from FB Storage.
                    let customPlantImageUUID_FB = data["customPlantImageUUID"] as? String
                    
                    if customPlantImageUUID_FB != nil {
                        
                        print("customPlantImageUUID_FB path: \(customPlantImageUUID_FB!)")
                        
                        let fileRef = Storage.storage().reference(withPath: customPlantImageUUID_FB!)
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
                            if error == nil && data != nil {
                                self?.currentPlant.customPlantImageID = customPlantImageUUID_FB!
                                self?.currentPlant.imageData = data!
                                self?.savePlant()
                                print("FB Storage imageData has been retrieved successfully: \(data!)")
                                completion()
                            } else {
                                print("Error retrieving data from cloud storage. Error: \(String(describing: error))")
                            }
                        }
                        
                    } else {
                        print("customPlantImage_FB is nil.")
                        self.savePlant()
                        completion()
                    }
                }
            }
        }
    }
    
    func uploadPhotoToFirebase(_ plantDoc: DocumentReference, completion: @escaping (String) -> Void) {
        let randomID = UUID.init().uuidString
        let path = "customSavedPlantImages/\(randomID).jpg"
        let uploadRef = Storage.storage().reference(withPath: path)
        
        guard let imageData = customImageData() else { return }
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpeg"
        
        uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetadata, error) in
            
            if error != nil {
                print("Firebase Error uploading photo: Error: \(String(describing: error))")
                completion("error")
            } else {
                
                // customPlantImageUUID: for identifying on cloud storage/Firestore
                plantDoc.updateData(["customPlantImageUUID": path]) { error in
                    if error != nil {
                        print("Firebase Error setting data for - customPlantImageUUID. Error: \(String(describing: error))")
                        completion("error")
                    } else {
                        
                        print("Firebase Storage: putData is complete. Meta Data info: \(String(describing: downloadMetadata))")
                        
                        completion("success")
                    }
                }
            }
        }
    }
    
    func deleteOldPhotoOnFB(customPlantImageID: String?, completion: @escaping () -> Void) {
        guard let imageToDeleteID = customPlantImageID else { return }
        
        let fileRef = Storage.storage().reference(withPath: imageToDeleteID)
        fileRef.delete { error in
            if error != nil {
                print("Error deleting from Firebase Storage: \(String(describing: error))")
                completion()
            } else {
                print("Successfully deleted previous image off firebase: \(imageToDeleteID)")
                completion()
            }
        }
    }
    
    func networkConnectionBool(completion: @escaping (Bool) -> Void) {
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
        
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network Connected")
                self.networkMonitor.cancel()
                completion(true)
            } else {
                print("Network Disconnected")
                self.networkMonitor.cancel()
                completion(false)
            }
            print("path.isExpensive: \(path.isExpensive)"
            )
        }
        
    }
    
    func shareQRCodeButton(currentPlant: Plant) {
        
        let filter = CIFilter.qrCodeGenerator()
        
        guard let uuidStringUnwrapped = currentPlant.id?.uuidString.utf8, let plantNameUnwrapped = currentPlant.plant else { return }
      
        
        filter.message = Data(uuidStringUnwrapped)
        
        if let outputImage = filter.outputImage {
            
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            let cgImageIn = UIImage(ciImage: outputImage.transformed(by: transform))
            
            
            let qrWithBorder = imageWithBorder(cgImageIn)
//            let qrWithBorderAndText = textToImage(drawText: plantNameUnwrapped, inImage: qrWithBorder, atPoint: CGPoint(x: 10, y: 90))
            
            let qrWithBorderAndText = textToImage(drawText: plantNameUnwrapped, inImage: qrWithBorder)
           
            let imageView = UIImageView(image: qrWithBorderAndText).viewPrintFormatter()
        
            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.outputType = .photo
            printInfo.jobName = "Printing Plant's QR"
            printInfo.orientation = .portrait
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.showsNumberOfCopies = false
            printController.printFormatter = imageView

        
            printController.present(animated: true)
            
        }
        
    }
    
    
    func imageWithBorder(_ image: UIImage) -> UIImage {
        // Load the original image
        let originalImage = image

        // Set the border width and color
        let borderWidth: CGFloat = 10.0
        let borderColor = UIColor.black.cgColor

        // Calculate the size of the new image
        let size = CGSize(width: originalImage.size.width + borderWidth, height: originalImage.size.height + borderWidth)

        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        // Get the current context
        let context = UIGraphicsGetCurrentContext()!

        // Draw the border
        context.setStrokeColor(borderColor)
        context.setLineWidth(borderWidth)
        let borderRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.stroke(borderRect)

        // Draw the original image inside the border
        let imageRect = CGRect(x: borderWidth/2, y: borderWidth/2, width: originalImage.size.width, height: originalImage.size.height)
        originalImage.draw(in: imageRect)

        // Get the new image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the image context
        UIGraphicsEndImageContext()
        return newImage

    }
    
    
    func textToImage(drawText text: String, inImage image: UIImage) -> UIImage {
        
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: image.size.width, height: image.size.height + 15)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        // Define text font attributes
        let textColor = UIColor.black
        var textFont = UIFont()
        switch text.count {
        case 14:
            textFont = UIFont(name: "Helvetica Bold", size: 11)!
        case 15:
            textFont = UIFont(name: "Helvetica Bold", size: 10)!
        case 16:
            textFont = UIFont(name: "Helvetica Bold", size: 9)!
        case 17:
            textFont = UIFont(name: "Helvetica Bold", size: 8)!
        case 18...100:
            textFont = UIFont(name: "Helvetica Bold", size: 7)!
        default:
            textFont = UIFont(name: "Helvetica Bold", size: 12)!
        }
        
//        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        let textBackgroundColor = UIColor(ciColor: .yellow)
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.backgroundColor: textBackgroundColor,
            ] as [NSAttributedString.Key : Any]
        
        // Calculate size of text.
        let textSizeWidth = (text as NSString).size(withAttributes: textFontAttributes).width
    
        // Calculate origin point to draw "text" to be placed in middle
        var imageCGPoint = CGPoint(x: image.size.width/2 - textSizeWidth/2, y: 90)
        
        // Calculate origin point to draw "text" to be placed at very left
        print("DDD1 textcount: \(text.count)")
        if textSizeWidth >= image.size.width {
            imageCGPoint = CGPoint(x: 0, y: 90)
        }
        
        // Temp fix for text width
        let cgSize = CGSize(width: image.size.width + 10, height: image.size.height + 15)
        let rect = CGRect(origin: imageCGPoint, size: cgSize)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        return newImage!
    }

    
}
