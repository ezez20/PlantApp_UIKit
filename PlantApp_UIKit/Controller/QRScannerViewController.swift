//
//  QRScannerViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 4/29/23.
//

import UIKit
import AVFoundation
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var plants: [Plant]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var scannedPlantUUID = ""
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var qrCodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemGreen.cgColor
        view.layer.borderWidth = 2

        return view
    }()
    
    var plantFrameView: UIView = {
        let view = UIView()

        return view
    }()
    
    var stackView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.opacity = 0.9
        view.layer.cornerRadius = 10
     
        view.axis = .vertical
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        
    
        return view
    }()
    
    var uiImageViewDrop: UIImageView = {
        let uiImageViewDrop = UIImageView(image: UIImage(systemName: "drop")?.withTintColor(.label, renderingMode: .alwaysOriginal))
        uiImageViewDrop.contentMode = .scaleAspectFit
//        uiImageViewDrop.backgroundColor = .gray
        return uiImageViewDrop
    }()
    
    var waterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
//        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
    
    var plantLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
//        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
//        label.frame.size.height = 20
        return label
    }()
    
    var waterButton: UIButton = {
        let button = UIButton(type: .system)
        let dropCircleImage = UIImage(systemName: "drop.circle")?.withRenderingMode(.alwaysTemplate)
        button.setImage(dropCircleImage, for: .normal)
        button.tintColor = UIColor(named: K.custom_blue_1)
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
//        button.contentMode = .scaleAspectFit
        return button
    }()
    
    var qrCodeScanned = false
    var scannedQRMatchedPlant = false
    var scannedPlant = ""
    var waterDays = 0
    var waterHabitIn = 0
    var lastWateredDateIn = Date()
    let currentDate = Date.now
    var nextWaterDate: Date {
        var date = Date()
        if let calculatedDate = Calendar.current.date(byAdding: Calendar.Component.day, value: waterHabitIn, to:  lastWateredDateIn) {
            date = calculatedDate
        }
        return date
    }
    var waterStatus: String {
        
        let dateIntervalFormat = DateComponentsFormatter()
        dateIntervalFormat.allowedUnits = .day
        dateIntervalFormat.unitsStyle = .short
        let formatted = dateIntervalFormat.string(from: currentDate, to: nextWaterDate) ?? ""
        if formatted == "0 days" || nextWaterDate < currentDate {
            return "):"
        } else if dateFormatter.string(from:  lastWateredDateIn) == dateFormatter.string(from: currentDate) {
            return "in \(waterHabitIn) days"
        } else {
            return "in: \(formatted)"
        }
        
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    
    init(captureSession: AVCaptureSession = AVCaptureSession(), previewLayer: AVCaptureVideoPreviewLayer? = nil, plants: [Plant]) {
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
        self.plants = plants
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCaptureSession()

    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate functions
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
        guard metadataObjects.count != 0 else {
            print("No QR code found")
            qrCodeFrameView.removeFromSuperview()
            waterButton.removeFromSuperview()
            stackView.removeFromSuperview()
            qrCodeFrameView.willRemoveSubview(plantFrameView)
            
            
            qrCodeScanned = false
           
            return
        }
        
        // Get the metadata object.
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
        qrCodeFrameView.frame = barCodeObject!.bounds
        
        // This will stop the loop for the above codes since "metadataOutput function" always runs when there is a QR code.
        // This is to prevent "addQRCodeFrameView, addWaterButton, addStackView" from being added every time during the loop.
        if qrCodeScanned == true {
            return
        }
        
        print("New Metadata found")
        qrCodeScanned = true
        
        // If QR code is detected, add the QR code frame view.
        addQRCodeFrameView()
        
        // If metadataObject matches user's plant, add "addWaterButton, addStackView" view.
        if metadataObject.type == AVMetadataObject.ObjectType.qr, let result = metadataObject.stringValue {
            
            let scannedResult = result
            print("QR Code found:  \(scannedResult)")
            
            for p in plants {
                
                // If QR Result matches
                if p.id?.uuidString == scannedResult {
                    
                    addWaterButton()
                    addStackView()
                    
                    addPlantPhotoToFrameView(plant: p)
                    
                    scannedQRMatchedPlant = true
                    scannedPlant = p.plant!
                    scannedPlantUUID = p.id!.uuidString
                    
                    waterHabitIn = Int(p.waterHabit)
                    lastWateredDateIn = p.lastWateredDate!
                    
                    plantLabel.text = scannedPlant
                    waterLabel.text = "\(waterStatus)"
                    
//                    waterHabitIn = Int(p.waterHabit)
//                    lastWateredDateIn = p.lastWateredDate!
                    
                    print("PLANT scanned: \(p.plant!)")
                     
                   
//                    plantLabel.text = scannedPlant
//                    waterLabel.text = "\(waterStatus)"
//                    stackView.frame.size.width = plantLabel.frame.width + 10
                  
                }
            }
            
        }
        
    }
    
    
}

