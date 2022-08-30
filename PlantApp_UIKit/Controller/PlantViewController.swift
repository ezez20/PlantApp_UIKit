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
    
    // MARK: - Weather variables
    @IBOutlet weak var weatherLogo: UIImageView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherCity: UILabel!
    
    // MARK: - Current Date Displayed Variable
    @IBOutlet weak var currentDateDisplayed: UILabel!
    
    // MARK: - waterButton variable
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var dropCircleImage: UIImageView!
    
    // MARK: - Watering Habit variable
    @IBOutlet weak var wateringHabitView: UIView!

    @IBOutlet weak var wateringHabitStackView: UIStackView!
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: - UI: Rectangle/Gradient shape for background of Plant Image.
        let shape = CAShapeLayer()
        shape.frame = view.bounds
//        shape.path = UIBezierPath(roundedRect: CGRect(x: view.frame.minY, y: view.frame.minY, width: view.frame.maxX, height: view.frame.height / 2.5), cornerRadius: 50).cgPath
        shape.path = UIBezierPath(roundedRect: CGRect(x: view.frame.minY, y: view.frame.minY, width: view.frame.maxX, height: plantImage.frame.maxY), cornerRadius: 50).cgPath
        
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.green.cgColor]
        gradient.locations = [0.1 , 1.0]
        gradient.startPoint = CGPoint(x : view.frame.minX, y : view.frame.minY)
        gradient.endPoint = CGPoint(x : view.frame.minX, y: 0.4) // you need to play with 0.15 to adjust gradient vertically
        gradient.frame = view.bounds
        gradient.mask = shape
        view.layer.insertSublayer(gradient, at: 0)
        
        
        
        // MARK: - UI: Water Button shadow
        dropCircleImage.layer.shadowColor = UIColor.black.cgColor
        dropCircleImage.layer.shadowOpacity = 0.5
        dropCircleImage.layer.shadowRadius = 3
        dropCircleImage.layer.masksToBounds = true

        dropCircleImage.layer.shadowPath = UIBezierPath(roundedRect: dropCircleImage.bounds, cornerRadius: 10).cgPath

        
        
        wateringHabitStackView.layer.shadowColor = UIColor.black.cgColor
        wateringHabitStackView.layer.shadowOpacity = 0.5
        wateringHabitStackView.layer.shadowRadius = 5
        wateringHabitStackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        wateringHabitStackView.layer.cornerRadius = 10
        wateringHabitStackView.layer.shadowPath = UIBezierPath(roundedRect: wateringHabitStackView.bounds, cornerRadius: 10).cgPath
       
    }
    
    @IBAction func waterButtonPressed(_ sender: Any) {
        print("Water button pressed.")
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
