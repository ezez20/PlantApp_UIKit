//
//  QRScannerViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 4/29/23.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var plants: [Plant]
    
    var qrCodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemYellow.cgColor
        view.layer.borderWidth = 2
        return view
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
    
    init(captureSession: AVCaptureSession = AVCaptureSession(), previewLayer: AVCaptureVideoPreviewLayer? = nil, plants: [Plant]) {
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
//        self.qrCodeFrameView = qrCodeFrameView!
        self.plants = plants
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 1: Set Capture Device
        if let frontCameraDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {

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
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("Metadata found")
        
        guard metadataObjects.count != 0 else {
            print("No QR code found")
            qrCodeFrameView.removeFromSuperview()
            resultLabel.layer.removeFromSuperlayer()
            return
        }
        
        addQRCodeFrameView()
        addResultLabelView()
        
        // Get the metadata object.
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
        qrCodeFrameView.frame = barCodeObject!.bounds
        
        if metadataObject.type == AVMetadataObject.ObjectType.qr, let result = metadataObject.stringValue {
            
            let scannedResult = result
            print("QR Code found \(scannedResult)")
            
            for p in plants {
                
                // If QR Result matches
                if p.id?.uuidString == scannedResult {
                    
                    scannedQRMatchedPlant = true
                    scannedPlant = p.plant!
                    print("PLANT scanned: \(p.plant!)")
                   
                    showQRFrameView(scannedResult: scannedPlant)
                }
            }
            
        }
    }
    
    func addQRCodeFrameView() {
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
    }
    
    func addResultLabelView() {
        // Bring the label to the front of the preview layer
        previewLayer?.insertSublayer(resultLabel.layer, above: previewLayer)
    }
    
    func showQRFrameView(scannedResult: String) {
        resultLabel.text = scannedResult
        resultLabel.sizeToFit()
        resultLabel.isHidden = false
        resultLabel.frame.origin = CGPoint(x: qrCodeFrameView.frame.minX + ( (qrCodeFrameView.frame.width - resultLabel.frame.width) / 2), y: qrCodeFrameView.frame.maxY + 10)
        resultLabel.frame.size.width = resultLabel.frame.width + 10
    }
    
}
