//
//  Constants.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/9/22.
//

import UIKit


struct K {
    
    static let title = "Plants"
    static let customGreenColor = "customGreen"
    static let customGreen2 = "customGreen2"
    static let custom_blue_1 = "custom_blue_1"
    static let unknownPlant = "UnknownPlant"
    static let leaf = "leaf"
    
    static let mainToPlantID = "MainToPlant"
    static let mainToAddPlantID = "MainToAddPlantView"
    
    static let plantTableViewCellID = "PlantTableViewCell"
    static let cellReuseID = "cellReuseID"
    static let suggestionCell = "suggestionCell"
    static let tempLockMessageFB = "Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later."
    
    static let AddPlantToWaterHabitID = "AddPlantToWaterHabit"
    
    static let imageSetNames = ["calathea ornata", "dracaena", "fiddle leaf fig", "monstera", "money plant", "peace lily", "pothos", "ponytail palm", "prayer plant","rubber tree", "snake plant", "spider plant","zz plant"]
    
    static let appPrivacyPolicyURL = "https://github.com/ezez20/PlantApp_UIKit/blob/main/AppPrivacyPolicy.md"
    
    static let termsAndConditionsURL  = "https://github.com/ezez20/PlantApp_UIKit/blob/main/TermsAndConditions.md"
    
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
    
    static func plantImageStringReturn_FB(_ imageSetNames: [String], plantImageString: String, inputImage: UIImage?) -> String {
    
        if imageSetNames.contains(plantImageString) && inputImage == nil {
            return plantImageString
        } else if imageSetNames.contains(plantImageString) && inputImage != nil {
            return ""
        } else if inputImage != nil {
            return ""
        } else {
            return "UnknownPlant"
        }
    }
    
    static func navigateToMainVC(_ vc: UIViewController) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewControllerID") as! MainViewController
        mainVC.modalTransitionStyle = .crossDissolve
        let navigation = UINavigationController(rootViewController: mainVC)
        navigation.navigationBar.tintColor = UIColor(named: K.customGreen2)
        navigation.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.customGreen2)]
        navigation.modalPresentationStyle = .fullScreen
        vc.present(navigation, animated: true)
    }
    
  
    
}
