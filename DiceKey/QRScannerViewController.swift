//
//  QRScannerViewController.swift
//  DiceKey
//
//  Created by Peter on 09/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, UITabBarControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    let uploadButton = UIButton()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var words = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.delegate = self
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        imagePicker.delegate = self
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                
                print("no camera")
                failed()
                throw error.noCameraAvailable
                
            }
            
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        } catch {
            
            failed()
            return
            
        }
        
        if (captureSession.canAddInput(videoInput)) {
            
            captureSession.addInput(videoInput)
            
        } else {
            
            failed()
            return
            
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } else {
            
            failed()
            return
            
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        addButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    func displayAlert(viewController: UIViewController, title: String, message: String) {
        print("displayAlert")
        
        DispatchQueue.main.async {
            
            let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            viewController.present(alertcontroller, animated: true, completion: nil)
            
        }
        
    }
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
    }
    
    func addButtons() {
        
        DispatchQueue.main.async {
            
            self.uploadButton.removeFromSuperview()
            self.uploadButton.showsTouchWhenHighlighted = true
            self.uploadButton.setTitleColor(UIColor.white, for: .normal)
            self.uploadButton.backgroundColor = UIColor.clear
            self.uploadButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
            self.uploadButton.frame = CGRect(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.width, height: 30)
            self.uploadButton.showsTouchWhenHighlighted = true
            self.uploadButton.titleLabel?.textAlignment = .center
            self.uploadButton.setTitle("Upload from photos", for: .normal)
            self.addShadow(view: self.uploadButton)
            self.uploadButton.addTarget(self, action: #selector(self.chooseQRCodeFromLibrary), for: .touchUpInside)
            self.view.addSubview(self.uploadButton)
            
            let label = UILabel()
            label.removeFromSuperview()
            label.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: 25)
            label.text = "Scan a recovery phrase, xpub or xprv"
            label.font = UIFont.init(name: "HelveticaNeue-Light", size: 20)
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
            self.addShadow(view: label)
            
            label.textColor = UIColor.white
            self.view.addSubview(label)
            
        }
        
    }
    
    func addShadow(view: UIView) {
        print("addShadow")
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        view.layer.shadowRadius = 2.5
        view.layer.shadowOpacity = 0.8
        
    }
    
    func failed() {
        print("failed")
        addButtons()
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
    }
    
    func found(code: String) {
        print(code)
        DispatchQueue.main.async {
            self.importKeys(string: code)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc func chooseQRCodeFromLibrary() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage = CIImage(image:pickedImage)!
            var qrCodeLink = ""
            let features = detector.features(in: ciImage)
            
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            print(qrCodeLink)
            
            if qrCodeLink != "" {
                
                DispatchQueue.main.async {
                    
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.importKeys(string: qrCodeLink)
                }
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func importKeys(string: String) {
        print("importKeys = \(string)")
        
        if !isInternetAvailable() {
            
            switch string.prefix(4) {
                
            case "xpub":
                print("its an xpub")
                
                Library.sharedInstance.xpub = string
                
                DispatchQueue.main.async {
                    
                    self.tabBarController?.selectedIndex = 0
                    
                }
                
            case "xprv":
                print("its an xprv")
                
                Library.sharedInstance.xprv = string
                
                DispatchQueue.main.async {
                    
                    self.tabBarController?.selectedIndex = 0
                    
                }
                
            case "zpub":
                print("its a zpub")
                
                displayAlert(viewController: self, title: "Error", message: "We do not yet support zpubs.")
                
            case "zprv":
                print("its a zprv")
                
                displayAlert(viewController: self, title: "Error", message: "We do not yet support zprvs")
                
            default:
                print("its a recovery phrase?")
                
                Library.sharedInstance.words = string
                
                DispatchQueue.main.async {
                    
                    self.tabBarController?.selectedIndex = 0
                    
                }
                
            }
            
        } else {
            
            displayAlert(viewController: self, title: "Put your device into airplane mode and turn wifi off to import keys", message: "The idea of this app is to keep your keys from ever touching the internet.")
            
        }
        
    }
    
}

extension QRScannerViewController  {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}