extension QRScannerViewController {
    
    func setupCaptureSession() {
        
        // 1: Set Capture Device
        if let frontCameraDevice = AVCaptureDevice.default(for: .video) {

            // 2: Set video input from capture device.
            let videoInput: AVCaptureDeviceInput
            
            
            do {
                videoInput = try AVCaptureDeviceInput(device: frontCameraDevice)
                captureSession.addInput(videoInput)
            
            } catch {
                print("Error capturing videoInput from AVCaptureDeviceInput. Error: \(error) ")
            }
            
        }
        
        // 3: Set metadata from capture session.
        let capturedMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(capturedMetadataOutput)
        
        // 4: Set the delegate and type of metadata for output
        capturedMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        capturedMetadataOutput.metadataObjectTypes = [.qr]
        
        // 5: Add previewLayer to view.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer!)
        
        
        // 6: Start video capture session
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
    }
    
    func addQRCodeFrameView() {
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
//        qrCodeFrameView.frame = barCodeObject.bounds
    }
    
    func addPlantPhotoToFrameView(plant: Plant) {
        print("Deez")
        qrCodeFrameView.addSubview(plantFrameView)
        
        let plantImageView = UIImageView()
        plantFrameView.addSubview(plantImageView)
        plantImageView.layer.cornerRadius = 10
        plantImageView.backgroundColor = .secondarySystemBackground
        
        
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        plantImageView.topAnchor.constraint(equalTo: qrCodeFrameView.topAnchor, constant: 5).isActive = true
        plantImageView.bottomAnchor.constraint(equalTo: qrCodeFrameView.bottomAnchor, constant: -5).isActive = true
        plantImageView.leftAnchor.constraint(equalTo: qrCodeFrameView.leftAnchor, constant: 5).isActive = true
        plantImageView.rightAnchor.constraint(equalTo: qrCodeFrameView.rightAnchor, constant: -5).isActive = true
        
        
        if K.imageSetNames.contains(plant.plantImageString!) {
            plantImageView.image = UIImage(named: plant.plantImageString!)
        } else {
            plantImageView.image = loadedImage(with: plant.imageData)
        }
        
    }
    
    func loadedImage(with imageData: Data?) -> UIImage {
        guard let imageData = imageData else {
            print("loaded image = unknown")
            return UIImage(named: K.unknownPlant)!
            
        }
        let loadedImage = UIImage(data: imageData)
        return loadedImage!
    }

    
    func addStackView() {
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: qrCodeFrameView.bottomAnchor, constant: 10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackView.centerXAnchor.constraint(equalTo: qrCodeFrameView.centerXAnchor).isActive = true
        
        // First ArrangedSubview:
        stackView.addArrangedSubview(uiImageViewDrop)
        uiImageViewDrop.translatesAutoresizingMaskIntoConstraints = false
        uiImageViewDrop.heightAnchor.constraint(equalToConstant: 20).isActive = true
        uiImageViewDrop.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        uiImageViewDrop.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0).isActive = true
        uiImageViewDrop.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0).isActive = true
