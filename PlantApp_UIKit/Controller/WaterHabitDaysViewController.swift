//
//  WaterHabitDaysViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/8/22.
//

import UIKit

class WaterHabitDaysViewController: UIViewController {

    @IBOutlet weak var waterDaysTableView: UITableView!
    let cellReuseID = "AddPlantToWaterHabit"

    let habitDays = Array(2...14)
    var selectedHabitDays = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        waterDaysTableView.delegate = self
        waterDaysTableView.dataSource = self
        self.waterDaysTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
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

extension WaterHabitDaysViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped on \(indexPath.description)")
        selectedHabitDays = habitDays[indexPath.row]
        tableView.reloadData()
        
    }
    

    
  
}

extension WaterHabitDaysViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell  = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        cell.textLabel?.text = "\(self.habitDays[indexPath.row].formatted()) days"
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
