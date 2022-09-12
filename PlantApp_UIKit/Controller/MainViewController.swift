//
//  ViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/19/22.
//

import UIKit
import CoreLocation
import CoreData

class MainViewController: UIViewController {
    
    // MARK: - Core Data - Persisting data
    var plants = [Plant]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var plantsTableView: UITableView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherLogo = ""
    var weatherTemp = ""
    var weatherCity = ""
    

    
    let imageSetNames = ["monstera", "pothos"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = K.title
        plantsTableView.delegate = self
        plantsTableView.dataSource = self
        plantsTableView.layer.cornerRadius = 10
        
        // Register: PlantTableViewCell
        plantsTableView.register(UINib(nibName: K.plantTableViewCellID, bundle: nil), forCellReuseIdentifier: K.plantTableViewCellID)
        
      
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        weatherManager.delegate = self
        
        // Load plants from Core Data
        loadPlants()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name:NSNotification.Name("triggerLoadPlants"), object: nil)

    }

    
    @IBAction func editButtonPressed(_ sender: Any) {
        // Future feature: Edit button to allow re-order tableView.
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: K.mainToAddPlantID, sender: self)
    }
    

    //MARK: - Data Manipulation Methods
    func savePlant() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        plantsTableView.reloadData()
    }
    
    func loadPlants() {
        let request : NSFetchRequest<Plant> = Plant.fetchRequest()
        
        do {
            plants = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
        plantsTableView.reloadData()
        print("Plants loaded")
    }
    
    
    @objc func notificationReceived() {
        loadPlants()
    }
    
    // MARK: - convert retrieved Data to UIImage 
        func loadedImage(with imageData: Data?) -> UIImage {
            guard let imageData = imageData else {
    //            print("Error outputing imageData")
                return UIImage(named: "UnknownPlant")!
            }
            let loadedImage = UIImage(data: imageData)
            return loadedImage!
        }
    
    // MARK: - Formatting displayedNextWaterDate
    func displayedNextWaterDate(lastWateredDate: Date, waterHabit: Int) -> String {
        // Work on implementing in ForEach List.
        var nextWaterDate: Date {
            let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabit, to: lastWateredDate.advanced(by: 86400))
            return calculatedDate!
        }
        
        var waterStatus: String {
            
            let dateIntervalFormat = DateComponentsFormatter()
            dateIntervalFormat.allowedUnits = .day
            dateIntervalFormat.unitsStyle = .short
            let formatted = dateIntervalFormat.string(from: Date.now, to: nextWaterDate) ?? ""
            if formatted == "0 days" || nextWaterDate < Date.now {
                return "Please water me ):"
            } else if dateFormatter.string(from: lastWateredDate) == dateFormatter.string(from: Date.now) {
                return "in \(waterHabit) days"
            } else {
                return "in \(formatted)"
            }
            
        }
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }
        return waterStatus
    }


    
}


// MARK: - extension: UITableViewDelegate/UITableViewDataSource
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped on \(indexPath.description)")
        performSegue(withIdentifier: K.mainToPlantID, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PlantViewController {
            let vc = segue.destination as? PlantViewController
            vc?.inputLogo = weatherLogo
            vc?.inputTemp = weatherTemp
            vc?.inputCity = weatherCity
            
        }
    }
  
}

extension MainViewController: UITableViewDataSource {
    
    // Tells how many rows to list out in tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
        return plants.count
    }
    
    // Inputs custom UITableViewCell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: K.plantTableViewCellID, for: indexPath) as! PlantTableViewCell
        
        // Later, assign values to cell's properties: EX below
        cell.plantName.text = plants[indexPath.row].plant
        
        if imageSetNames.contains(plants[indexPath.row].plantImageString!) {
            cell.plantImage.image = UIImage(named: plants[indexPath.row].plantImageString!)
        } else if plants[indexPath.row].plantImageString! == "UnknownPlant" && plants[indexPath.row].imageData != nil {
            cell.plantImage.image = UIImage(named: K.unknownPlant)
        } else {
            if plants[indexPath.row].imageData != nil {
                cell.plantImage.image = UIImage(data: plants[indexPath.row].imageData!)
            } else {
                cell.plantImage.image = UIImage(named: K.unknownPlant)
            }
        }
        
        cell.waterInDays.text = displayedNextWaterDate(lastWateredDate: plants[indexPath.row].lastWateredDate! , waterHabit: Int(plants[indexPath.row].waterHabit))
        
        return cell
    }
    
}


extension MainViewController: WeatherManagerDelegate {

    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherLogo = weather.conditionName
            self.weatherTemp = weather.teperatureString
            self.weatherCity = weather.cityName
            
        }
    }

    func didFailWithError(error: Error) {
        print(error)
    }
    

}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

