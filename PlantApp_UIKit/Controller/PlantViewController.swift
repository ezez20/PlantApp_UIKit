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
    
    @IBOutlet weak var weatherDateStackView: UIStackView!
    
    // MARK: - waterButton variable
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var dropCircleImage: UIImageView!
    
    // MARK: - Watering Habit variable
    @IBOutlet weak var wateringHabitStackView: UIStackView!
    
    @IBOutlet weak var containerView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: - UI: Water Button shadow
//        dropCircleImage.layer.shadowColor = UIColor.black.cgColor
//        dropCircleImage.layer.shadowOpacity = 0.5
//        dropCircleImage.layer.shadowRadius = 3
//        dropCircleImage.layer.masksToBounds = false
//
//        dropCircleImage.layer.shadowPath = UIBezierPath(roundedRect: dropCircleImage.frame, cornerRadius: 10).cgPath

        // MARK: - UI: Shadow around Watering Habit StackView
        wateringHabitStackView.layer.shadowColor = UIColor.black.cgColor
        wateringHabitStackView.layer.shadowOpacity = 0.5
        wateringHabitStackView.layer.shadowRadius = 5
        wateringHabitStackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        wateringHabitStackView.layer.cornerRadius = 10

       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // update the layers frame based on the frame of the view.
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.green.cgColor]
        gradient.locations = [0.6 , 1.0]
        gradient.frame = containerView.frame
        gradient.cornerRadius = 40
        containerView.layer.insertSublayer(gradient, at: 0)
        containerView.layer.cornerRadius = 40

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
