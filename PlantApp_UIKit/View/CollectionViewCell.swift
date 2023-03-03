//
//  CollectionViewCell.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 3/3/23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    let imageIn = UIImage()
    
    var cellImageView: UIImageView {
        let imageView = UIImageView()
        imageView.image = imageIn
        return imageView
    }
    
   
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(cellImageView)
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cellImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cellImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
}
