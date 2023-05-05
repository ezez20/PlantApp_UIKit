//
//  QRScannerViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 4/29/23.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var plants: [Plant]
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var qrCodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemGreen.cgColor
        view.layer.borderWidth = 2
        
//        let imageView = UIImageView(image: UIImage(systemName: "camera.metering.center.weighted.average")?.withTintColor(.green))
//         imageView.contentMode = .scaleToFill
//        view.addSubview(imageView)
        return view
    }()
    
    var stackView: UIStackView = {
        let view = UIStackView()
        let uiImageViewDrop = UIImageView(image: UIImage(systemName: "drop")?.withTintColor(.label, renderingMode: .alwaysOriginal))
        uiImageViewDrop.contentMode = .scaleAspectFit
        view.addArrangedSubview(uiImageViewDrop)
        
        uiImageViewDrop.translatesAutoresizingMaskIntoConstraints = false
        uiImageViewDrop.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.backgroundColor = .secondarySystemBackground
        view.layer.opacity = 0.9
        view.layer.cornerRadius = 10
     
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.spacing = 5
        view.translatesAutoresizingMaskIntoConstraints = false
    
        return view
    }()
    
    var waterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
    
    var plantLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
//        label.frame.size = CGSize(width: 100, height: 40)
        return label
    }()
    
    var waterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "drop.circle")?.withTintColor(.blue), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
//        button.contentMode = .scaleAspectFit
        return button
    }()
    
//    let cameraFrame: UIImageView = {
//       let imageView = UIImageView(image: UIImage(systemName: "camera.metering.center.weighted.average")?.withTintColor(.green))
//        imageView.contentMode = .scaleToFill
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()

    
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
        print("Metadata found")
        
        guard metadataObjects.count != 0 else {
            print("No QR code found")
            qrCodeFrameView.removeFromSuperview()
            waterButton.removeFromSuperview()
            stackView.removeFromSuperview()
          
            return
        }
        
        
        // Get the metadata object.
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
        
        addQRCodeFrameView(barCodeObject: barCodeObject!)
        addWaterButton()
        addStackView(barCodeObject: barCodeObject!)
        
        if metadataObject.type == AVMetadataObject.ObjectType.qr, let result = metadataObject.stringValue {
            
            let scannedResult = result
            print("QR Code found \(scannedResult)")
            
            for p in plants {
                
                // If QR Result matches
                if p.id?.uuidString == scannedResult {
                    
                    scannedQRMatchedPlant = true
                    scannedPlant = p.plant!
                    
                    waterHabitIn = Int(p.waterHabit)
                    lastWateredDateIn = p.lastWateredDate!
                    
                    print("PLANT scanned: \(p.plant!)")
                   
                    plantLabel.text = scannedPlant
                    waterLabel.text = "\(waterStatus)"
                    stackView.frame.size.width = plantLabel.frame.width
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
    
    func addQRCodeFrameView(barCodeObject: AVMetadataObject) {
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
        qrCodeFrameView.frame = barCodeObject.bounds
    }

    
    func addStackView(barCodeObject: AVMetadataObject) {
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: qrCodeFrameView.bottomAnchor, constant: 10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackView.centerXAnchor.constraint(equalTo: qrCodeFrameView.centerXAnchor).isActive = true

        // Second ArrangedSubview:
        stackView.addArrangedSubview(waterLabel)
        
        // Second ArrangedSubview:
        stackView.addArrangedSubview(plantLabel)
        plantLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10).isActive = true
        plantLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10).isActive = true
        
        plantLabel.sizeToFit()

    }
    
    func addWaterButton() {
        view.addSubview(waterButton)
        view.bringSubviewToFront(waterButton)
        waterButton.translatesAutoresizingMaskIntoConstraints = false
        waterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true

    }
    
    
}
