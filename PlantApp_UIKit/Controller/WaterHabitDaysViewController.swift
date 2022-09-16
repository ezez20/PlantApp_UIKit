//
//  WaterHabitDaysViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/8/22.
//

import UIKit

protocol PassDataDelegate {
    func passData(Data: Int)
}

class WaterHabitDaysViewController: UIViewController {

    @IBOutlet weak var waterDaysTableView: UITableView!
    private let cellReuseID = "Cell"

    let habitDays = Array(2...14)
    var selectedHabitDays = 7
    
    var delegate: PassDataDelegate?

// MARK: - Views load state
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        waterDaysTableView.delegate = self
        waterDaysTableView.dataSource = self
        waterDaysTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        
    }

}

extension WaterHabitDaysViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped on \(indexPath.description)")
        selectedHabitDays = habitDays[indexPath.row]
        print("SelectedHabitDays: VC2 = \(selectedHabitDays)")
        tableView.reloadData()
        
        delegate?.passData(Data: selectedHabitDays)
   
    }

}

extension WaterHabitDaysViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell  = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        
        cell.textLabel?.text = "\(self.habitDays[indexPath.row].formatted()) days"
        
        // UI Update: Tick on cell when selected.

        if selectedHabitDays == self.habitDays[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
      
    }
    
  
    // Tells how many rows to list out in tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitDays.count
    }
    

}


