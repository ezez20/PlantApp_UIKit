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
            
            
            // Set Water level status color on dropletImage
            let waterStatus = displayedNextWaterDate(lastWateredDate: plantIn.lastWateredDate!, waterHabit: Int(plantIn.waterHabit))
            
            if waterStatus.localizedStandardContains("today") {
                dropletImage.tintColor = .systemRed
            } else if waterStatus.localizedStandardContains("2") || waterStatus.localizedStandardContains("3"){
                dropletImage.tintColor = .systemYellow
            } else {
                dropletImage.tintColor = .systemGreen
            }
            
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
//        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
//        label.backgroundColor = .secondarySystemBackground
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
//        imageView.tintColor = .label
        return imageView
    }()
    
    let labelWaterDays: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byCharWrapping
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
        contentView.addSubview(dropletImage)
        contentView.addSubview(labelWaterDays)
        

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
    
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cellImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cellImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        cellImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        cellImageView.backgroundColor = .clear
        
        labelName.translatesAutoresizingMaskIntoConstraints = false
        labelName.topAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: 2).isActive = true
        labelName.centerXAnchor.constraint(equalTo: cellImageView.centerXAnchor).isActive = true
        labelName.widthAnchor.constraint(equalTo: cellImageView.widthAnchor).isActive = true
        
        
        dropletImage.translatesAutoresizingMaskIntoConstraints = false
        dropletImage.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 5).isActive = true
        dropletImage.centerXAnchor.constraint(equalTo: cellImageView.centerXAnchor).isActive = true
  
        labelWaterDays.translatesAutoresizingMaskIntoConstraints = false
        labelWaterDays.topAnchor.constraint(equalTo: dropletImage.bottomAnchor, constant: 2).isActive = true
        labelWaterDays.centerXAnchor.constraint(equalTo: cellImageView.centerXAnchor).isActive = true
        labelWaterDays.widthAnchor.constraint(equalTo: cellImageView.widthAnchor).isActive = true
        
        
//        labelName.frame = CGRect(x: 0,
//                                 y: cellImageView.bounds.maxY,
//                                 width: contentView.frame.size.width,
//                                 height: 20
//        )
//        labelName.backgroundColor = .clear
//        labelName.tintColor = .label
//
//        waterStatusView.frame = CGRect(x: cellImageView.bounds.midX - 30,
//                                   y:  cellImageView.bounds.maxY + CGFloat(20),
//                                   width: contentView.frame.size.width,
//                                   height: 20
//        )
//
//        waterStatusView.backgroundColor = .clear
//        waterStatusView.tintColor = .label
//        waterStatusView.addSubview(dropletImage)
//        dropletImage.frame = CGRect(x: 0,
//                                    y:  0,
//                                    width: 20,
//                                 height: 20
//        )
//
//        waterStatusView.addSubview(labelWaterDays)
//        labelWaterDays.frame = CGRect(x: dropletImage.frame.maxX,
//                                 y:  0,
//                                 width: contentView.frame.size.width / 2,
//                                 height: 20
//        )
        
    
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
                return "today"
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
            
            contentView.layer.opacity = 0.7
        } else {
            trashCanView.removeFromSuperview()
            contentView.layer.opacity = 1.0
        }
    }
    
    
}
