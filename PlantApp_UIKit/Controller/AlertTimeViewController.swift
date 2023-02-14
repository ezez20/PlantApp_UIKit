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

        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(alertTimeTable)
        alertTimeTable.translatesAutoresizingMaskIntoConstraints = false
        alertTimeTable.topAnchor.constraint(equalTo: view.topAnchor, constant: 108).isActive = true
        alertTimeTable.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        alertTimeTable.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        alertTimeTable.bottomAnchor.constraint(equalTo: view.topAnchor, constant: (50 * 4) + 108).isActive = true
        alertTimeTable.layer.cornerRadius = 10
        
        alertTimeTable.tableHeaderView = UIView()
        alertTimeTable.tableFooterView = UIView()
        alertTimeTable.rowHeight = 50
        alertTimeTable.layer.cornerRadius = 10
        alertTimeTable.alwaysBounceVertical = false
        alertTimeTable.alwaysBounceHorizontal = false
        
        alertTimeTable.delegate = self
        alertTimeTable.dataSource = self
        alertTimeTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        
        title = "Alert"
    }
    
    
}


extension AlertTimeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell  = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        
        cell.textLabel?.text = "\(self.options[indexPath.row])"
        
        // UI Update: Tick on cell when selected.
        if alertOption == indexPath.row {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(named: K.customGreen2)
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
