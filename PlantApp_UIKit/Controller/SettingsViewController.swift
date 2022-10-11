//
//  SettingsViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 10/10/22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let containerView = UIView()
    let sectionView = UIView()
    
    // notification section
    let notificationLabel = UILabel()
    let notificationBell = UIImageView()
    let notificationToggleSwitch = UISwitch()
    
    //divider
    let dividerView = UIView()
    
    // alertTimeButton
    let alertTimeButton = UIButton()
    let alertLogo = UIImageView()
    let alertLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Settings"

        // Do any additional setup after loading the view.
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        containerView.backgroundColor = .secondarySystemBackground
        
        containerView.addSubview(sectionView)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 108).isActive = true
        
//        sectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -200).isActive = true
        sectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        sectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        
        sectionView.backgroundColor = .white
        sectionView.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        // notification section
        sectionView.addSubview(notificationBell)
        notificationBell.translatesAutoresizingMaskIntoConstraints = false
        notificationBell.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 10).isActive = true
        notificationBell.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        
        notificationBell.heightAnchor.constraint(equalToConstant: 30).isActive = true
        notificationBell.widthAnchor.constraint(equalToConstant: 30).isActive = true
        notificationBell.image = UIImage(systemName: "bell.fill")
        notificationBell.contentMode = .scaleAspectFit
        notificationBell.tintColor = .systemYellow
        
        sectionView.addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.centerYAnchor.constraint(equalTo: notificationBell.centerYAnchor).isActive = true
        notificationLabel.leftAnchor.constraint(equalTo: notificationBell.rightAnchor, constant: 20).isActive = true
        notificationLabel.text = "Notification Mode"
        
        sectionView.addSubview(notificationToggleSwitch)
        notificationToggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        notificationToggleSwitch.centerYAnchor.constraint(equalTo: notificationBell.centerYAnchor).isActive = true
        notificationToggleSwitch.rightAnchor.constraint(equalTo: sectionView.rightAnchor, constant: -20).isActive = true
        
        // dividerView
        sectionView.addSubview(dividerView)
        dividerView.frame = CGRect(x: 0, y: 0, width: sectionView.frame.width, height: 1.0)
        dividerView.layer.borderWidth = 1.0
        dividerView.layer.borderColor = UIColor.placeholderText.cgColor
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constraint(equalTo: notificationBell.bottomAnchor, constant: 10).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: notificationBell.bottomAnchor, constant: 11).isActive = true
        dividerView.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        dividerView.rightAnchor.constraint(equalTo: sectionView.rightAnchor, constant: 0).isActive = true
        
        // alertTimeButton
        var config = UIButton.Configuration.plain()
        config.title = "day of event"
        config.baseForegroundColor = .placeholderText
        alertTimeButton.configuration = config
       
        sectionView.addSubview(alertTimeButton)
        alertTimeButton.translatesAutoresizingMaskIntoConstraints = false
        alertTimeButton.leftAnchor.constraint(equalTo: sectionView.leftAnchor).isActive = true
        alertTimeButton.rightAnchor.constraint(equalTo: sectionView.rightAnchor).isActive = true
        alertTimeButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor).isActive = true
        alertTimeButton.heightAnchor.constraint(equalTo: notificationBell.heightAnchor, constant: 20).isActive = true
        alertTimeButton.contentHorizontalAlignment = .trailing
        alertTimeButton.configuration?.image = UIImage(systemName: "chevron.right")
        alertTimeButton.configuration?.imagePlacement = .trailing
        
        alertTimeButton.addTarget(self, action:#selector(alertButtonPressed), for: .touchUpInside)
        
        sectionView.addSubview(alertLogo)
        alertLogo.translatesAutoresizingMaskIntoConstraints = false
        alertLogo.topAnchor.constraint(equalTo: alertTimeButton.topAnchor, constant: 10).isActive = true
        alertLogo.leftAnchor.constraint(equalTo: sectionView.leftAnchor, constant: 20).isActive = true
        
        alertLogo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        alertLogo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        alertLogo.image = UIImage(systemName: "clock.fill")
        alertLogo.contentMode = .scaleAspectFit
        alertLogo.tintColor = .systemRed
        
        sectionView.addSubview(alertLabel)
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.centerYAnchor.constraint(equalTo: alertLogo.centerYAnchor).isActive = true
        alertLabel.leftAnchor.constraint(equalTo: alertLogo.rightAnchor, constant: 20).isActive = true
        alertLabel.text = "Alert"
        
        // ADJUST IF NEEDED: determines the constraint for the bottom of "sectionView"
        sectionView.bottomAnchor.constraint(equalTo: alertTimeButton.bottomAnchor, constant: 0).isActive = true
    }

    @objc func alertButtonPressed() {
        print("alertButtonPressed")
        // add segue to "alertTime" view controller.
        
    }
}
