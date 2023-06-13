//
//  NotesTableViewCell.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 6/13/23.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    var plantImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.image = UIImage(named: K.unknownPlant)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var plantTextLabel = UILabel()
    
    var notesTextViewContrainer = UIView()
    var notesTextView = UITextView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .green
        self.layer.cornerRadius = 10
        
       
    }
    
    override func layoutSubviews() {
        setupPlantImageAndLabel()
        setupNotesTextfield()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension NotesTableViewCell {
    
    func setupPlantImageAndLabel() {
        addSubview(plantImageView)
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        plantImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        plantImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        plantImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        plantImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        plantImageView.clipsToBounds = true
        plantImageView.layer.cornerRadius = plantImageView.frame.size.width / 2
        
        addSubview(plantTextLabel)
        plantTextLabel.translatesAutoresizingMaskIntoConstraints = false
        plantTextLabel.leftAnchor.constraint(equalTo: plantImageView.rightAnchor, constant: 10).isActive = true
        plantTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        plantTextLabel.centerYAnchor.constraint(equalTo: plantImageView.centerYAnchor).isActive = true
        plantTextLabel.text = "Test Plant"
        plantTextLabel.backgroundColor = .systemGray
    }
    
    func setupNotesTextfield() {
        addSubview(notesTextViewContrainer)
        notesTextViewContrainer.translatesAutoresizingMaskIntoConstraints = false
        notesTextViewContrainer.topAnchor.constraint(equalTo: plantImageView.bottomAnchor, constant: 10).isActive = true
        notesTextViewContrainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        notesTextViewContrainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        notesTextViewContrainer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        notesTextViewContrainer.layer.cornerRadius = 10
        notesTextViewContrainer.backgroundColor = .white
        
        addSubview(notesTextView)
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.topAnchor.constraint(equalTo: notesTextViewContrainer.topAnchor, constant: 5).isActive = true
        notesTextView.leftAnchor.constraint(equalTo: notesTextViewContrainer.leftAnchor, constant: 5).isActive = true
        notesTextView.rightAnchor.constraint(equalTo: notesTextViewContrainer.rightAnchor, constant: -5).isActive = true
        notesTextView.bottomAnchor.constraint(equalTo: notesTextViewContrainer.bottomAnchor, constant: -5).isActive = true
        notesTextView.backgroundColor = .gray
        notesTextView.textAlignment = .left
    }
    
}

extension NotesTableViewCell: UITextFieldDelegate {
    
}
