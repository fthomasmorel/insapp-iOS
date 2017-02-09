//
//  BarCodeViewController.swift
//  Insapp
//
//  Created by Guillaume Courtet on 30/01/2017.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//


import UIKit
import AVFoundation

class CameraView: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        get {
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
}

class BarCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var parentView: UserViewController!
    
    @IBOutlet weak var cameraViewCanvas: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    // Camera view
    var cameraView: CameraView?
    
    var codeFrameView: UIView?
    
    
    // AV capture session and dispatch queue
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraView = CameraView()
        self.cameraView?.frame = self.cameraViewCanvas.frame
        self.cameraViewCanvas.addSubview(cameraView!)
        
        
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if (videoDevice != nil) {
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
            
            if (videoDeviceInput != nil) {
                if (session.canAddInput(videoDeviceInput)) {
                    session.addInput(videoDeviceInput)
                }
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                
                metadataOutput.metadataObjectTypes = [
                    AVMetadataObjectTypeCode128Code
                ]

                
                session.sessionPreset = AVCaptureSessionPreset640x480
                let scanRectTransformed = CGRect(x: 0.4, y: 0.0, width: 0.2, height: 1.0)
                metadataOutput.rectOfInterest = scanRectTransformed
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
            
            if(videoDevice!.isFocusModeSupported(.continuousAutoFocus)) {
                try! videoDevice!.lockForConfiguration()
                videoDevice!.focusMode = .continuousAutoFocus
                videoDevice!.unlockForConfiguration()
            }
        }
        
        session.commitConfiguration()
        
        self.cameraView?.layer.session = session
        self.cameraView?.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Set initial camera orientation
        self.cameraView?.layer.connection.videoOrientation = .portrait
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start AV capture session
        sessionQueue.async {
            self.session.startRunning()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop AV capture session
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update camera orientation
        cameraView?.layer.connection.videoOrientation = .portrait
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Display barcode value
        if (metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject) {
            
            self.session.stopRunning()
            let scan = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            
            let alertController = UIAlertController(title: "Barcode Scanned", message: scan.stringValue, preferredStyle: .alert)
            
            let cancelHandler = { (action:UIAlertAction!) -> Void in
                self.parentView.loadCode(code: scan.stringValue)
                self.dismiss(animated: true, completion: nil)
                
                return
            }
            
            let rescanHandler = { (action:UIAlertAction!) -> Void in
                self.session.startRunning()
                return
            }
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: cancelHandler))
            alertController.addAction(UIAlertAction(title: "Re-scan", style: .cancel, handler: rescanHandler))
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

