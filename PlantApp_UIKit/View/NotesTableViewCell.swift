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
    var saveButton = UIButton()
    
    weak var plant: Plant?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        self.layer.cornerRadius = 10
        selectionStyle = .none
        
    }
    
    override func layoutSubviews() {
        setupPlantImageAndLabel()
        setupNotesTextfield()
        addSaveButton()
        loadPlant()
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
//        plantTextLabel.text = "Test Plant"
//        plantTextLabel.backgroundColor = .systemGray
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
        notesTextView.backgroundColor = .secondarySystemBackground
        notesTextView.layer.cornerRadius = 10
        notesTextView.textAlignment = .left
        notesTextView.font = .systemFont(ofSize: 15)
        notesTextView.text = "Add a note..."
        notesTextView.textColor = UIColor.lightGray

        notesTextView.delegate = self
        
    }
    
    func addSaveButton() {
        addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.topAnchor.constraint(equalTo: notesTextViewContrainer.bottomAnchor, constant: 5).isActive = true
        saveButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.systemCyan, for: .normal)
        saveButton.setTitleColor(.systemGray, for: .disabled)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveButtonPressed(sender:)), for: .touchUpInside)
        
    }
    
    func loadPlant() {
        plantTextLabel.text = plant?.plant
        
        if K.imageSetNames.contains((plant?.plantImageString)!) {
            plantImageView.image = UIImage(named: (plant?.plantImageString)!)
        } else {
            plantImageView.image = loadedImage(with: plant?.imageData)
        }
    }
    
    func loadedImage(with imageData: Data?) -> UIImage {
        guard let imageData = imageData else {
            return UIImage(named: "UnknownPlant")!
        }
        let loadedImage = UIImage(data: imageData)
        return loadedImage!
    }
    
    @objc func saveButtonPressed(sender: UIButton) {
        print("saveButtonPressed")
    }
    
}

extension NotesTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
   
        print("textViewDidBeginEditing")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note..."
            textView.textColor = UIColor.lightGray
        }
    
        print("textViewDidEndEditing")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateNotesEntry()
    }
    
    func validateNotesEntry() {
        if notesTextView.hasText && notesTextView.text != "Add a note..." {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}
