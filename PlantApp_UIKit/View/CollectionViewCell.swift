//
//  CollectionViewCell.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 3/3/23.
//

import UIKit

@available(iOS 15, *)
class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "collectionCellID"
    
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
        imageView.tintColor = .label
        return imageView
    }()
    
    let labelWaterDays: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.clipsToBounds = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let trashCanView: UIImageView = {
        let x = UIImageView()
        x.image = UIImage(systemName: "minus.circle.fill")?.withRenderingMode(.alwaysOriginal)
        x.tintColor = .systemRed
        x.contentMode = .scaleAspectFit
        return x
    }()
    
    var deleteView = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Sets collectionViewCell color based on Light/Dark Appearance
        if traitCollection.userInterfaceStyle == .light {
            contentView.backgroundColor = .white
        } else {
            contentView.backgroundColor = .secondarySystemBackground
        }
        
        contentView.clipsToBounds = true
        contentView.addSubview(cellImageView)
        contentView.addSubview(labelName)
        contentView.addSubview(waterStatusView)

        NotificationCenter.default.addObserver(self, selector: #selector(toggleDeleteView), name: NSNotification.Name("toggleDeleteViewNoti"), object: nil)
    }
    
    // Sets collectionViewCell color based on Light/Dark Appearance switch.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .light {
            contentView.backgroundColor = .white
        } else {
            contentView.backgroundColor = .secondarySystemBackground
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CollectionViewCell deinitialized.")
    }
    
   
    override func layoutSubviews() {
        
        cellImageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: contentView.frame.size.width,
                                     height: contentView.frame.size.height / CGFloat(1.5)
        )
        cellImageView.backgroundColor = .clear
        
        labelName.frame = CGRect(x: 0,
                                 y: cellImageView.bounds.maxY,
                                 width: contentView.frame.size.width,
                                 height: 20
        )
        labelName.backgroundColor = .clear
        labelName.tintColor = .label
       
        waterStatusView.frame = CGRect(x: cellImageView.bounds.midX - 30,
                                   y:  cellImageView.bounds.maxY + CGFloat(20),
                                   width: contentView.frame.size.width,
                                   height: 20
        )
        waterStatusView.backgroundColor = .clear
        waterStatusView.tintColor = .label
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
    
    
}

@available(iOS 15, *)
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
    
    @objc func toggleDeleteView() {
    
        deleteView.toggle()
        if deleteView {
            print("addingview")
            trashCanView.frame = CGRect(origin: cellImageView.center, size: CGSize(width: 30, height: 30))
            trashCanView.center = cellImageView.center
            contentView.addSubview(trashCanView)
        } else {
            trashCanView.removeFromSuperview()
        }
    }
    
    
}
