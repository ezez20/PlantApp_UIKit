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
    var qrCodeFrameView: UIView?
    
    var plants: [Plant]
    
    init(captureSession: AVCaptureSession = AVCaptureSession(), previewLayer: AVCaptureVideoPreviewLayer? = nil, qrCodeFrameView: UIView? = nil, plants: [Plant]) {
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
        self.qrCodeFrameView = qrCodeFrameView
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
        
        if metadataObjects.count == 0 {
            print("No QR code found")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr,
           let result = metadataObj.stringValue {
            
            let scanResult = result
            print("QR Code found \(scanResult)")
            
            for p in plants {
                if p.id?.uuidString == scanResult {
                    print("PLANT scanned: \(p.plant!)")
                }
            }
        }
    }
    
}
