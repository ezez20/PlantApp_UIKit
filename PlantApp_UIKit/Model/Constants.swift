//
//  Constants.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/9/22.
//

import Foundation
import UIKit


struct K {
    static let title = "Plants"
    static let customGreenColor = "customGreen"
    static let customGreen2 = "customGreen2"
    static let unknownPlant = "UnknownPlant"
    static let leaf = "leaf"
    
    static let mainToPlantID = "MainToPlant"
    static let mainToAddPlantID = "MainToAddPlantView"
    
    static let plantTableViewCellID = "PlantTableViewCell"
    static let cellReuseID = "cellReuseID"
    static let suggestionCell = "suggestionCell"
    
    static let AddPlantToWaterHabitID = "AddPlantToWaterHabit"
    
    static let imageSetNames = ["monstera", "pothos", "fiddle leaf"]
    
    static func presentAlert(_ viewController: UIViewController ,_ error: Error) {

        let alert = UIAlertController(title: "Error:", message: "\(error)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func plantImageStringReturn(_ imageSetNames: [String], plantImageString: String, inputImage: UIImage?, newPlant: Plant) {
    
        if imageSetNames.contains(plantImageString) && inputImage == nil {
            newPlant.plantImageString = plantImageString
        } else if imageSetNames.contains(plantImageString) && inputImage != nil {
            newPlant.plantImageString = ""
        } else if inputImage != nil {
            newPlant.plantImageString = ""
        } else {
            newPlant.plantImageString = "UnknownPlant"
        }
    }
    
    static func navigateToMainVC(_ navVC: UINavigationController) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewControllerID")  as! MainViewController
        navVC.pushViewController(mainVC, animated: true)
    }
    
}
