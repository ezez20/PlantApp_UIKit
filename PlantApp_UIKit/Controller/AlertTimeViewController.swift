//
//  AlertTimeViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 10/11/22.
//

import UIKit

class AlertTimeViewController: UIViewController {
    
    private let cellReuseID = K.cellReuseID
    let options = ["day of event", "1 day before", "2 days before", "3 day before"]
    var alertOption = 0
    
    let containerView = UIView()
    let alertTimeTable = UITableView()
    var delegate: PassAlertDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alert"
        navigationController?.navigationBar.prefersLargeTitles = false

        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(alertTimeTable)
        alertTimeTable.translatesAutoresizingMaskIntoConstraints = false
        alertTimeTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        alertTimeTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        alertTimeTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true

        
        alertTimeTable.delegate = self
        alertTimeTable.dataSource = self
        alertTimeTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        
    }
    
    override func viewDidLayoutSubviews() {
        // ADJUST: tableview dynamically adjusts height based on contentSize.
        alertTimeTable.heightAnchor.constraint(equalToConstant: alertTimeTable.contentSize.height).isActive = true
        
//        let rowsHeight = alertTimeTable.estimatedSectionFooterHeight
//        print(rowsHeight)
//        let distance = view.bounds.height - rowsHeight - CGFloat(50)
//        print(distance)
//        alertTimeTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -distance).isActive = true
        
        alertTimeTable.layer.cornerRadius = 10
        alertTimeTable.alwaysBounceVertical = false
        alertTimeTable.alwaysBounceHorizontal = false
    }
    

}


extension AlertTimeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell  = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        
        cell.textLabel?.text = "\(self.options[indexPath.row])"
        
        // UI Update: Tick on cell when selected.
        if alertOption == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
    }
  
    // Tells how many rows to list out in tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alertOption = indexPath.row
        delegate?.passAlert(Alert: alertOption)
        print("Option \(alertOption) picked")
        tableView.reloadData()
    }
    
}

protocol PassAlertDelegate {
    func passAlert(Alert: Int)
}
