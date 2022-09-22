//
//  AddPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/1/22.
//

import UIKit
import CoreData


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
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    var filteredSuggestion = [String]()
    var showSuggestionList = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: ReloadDataDelegate?
    
    private var selectedHabitDay = 7
    
    // ADD: add more plants and images
    let imageSetNames = K.imageSetNames
    private var plantImageString = ""
    private var showingImagePicker = false
    private var inputImage: UIImage?
    private var sourceType: UIImagePickerController.SourceType = .camera
    
    
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        print(selectedHabitDay)
    }
    
    override func viewDidLayoutSubviews() {
        addCornerRadius(textFieldView)
        addCornerRadius(wateringSectionView)
        addCornerRadius(addPlantButton)
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
        if imageSetNames.contains(plantName.text!) && inputImage == nil {
            plantImageButton.setImage(UIImage(named: plantName.text!), for: .normal)
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
    
    
    //MARK: - Data Manipulation Methods
    func savePlant() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    
    
    //MARK: - IBActions Buttons
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
        
        let newPlant = Plant(context: self.context)
        newPlant.id = UUID()
        newPlant.plant = self.plantName.text
        newPlant.waterHabit = Int16(selectedHabitDay)
        newPlant.dateAdded = Date.now
        newPlant.order = Int32(plants.count + 1)
        newPlant.lastWateredDate = datePicker.date
        
        if imageSetNames.contains(plantImageString) && inputImage == nil {
            newPlant.plantImageString = plantImageString
        } else if imageSetNames.contains(plantImageString) && inputImage != nil {
            newPlant.plantImageString = ""
        } else if inputImage != nil {
            newPlant.plantImageString = ""
        } else {
            newPlant.plantImageString = "UnknownPlant"
        }
        
        if customImageData() != nil {
            newPlant.imageData = customImageData()
        }
        
        self.plants.append(newPlant)
        self.savePlant()
        
        // Tells MainViewController to "loadPlants"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
        
        
        //ADD: dismiss AddPlantView.
        dismiss(animated: true)
        
        // Debug area
        print("Plant added on \(String(describing: newPlant.dateAdded)): \(self.plantName.text!)")
        print("Plant order: \(newPlant.order)")
        
        
    }
    
    @IBAction func plantImageButtonTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
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

// MARK: - Protocols
protocol ReloadDataDelegate {
    func reloadData()
}


// MARK: - Extensions
extension AddPlantViewController: PassDataDelegate {
    func passData(Data: Int) {
        selectedHabitDay = Data
        print(Data)
    }
    
}

extension AddPlantViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - tableView section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredSuggestion.isEmpty {
            return filteredSuggestion.count
        } else {
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
            plantName.text = filteredSuggestion[indexPath.row]
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeSuggestionScrollView()
        self.view.endEditing(true)
        return false
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

//extension AddPlantViewController {
//    func animateConstraint() {
//        self.textFieldTopWateringLabelBottomConstraint.constant = 50
//
//        [UIView .animate(withDuration: 1.2, delay: 1, options: .curveEaseInOut, animations: {
//            self.textFieldTopWateringLabelBottomConstraint.constant = 50 ;
//            self.view.layoutIfNeeded();
//        }, completion: nil)];
//    }
//
//}


