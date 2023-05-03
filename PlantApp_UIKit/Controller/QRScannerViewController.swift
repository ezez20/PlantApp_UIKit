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
        return view
    }()
    
    var stackView: UIStackView = {
        let view = UIStackView()
        let UIImageViewDrop = UIImageView(image: UIImage(systemName: "drop.circle")?.withTintColor(.blue))
        view.addArrangedSubview(UIImageViewDrop)
        view.frame.size = CGSize(width: 200, height: 100)
        view.backgroundColor = .tertiaryLabel
        view.axis = .vertical
        return view
    }()
    
    var stackViewLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
    
  
    var resultLabel: UILabel = {
        var labelView = UILabel()
        labelView = UILabel()
        labelView.textColor = UIColor.white
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.font = UIFont.systemFont(ofSize: 20)
        labelView.backgroundColor = .tertiaryLabel
        labelView.clipsToBounds = true
        labelView.layer.cornerRadius = 4
        return labelView
    }()
    
    var scannedQRMatchedPlant = false
    var scannedPlant = ""
    
    var waterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "drop.circle")?.withTintColor(.blue), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
//        button.contentMode = .scaleAspectFit
        return button
    }()
    
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
            resultLabel.layer.removeFromSuperlayer()
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
                    print("PLANT scanned: \(p.plant!)")
                   
//                    showResultLabelView(scannedResult: scannedPlant)
                    stackViewLabel.text = scannedPlant
  
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

    
    func showResultLabelView(scannedResult: String) {
        resultLabel.text = scannedResult
        resultLabel.sizeToFit()
        resultLabel.isHidden = false
        
        // Centers label below QR Code scanned.
        resultLabel.frame.origin = CGPoint(x: qrCodeFrameView.frame.minX + ( (qrCodeFrameView.frame.width - resultLabel.frame.width) / 2), y: qrCodeFrameView.frame.maxY + 10)
        // Adds padding to label's frame
        resultLabel.frame.size.width = resultLabel.frame.width + 10
        
        // Bring the label to the front of the preview layer
        previewLayer?.insertSublayer(resultLabel.layer, above: previewLayer)
    }
    
    func addStackView(barCodeObject: AVMetadataObject) {
        view.addSubview(stackView)
        view.bringSubviewToFront(qrCodeFrameView)
        stackView.frame.origin = CGPoint(x: qrCodeFrameView.frame.minX + ( (qrCodeFrameView.frame.width - stackView.frame.width) / 2), y: qrCodeFrameView.frame.maxY + 10)
        stackView.addArrangedSubview(stackViewLabel)
    }
    
    func addWaterButton() {
        view.addSubview(waterButton)
        view.bringSubviewToFront(waterButton)
        waterButton.translatesAutoresizingMaskIntoConstraints = false
        waterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true

    }
    
}
