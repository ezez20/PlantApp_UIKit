//
//  PlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/21/22.
//

import UIKit

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
    let imageSetNames = ["monstera", "pothos"]
    
    // MARK: - Core Data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentPlant = Plant()
    

    
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
            return "water me ):"
        } else if dateFormatter.string(from:  datePicker.date) == dateFormatter.string(from: currentDate) {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // MARK: - UI: add gradient to containerView
       
        updateWeatherUI()
        loadData()
        updateUI()
        datePicker.maximumDate = Date.now
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        
    }
   
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        lastWateredDateIn = sender.date
        updateUI()
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
    }

    // MARK: - IBActions functions
    @IBAction func waterButtonPressed(_ sender: Any) {
        lastWateredDateIn = Date.now
        currentDate = Date.now
        updateUI()
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
    
    func updateUI() {
        waterStatusView.text = waterStatus
    }
    
    func loadData() {
        plantName.text = currentPlant.plant
        waterHabitIn = Int(currentPlant.waterHabit)
        lastWateredDateIn = currentPlant.lastWateredDate!
        plantImage.image = plantImageLoadedIn
        waterStatusView.text = waterStatus
    }
    
    func updatePlant() {
        // ADD PLANT ENTITY TO UPDATE DATA
        currentPlant.lastWateredDate = lastWateredDateIn
        print("Updated current plant to: \(lastWateredDateIn)" )
 
        do {
            try context.save()
        } catch {
            print("Error updating plant \(error)")
        }
    }
    
    
    
//    func loadedImage(with imageData: Data?) -> UIImage {
//        guard let imageData = imageData else {
//            //            print("Error outputing imageData")
//            return UIImage(named: "UnknownPlant")!
//        }
//        let loadedImage = UIImage(data: imageData)
//        return loadedImage!
//    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


