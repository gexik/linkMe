//
//  PreviewPhotoContainerView.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 28.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
       let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let seveButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "saveButton"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        addSubview(seveButton)
        addSubview(cancelButton)
        
        previewImageView.anchor(top: topAnchor, left: leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        cancelButton.anchor(top: nil, left: leftAnchor, buttom: nil, right: seveButton.leftAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 50)
        cancelButton.centerYAnchor.constraint(equalTo: seveButton.centerYAnchor).isActive = true
        
        seveButton.anchor(top: nil, left: nil, buttom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 40, height: 40)
        seveButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc func handleSave() {
       guard let previewImage = previewImageView.image else {return}
        
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({
            
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        }) { (success, error) in
            
        }
        
        DispatchQueue.main.async {
            let savedLabel = UILabel()
            savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
            savedLabel.text = "Photo saved"
            savedLabel.textColor = .white
            savedLabel.textAlignment = .center
            savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
            savedLabel.layer.cornerRadius = 5
            savedLabel.clipsToBounds = true
            savedLabel.center = self.center
            
            self.addSubview(savedLabel)
            
            savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { 
                savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)

            }, completion: { (complition) in
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { 
                    savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    savedLabel.alpha = 0

                }, completion: { (complited) in
                    savedLabel.removeFromSuperview()
                })
            })
        }
    }
}
