//
//  ViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/19/22.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet weak var plantsTableView: UITableView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    var weatherLogo = ""
    var weatherTemp = ""
    var weatherCity = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Plants"
        plantsTableView.delegate = self
        plantsTableView.dataSource = self
        plantsTableView.layer.cornerRadius = 10
        
        // Register: PlantTableViewCell
        plantsTableView.register(UINib(nibName: "PlantTableViewCell", bundle: nil), forCellReuseIdentifier: "PlantTableViewCell")
        
      
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        weatherManager.delegate = self

    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "MainToAddPlantView", sender: self)
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


// MARK: - extension: UITableViewDelegate/UITableViewDataSource
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped on \(indexPath.description)")
        self.performSegue(withIdentifier: "MainToPlant", sender: self)
        
    }
  
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PlantTableViewCell", for: indexPath) as! PlantTableViewCell
        
//        cell.textLabel?.text = "Plants"
        return cell
    }
    
    
    
}


extension MainViewController: WeatherManagerDelegate {

    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
//            self.temperatureLabel.text = weather.teperatureString
//            self.conditionImageView.image = UIImage(systemName: "\(weather.conditionName)")
//            self.cityLabel.text = weather.cityName
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
