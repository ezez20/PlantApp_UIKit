//
//  AddPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/1/22.
//

import UIKit

class AddPlantViewController: UIViewController {
    
    @IBOutlet weak var typeOfPlant: UITextField!
    
    @IBOutlet weak var wateringSectionView: UIView!
    @IBOutlet weak var waterHabitButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addPlantButton: UIButton!
    
    @IBOutlet weak var plantImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.title = "Add Plant"
        
    }
    
    override func viewDidLayoutSubviews() {
        addCornerRadius(typeOfPlant)
        addCornerRadius(wateringSectionView)
        addCornerRadius(addPlantButton)
        
    }
    
    func addCornerRadius(_ appliedView: UIView) {
        appliedView.layer.cornerRadius = 10
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
