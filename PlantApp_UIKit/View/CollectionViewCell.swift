//
//  CollectionViewCell.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 3/3/23.
//

import UIKit

protocol CollectionViewCellDelegate {
    func insidCellDidSelect()
}


class CollectionViewCell: UICollectionViewCell {
    
    
    static let identifier = "collectionCellID"
    
    var delegate : CollectionViewCellDelegate?
    
    var plant: Plant? {
        didSet {
            guard let plantIn = plant else { return }
            
            if K.imageSetNames.contains(plantIn.plantImageString!) {
                cellImageView.image = UIImage(named: plantIn.plantImageString!)
            } else {
                cellImageView.image = loadedImage(with: plantIn.imageData)
            }
            
            labelName.text = plantIn.plant
            
            labelWaterDays.text = displayedNextWaterDate(lastWateredDate: plantIn.lastWateredDate ?? Date.now, waterHabit: Int(plantIn.waterHabit))
        }
    }
    
    let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    let labelName: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .secondarySystemBackground
        return label
    }()
    
    let waterStatusView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .secondarySystemBackground
        return uiView
    }()
    
    let dropletImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "drop")
        imageView.tintColor = .black
//        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    let labelWaterDays: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.clipsToBounds = true
        label.adjustsFontSizeToFitWidth = true
//        label.backgroundColor = .secondarySystemBackground
        return label
    }()
    
    let button: UIButton = {
       let button = UIButton()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(cellImageView)
        contentView.addSubview(labelName)
        contentView.addSubview(waterStatusView)
        contentView.addSubview(button)
        button.bounds = contentView.bounds
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
//        contentView.addSubview(labelWaterDays)
//        contentView.addSubview(dropletImage)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    override func layoutSubviews() {
        
        cellImageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: contentView.frame.size.width,
                                     height: contentView.frame.size.height / CGFloat(1.5)
        )
        
        labelName.frame = CGRect(x: 0,
                                 y: cellImageView.bounds.maxY,
                                 width: contentView.frame.size.width,
                                 height: 20
        )
        
//        labelWaterDays.frame = CGRect(x: contentView.center.x - 20,
//                                 y:  cellImageView.bounds.maxY + CGFloat(20),
//                                 width: contentView.frame.size.width / 2,
//                                 height: 20
//        )
        
//        labelWaterDays.backgroundColor = .red
        
//        dropletImage.frame = CGRect(x: 20,
//                                 y:  cellImageView.bounds.maxY + CGFloat(20),
//                                    width: (dropletImage.image?.size.width)!,
//                                 height: 20
//        )
        
        
       
        waterStatusView.frame = CGRect(x: cellImageView.bounds.midX - 30,
                                   y:  cellImageView.bounds.maxY + CGFloat(20),
                                   width: contentView.frame.size.width,
                                   height: 20
        )
        
        waterStatusView.addSubview(dropletImage)
        dropletImage.frame = CGRect(x: 0,
                                    y:  0,
                                    width: 20,
                                 height: 20
        )
        
        waterStatusView.addSubview(labelWaterDays)
        labelWaterDays.frame = CGRect(x: dropletImage.frame.maxX,
                                 y:  0,
                                 width: contentView.frame.size.width / 2,
                                 height: 20
        )
        
        
    }
    
    override func prepareForReuse() {
        cellImageView.image = nil
    }
    
    @objc func buttonPressed() {
        print("Button pressed")
        delegate?.insidCellDidSelect()
    }
    
}

extension CollectionViewCell {
    
    func loadedImage(with imageData: Data?) -> UIImage {
        guard let imageData = imageData else {
            return UIImage(named: "UnknownPlant")!
        }
        let loadedImage = UIImage(data: imageData)
        return loadedImage!
    }
    
    func displayedNextWaterDate(lastWateredDate: Date, waterHabit: Int) -> String {
        
        var nextWaterDate: Date {
            let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabit, to: lastWateredDate)
            return calculatedDate!
        }
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }
        
        var waterStatus: String {
            
            let dateIntervalFormat = DateComponentsFormatter()
            dateIntervalFormat.allowedUnits = .day
            dateIntervalFormat.unitsStyle = .short
            let formatted = dateIntervalFormat.string(from: Date.now, to: nextWaterDate) ?? ""
            if formatted == "0 days" || nextWaterDate < Date.now {
                return "due"
            } else if dateFormatter.string(from: lastWateredDate) == dateFormatter.string(from: Date.now) {
                return "\(waterHabit) days"
            } else {
                return "\(formatted)"
            }
            
        }
    
        return waterStatus
    }
    
}
