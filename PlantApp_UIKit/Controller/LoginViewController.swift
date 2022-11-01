//
//  LoginViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/1/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    let titleLogo = UIImageView()
    let appName = UILabel()
    
    let signUpButton = UIButton()
    let useWithoutAccountButton = UIButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(titleLogo)
        titleLogo.translatesAutoresizingMaskIntoConstraints = false
        titleLogo.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        titleLogo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        titleLogo.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        titleLogo.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        titleLogo.image = UIImage(named: K.unknownPlant)
        
        view.addSubview(appName)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.topAnchor.constraint(equalTo: titleLogo.bottomAnchor, constant: 5).isActive = true
        appName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        appName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        appName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        appName.text = "PlantApp"
        appName.font = UIFont.boldSystemFont(ofSize: 50)
        appName.textAlignment = .center
        
        view.addSubview(useWithoutAccountButton)
        useWithoutAccountButton.translatesAutoresizingMaskIntoConstraints = false
        useWithoutAccountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        useWithoutAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        useWithoutAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        useWithoutAccountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        useWithoutAccountButton.setTitle("Use without login account", for: .normal)
        useWithoutAccountButton.backgroundColor = .red
//        useWithoutAccountButton.setTitleColor(.black, for: .normal)
        useWithoutAccountButton.layer.cornerRadius = 20
        useWithoutAccountButton.addTarget(self, action: #selector(useWithoutAccountButtonClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func useWithoutAccountButtonClicked(sender: UIButton) {
        // Add segue to WaterHabitDaysViewController
        print("Water Habit button clicked")
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewControllerID")  as! MainViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
        
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
