//
//  NotesViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 6/13/23.
//

import UIKit

class NotesViewController: UIViewController {
    
    var plants: [Plant]
    var weatherLogo: String?
    var weatherTemp: String?
    var weatherCity: String?
    
    let notesTableView = UITableView()
    
    init(plants: [Plant]) {
        self.plants = plants
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.customGreen2) ?? .label]
        title = "Notes"
        
        setupNotesTableView()
        self.enableDismissKeyboardOnTapOutside()
        
        print("DEBUG: \(plants.count)")
    }
    

}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    func setupNotesTableView() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.register(NotesTableViewCell.self, forCellReuseIdentifier: K.notesTableViewCellID)
            
        view.addSubview(notesTableView)
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
        notesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        notesTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        notesTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        notesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        notesTableView.rowHeight = 180
        notesTableView.layer.cornerRadius = 10
        notesTableView.backgroundColor = .secondarySystemBackground
        notesTableView.sectionHeaderTopPadding = 0
        
    }
    
    
    // MARK: - UITableViewDelegate METHODS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return plants.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = PlantViewController()
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let plantVC = storyboard.instantiateViewController(withIdentifier: K.PlantViewControllerID) as! PlantViewController
        plantVC.currentPlant = plants[indexPath.section]
        plantVC.inputCityIn = weatherCity!
        plantVC.inputLogoIn = weatherLogo!
        plantVC.inputTempIn = weatherTemp!
        
        navigationController?.navigationBar.tintColor = UIColor(named: K.customGreen2)
        navigationController?.pushViewController(plantVC, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource METHODS
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.notesTableViewCellID, for: indexPath) as! NotesTableViewCell
        
        cell.plant = plants[indexPath.section]
        
        return cell
    }
    
    // MARK: - UITextView METHODS
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
    }
    
    func enableDismissKeyboardOnTapOutside() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        print("DDD view: \(tap.view)")
        view.addGestureRecognizer(tap)
        print("enableDismissKeyboardOnTapOutside")
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
        print("dismissKeyboardTouchOutside")
    }
    
}
