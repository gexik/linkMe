//
//  ViewController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 04.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = UIColor(red:0.30, green:0.44, blue:0.61, alpha:1.00)
        button.addTarget(self, action: #selector(handlePlusButton), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        tf.backgroundColor = .clear
        tf.textColor = .flatWhite
        tf.font = .systemFont(ofSize: 14)
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .emailAddress
        tf.keyboardAppearance = .dark
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf.leftViewMode = .always
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var userNameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        tf.backgroundColor = .clear
        tf.textColor = .flatWhite
        tf.font = .systemFont(ofSize: 14)
        tf.clearButtonMode = .whileEditing
        tf.keyboardAppearance = .dark
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf.leftViewMode = .always
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        tf.backgroundColor = .clear
        tf.textColor = .flatWhite
        tf.font = .systemFont(ofSize: 14)
        tf.clearButtonMode = .whileEditing
        tf.keyboardAppearance = .dark
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf.leftViewMode = .always
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.00)
        button.layer.cornerRadius = 8
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white , for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.alpha = 0.75
        button.isEnabled = false
        
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedText.append(NSAttributedString(string: "Sign In.", attributes:  [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor(red:0.30, green:0.44, blue:0.61, alpha:1.00)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAccountButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusButton.layer.cornerRadius = plusButton.frame.width/2
        plusButton.layer.masksToBounds = true
        plusButton.layer.borderColor = UIColor(white: 0, alpha: 0.25).cgColor
        plusButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePlusButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @objc func handleTextInputChange() {
        
        let isFormValid =
            emailTextField.text?.count ?? 0 > 0 &&
                userNameTextField.text?.count ?? 0 > 0 &&
                passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.alpha = 1
            signUpButton.isEnabled = true
        } else {
            signUpButton.alpha = 0.75
            signUpButton.isEnabled = false
        }
    }
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let username = userNameTextField.text, username.count > 0  else {return}
        guard let password = passwordTextField.text, password.count > 0  else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let err = error {
                print("Failed created user:", err)
                self.view.endEditing(true)
                let popup = PopupView()
                popup.showWithMessage(message: (err.localizedDescription))
                return
            }
            
            print("Successfully created user:", user?.uid ?? "")
            
            guard let image = self.plusButton.imageView?.image else {return}
            
            guard let uploadData = UIImageJPEGRepresentation(image, 1) else {return}
            
            let filename = NSUUID().uuidString
            
            Storage.storage().reference().child("profile_image").child(filename).putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if err != nil {

                }
                
                guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                print("Successfully uploaded profile image:", profileImageUrl)
                
                guard let uid = user?.uid else { return }
                
                let dictionaryValues = ["username": username,"profileImageUrl": profileImageUrl]
                let values = [uid: dictionaryValues]
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("Failed to save user into db", err)
                        return
                    }
                    
                    print("Successfully saved user into bd")
                    
                    guard let mainTabBarController =  UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                    mainTabBarController.setupViewControllers()
                    self.dismiss(animated: true, completion: nil)
                })
                
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        view.addSubview(plusButton)
        
        view.addSubview(alreadyHaveAccountButton)
        
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, buttom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        plusButton.anchor(top: view.topAnchor, left: nil, buttom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignView))
        
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func resignView() {
        view.endEditing(true)
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, userNameTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 0
        
        view.addSubview(stackView)

        let bgView = UIView()
        stackView.addSubview(bgView)
        stackView.sendSubview(toBack: bgView)
        bgView.backgroundColor = UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        bgView.layer.cornerRadius = 8
        bgView.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, buttom: stackView.bottomAnchor, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let separatorView1 = UIView()
        separatorView1.backgroundColor = UIColor(red:0.20, green:0.23, blue:0.27, alpha:1.00)
        bgView.addSubview(separatorView1)
        separatorView1.anchor(top: nil, left: bgView.leftAnchor, buttom: emailTextField.bottomAnchor, right: bgView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        let separatorView2 = UIView()
        separatorView2.backgroundColor = UIColor(red:0.20, green:0.23, blue:0.27, alpha:1.00)
        bgView.addSubview(separatorView2)
        separatorView2.anchor(top: nil, left: bgView.leftAnchor, buttom: userNameTextField.bottomAnchor, right: bgView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        
        stackView.anchor(top: plusButton.bottomAnchor, left: view.leftAnchor, buttom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
        
        
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, buttom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 48)
    }
}



