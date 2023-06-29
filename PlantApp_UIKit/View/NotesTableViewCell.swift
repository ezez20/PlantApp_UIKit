//
//  NotesTableViewCell.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 6/13/23.
//

import UIKit
import Network
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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

    private let loadingSpinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.color = .white
        return spinner
    }()
    
    weak var plant: Plant?
    let networkMonitor = NWPathMonitor()
    
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
        notesTextView.tintColor = UIColor(named: K.customGreen2)

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

extension NotesTableViewCell {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func editPlant_FB(_ currentPlantID: UUID) {
        
        addLoadingView()
        
        networkConnectionBool { [self] boolIn in
            
            if boolIn {
                print("boolIn: true")
                
                DispatchQueue.main.async { [self] in
                    
                    
                    let db = Firestore.firestore()
                    
                    //2: FIREBASE: Get currentUser UID to use as document's ID.
                    guard let currentUser = Auth.auth().currentUser?.uid else { return }
                    
                    let userFireBase = db.collection("users").document(currentUser)
                    
                    //3: FIREBASE: Declare collection("plants)
                    let plantCollection =  userFireBase.collection("plants")
                    
                    //4: FIREBASE: Plant entity input
                    let plantEditedData: [String: Any] = [
                        "plantNotes": ""
                    ]
                    
                    // 5: FIREBASE: Set doucment name(use index# to later use in core data)
                    let plantDoc = plantCollection.document("\(plant!.id!.uuidString)")
                    print("plantDoc edited uuid: \(currentPlantID.uuidString)")
                    
                    // 6: Edited data for "Plant entity input"
                    plantDoc.updateData(plantEditedData) { error in
                        if error != nil {
//                            K.presentAlert(self, error!)
                            print("Error updating data on FB: \(String(describing: error))")
                        }
                    }
                    
                    // 7: Add edited doc date on FB
                    plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                        if error != nil {
//                            K.presentAlert(self, error!)
                            print("Error updating data on FB: \(String(describing: error))")
                        }
                    }
                    
                    
                    print("Plant successfully edited on Firebase")
                    
                }
                
            } else {
                print("boolIn: false")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error uploading plant:", message: "Please try again or check your network.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                        self.removeLoadingView()
                    }))
                    
//                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func addLoadingView() {
        DispatchQueue.main.async { [self] in
            loadingSpinnerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(loadingSpinnerView)
            loadingSpinnerView.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor).isActive = true
            loadingSpinnerView.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor).isActive = true
            loadingSpinnerView.startAnimating()
            saveButton.isHidden = true
            print("addLoadingView")
        }
    }
    
    func removeLoadingView() {
        DispatchQueue.main.async {
            self.loadingSpinnerView.stopAnimating()
            self.loadingSpinnerView.removeFromSuperview()
            print("removedLoadingView")
        }
    }
    
    func networkConnectionBool(completion: @escaping (Bool) -> Void) {
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
        
        networkMonitor.pathUpdateHandler = { path in
           if path.status == .satisfied {
              print("Network Connected")
               self.networkMonitor.cancel()
               completion(true)
           } else {
              print("Network Disconnected")
               self.networkMonitor.cancel()
               completion(false)
           }
            print("path.isExpensive: \(path.isExpensive)"
            )
        }
      
    }
    
    
}
