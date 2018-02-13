//
//  CameraController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 25.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCaptureSession()
        setupHUD()
    }

    let customAnimationPresenter = CustomAnimationPresenter()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresenter
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, buttom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 15, paddingRight: 0, width: 100, height: 100)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: nil, left: view.leftAnchor, buttom: nil, right: capturePhotoButton.leftAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 50)
        dismissButton.centerYAnchor.constraint(equalTo: capturePhotoButton.centerYAnchor).isActive = true
    }
    
    let output = AVCapturePhotoOutput()
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        //1. setup inputs
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }
        
        //2. setup outputs
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        //3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        
        let previewImage = UIImage(data: imageData!)
        
        let containerView = PreviewPhotoContainerView()
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, buttom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        containerView.previewImageView.image = previewImage
    }
    
    @objc func handleCapturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        guard let previewPhotoPixelFormat = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormat]
        
        output.capturePhoto(with: settings, delegate: self)

    }
    
}
