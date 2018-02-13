//
//  SharePhotoController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SharePhotoController: UIViewController {
    
    let imageView: UIImageView = {
        let im = UIImageView()
        im.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00)
        im.contentMode = .scaleAspectFill
        im.clipsToBounds = true
        return im
    }()
    
    let textView: UITextView = {
        let tx = UITextView()
        tx.font = .systemFont(ofSize: 14)
        tx.backgroundColor = UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        tx.keyboardAppearance = .dark
        tx.textColor = .white
        return tx
    }()
    
    let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.progressViewStyle = .bar
        pv.progressTintColor = UIColor.flatGreen
        return pv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageViewAndTextView()
    }
    
    fileprivate func setupImageViewAndTextView() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, buttom: nil, right: view.rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, buttom: containerView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 80, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, buttom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
        textView.becomeFirstResponder()
        
        view.addSubview(progressView)
        progressView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, buttom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
    }
    
    @objc func handleShare() {
        let filename = NSUUID().uuidString
     //   guard let caption = textView.text, caption.characters.count > 0 else { return }
        guard let image = imageView.image else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", error ?? "")
                return
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            print("Successfully to upload post image:", imageUrl)
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
        
        _ = uploadTask.observe(.progress) { snapshot in
            print(snapshot.progress ?? "") // NSProgress object
            self.progressView.observedProgress = snapshot.progress
        }
        

    }
    static let updateFeedNotificationName = Notification.Name(rawValue: "UpdateFeed")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = imageView.image else { return }
        guard let caption = textView.text else { return }

        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": NSDate().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post image:", error ?? "")
                return
            }
            
            print("Successfully to save post image:", imageUrl)
            
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
}
