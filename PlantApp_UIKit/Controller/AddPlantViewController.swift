//
//  AddPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/1/22.
//

import UIKit
import CoreData

protocol ReloadDataDelegate {
    func reloadData()
}

class AddPlantViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var plantName: UITextField!

    @IBOutlet weak var wateringSectionView: UIView!
    @IBOutlet weak var waterHabitButton: UIButton!
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addPlantButton: UIButton!
    
    @IBOutlet weak var plantImageButton: UIButton!
    
    
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: ReloadDataDelegate?
  
    private var selectedHabitDay = 7

    // ADD: add more plants and images
    let imageSetNames = ["monstera", "pothos"]
    private var plantImageString = ""
    private var showingImagePicker = false
    private var inputImage: UIImage?
    private var sourceType: UIImagePickerController.SourceType = .camera

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Add Plant"
        plantName.delegate = self
        
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
    
   

    func updateUI() {
        waterHabitButton.setTitle("Water every \(selectedHabitDay.formatted()) days", for: .normal)
    }

    func addCornerRadius(_ appliedView: UIView) {
        appliedView.layer.cornerRadius = 10
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
  
    
    // MARK: - waterHabitButton Pressed
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
    
    //MARK: - Add Plant Button Pressed
    @IBAction func addPlantButtonPressed(_ sender: Any) {
        
        let newPlant = Plant(context: self.context)
        newPlant.id = UUID()
        newPlant.plant = self.plantName.text
        newPlant.waterHabit = Int16(selectedHabitDay)
        newPlant.dateAdded = Date.now
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
        print(self.plantName.text!)
        print(self)
        print(datePicker.date)
        

    }
    
    @IBAction func plantImageButtonTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func customImageData () -> Data? {
        let pickedImage = inputImage?.jpegData(compressionQuality: 0.80)
        return pickedImage
    }
}

extension AddPlantViewController: PassDataDelegate {
    func passData(Data: Int) {
        selectedHabitDay = Data
        print(Data)
    }
    
}

extension AddPlantViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateInputImage()
        
        let trimmedAndLoweredText = plantName.text?.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard plantName.text!.count >= 1, trimmedAndLoweredText != "" else {
            plantImageString = ""
            addPlantButton.isEnabled = false
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
        
        // ADD FEATURE LATER: Plants suggestion
//        if plant != "" {
//            showSuggestionsList = true
//        } else {
//            showSuggestionsList = false
//        }
        
        plantImageString = trimmedAndLoweredText!
        print(plantImageString)
 
//        showSuggestionsList = false
//        UIApplication.shared.endEditing()
    
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
