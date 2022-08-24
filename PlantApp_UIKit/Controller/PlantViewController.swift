//
//  PlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/21/22.
//

import UIKit

class PlantViewController: UIViewController {

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantHappinessLevel: UILabel!
    
    @IBOutlet weak var weatherLogo: UIImageView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherCity: UILabel!
    
    @IBOutlet weak var currentDateDisplayed: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: - Rectangle/Gradient shape for background of Plant Image.
        let shape = CAShapeLayer()
        shape.frame = view.bounds
        shape.path = UIBezierPath(roundedRect: CGRect(x: view.frame.minY, y: view.frame.minY, width: view.frame.maxX, height: view.frame.height / 2.5), cornerRadius: 50).cgPath

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.green.cgColor]
        gradient.locations = [0.5 , 1.0]
        gradient.startPoint = CGPoint(x : 0.0, y : 0)
        gradient.endPoint = CGPoint(x :0.0, y: 0.5) // you need to play with 0.15 to adjust gradient vertically
        gradient.frame = view.bounds
        gradient.mask = shape
        
//        view.layer.addSublayer(gradient)
        view.layer.insertSublayer(gradient, at: 0)
        
        
        
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
