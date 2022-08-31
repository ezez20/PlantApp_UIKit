//
//  PlantTableViewCell.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 8/20/22.
//

import UIKit

class PlantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var waterInDays: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
