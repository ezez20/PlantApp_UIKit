//
//  PlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/21/22.
//

import UIKit

class PlantViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        
        let shape = CAShapeLayer()
        shape.frame = view.bounds
        shape.path = UIBezierPath(roundedRect: CGRect(x: 120, y: 64, width: 160, height: 160), cornerRadius: 50).cgPath

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.green.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x : 0.0, y : 0)
        gradient.endPoint = CGPoint(x :0.0, y: 0.15) // you need to play with 0.15 to adjust gradient vertically
        gradient.frame = view.bounds
        gradient.mask = shape
        
        view.layer.addSublayer(gradient)
        
        
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
