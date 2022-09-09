//
//  AddPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/1/22.
//

import UIKit
import CoreData


class AddPlantViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var typeOfPlant: UITextField!

    @IBOutlet weak var wateringSectionView: UIView!
    @IBOutlet weak var waterHabitButton: UIButton!
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addPlantButton: UIButton!
    
    @IBOutlet weak var plantImageButton: UIButton!
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedHabitDay = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Add Plant"
        
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
    
    func loadCategories() {
        
        let request : NSFetchRequest<Plant> = Plant.fetchRequest()
        
        do {
            plants = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }

        
    }
    
  
    
    // MARK: - waterHabitButton Pressed
    @IBAction func waterHabitButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "AddPlantToWaterHabit", sender: self)
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
        
//            let newPlant = Plant(context: self.context)
//            newPlant.plant = self.typeOfPlant.text
//
//            self.plants.append(newPlant)
//
//            self.savePlant()
        
            // dismiss AddPlantVIew
        dismiss(animated: true)
    }
    
}

extension AddPlantViewController: PassDataDelegate {
    func passData(Data: Int) {
        selectedHabitDay = Data
        print(Data)
    }
    
}