//        uiImageViewDrop.backgroundColor = .green
        uiImageViewDrop.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true

        // Second ArrangedSubview:
        stackView.addArrangedSubview(waterLabel)
        waterLabel.translatesAutoresizingMaskIntoConstraints = false
        waterLabel.topAnchor.constraint(equalTo: uiImageViewDrop.bottomAnchor).isActive = true
        waterLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
//        waterLabel.backgroundColor = .red

        // Third ArrangedSubview:
        stackView.addArrangedSubview(plantLabel)
        plantLabel.translatesAutoresizingMaskIntoConstraints = false
        plantLabel.topAnchor.constraint(equalTo: waterLabel.bottomAnchor, constant: 5).isActive = true
        plantLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        

        if plantLabel.frame.width < waterLabel.frame.width {
            waterLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10).isActive = true
            waterLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10).isActive = true
  
           print("DDD1: plantLabel width\(plantLabel.frame.width)")
            print("DDD1: waterLabel width\(waterLabel.frame.width)")
        } else {
            plantLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10).isActive = true
            plantLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10).isActive = true

            print("DDD2: plantLabel width\(plantLabel.frame.width)")
             print("DDD2: waterLabel width\(waterLabel.frame.width)")

        }

    }
    
    func addWaterButton() {
        view.addSubview(waterButton)
        view.bringSubviewToFront(waterButton)
        waterButton.translatesAutoresizingMaskIntoConstraints = false
        waterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        waterButton.addTarget(self, action: #selector(waterButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc func waterButtonPressed(sender: Any) {
        for p in plants {
            if p.id?.uuidString == scannedPlantUUID {
                p.lastWateredDate = Date.now
                savePlant()
                editPlant_FB(p.id)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserNotification"), object: nil)
                
                print("Water button pressed.")
                print("Water: \(p.plant!)")
                
                // This will refresh and re-add views for QRCode.
                qrCodeScanned = false
            }
        }
      
    }
    
    func savePlant() {
        // update currentPlant on Core Data
        do {
            try context.save()
        } catch {
            print("Error updating plant. Error: \(error)")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "triggerLoadPlants"), object: nil)
    }
    
//    func updateUI(plant: Plant) {
//        waterHabitIn = Int(plant.waterHabit)
//        lastWateredDateIn = plant.lastWateredDate!
//    }
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    func editPlant_FB(_ currentPlantID: UUID?) {
        if authenticateFBUser() {
            
            guard let currentPlantIDString = currentPlantID?.uuidString else { return }
            
            let db = Firestore.firestore()
            
            //2: FIREBASE: Get currentUser UID to use as document's ID.
            guard let currentUser = Auth.auth().currentUser?.uid else {return}
            
            let userFireBase = db.collection("users").document(currentUser)
            
            //3: FIREBASE: Declare collection("plants)
            let plantCollection =  userFireBase.collection("plants")
            
            
            //4: FIREBASE: Plant entity input
            let plantEditedData: [String: Any] = [
                "lastWatered": Date.now
//                "wateredBool": wateredBool,
            ]
            
            // 5: FIREBASE: Set doucment name(use index# to later use in core data)
            let plantDoc = plantCollection.document("\(currentPlantIDString)")
            print("plantDoc edited uuid: \(currentPlantIDString)")
            
            // 6: Edited data for "Plant entity input"
            plantDoc.updateData(plantEditedData) { error in
                if error != nil {
                    print("FB Update Data error. Error: \(String(describing: error))")
                }
            }
            
            // 7: Add edited doc date on FB
            plantDoc.setData(["Edited Doc date": Date.now], merge: true) { error in
                if error != nil {
                    print("FB error setting data. Error: \(String(describing: error))")
                }
            }
            
            print("Plant successfully edited on Firebase")
        }
    }
    
    
}
