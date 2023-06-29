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
    
    static let PlantViewControllerID = "PlantViewControllerID"
    
    static let mainToPlantID = "MainToPlant"
    static let mainToAddPlantID = "MainToAddPlantView"
    
    static let plantTableViewCellID = "PlantTableViewCell"
    static let notesTableViewCellID = "NotesTableViewCellID"
    static let cellReuseID = "cellReuseID"
    static let suggestionCell = "suggestionCell"
    static let tempLockMessageFB = "Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later."
    
    static let AddPlantToWaterHabitID = "AddPlantToWaterHabit"
    
    static let imageSetNames = [
        "calathea ornata",
        "dracaena",
        "fiddle leaf fig",
        "monstera",
        "money plant",
        "peace lily",
        "pothos",
        "ponytail palm",
        "prayer plant",
        "rubber tree",
        "snake plant",
        "spider plant",
        "zz plant"
    ]
    
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
    
    static func presentTabBarController(_ vc: UIViewController) {
        let tbC = TabBarController()
        tbC.tabBar.backgroundColor = .secondarySystemBackground
        tbC.tabBar.tintColor = UIColor(named: K.customGreen2)
        tbC.modalTransitionStyle = .crossDissolve
        tbC.modalPresentationStyle = .fullScreen
        
        let vc1 = mainVC()
        let vc2 = notesNavVC()
        let vc3 = QRScannerViewController(plants: [])
        let vc4 = ViewController4()
        let vc5 = profileSettingsVC()
        
       
        vc1.tabBarItem.image = UIImage(systemName: "leaf")
        vc1.title = "Plants"
        vc2.tabBarItem.image = UIImage(systemName: "square.and.pencil")
        vc2.title = "Notes"
        vc3.tabBarItem.image = UIImage(systemName: "qrcode.viewfinder")
        vc3.title = "Scan"
        vc4.tabBarItem.image = UIImage(systemName: "bag")
        vc4.title = "Wishlist"
        vc5.tabBarItem.image = UIImage(systemName: "gear")
        vc5.title = "Settings"
        
        
        tbC.setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: false)
        vc.present(tbC, animated: true)
   
    }
    
    static func mainVC() -> UIViewController {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewControllerID") as! MainViewController
        mainVC.modalTransitionStyle = .crossDissolve
        let navigation = UINavigationController(rootViewController: mainVC)
        navigation.navigationBar.tintColor = UIColor(named: K.customGreen2)
        navigation.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.customGreen2) ?? .label]
        navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.customGreen2) ?? .label]
        return navigation
    }
    
    static func profileSettingsVC() -> UIViewController {
        let settingsVC = SettingsViewController()
        let settingsPlantNavVC = UINavigationController(rootViewController: settingsVC)
        return settingsPlantNavVC
    }
    
    static func notesNavVC() -> UIViewController {
        let notesVC = NotesViewController(plants: [])
        let notesNavVC = UINavigationController(rootViewController: notesVC)
        return notesNavVC
    }
    
    
}

class ViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
    }
    
}

class ViewController3: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

class ViewController4: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
    }
}

class ViewController5: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
    }
}
