//
//  LoginController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 08.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
       let view = UIView()
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo_login"))
        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        
        logoImageView.anchor(top: nil, left: nil, buttom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

      //  view.backgroundColor = UIColor(red:0.40, green:0.67, blue:0.36, alpha:1.00)
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 14)
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .emailAddress
        tf.keyboardAppearance = .dark
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf.leftViewMode = .always
        return tf
    }()

    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 14)
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf.leftViewMode = .always
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.00)
        button.layer.cornerRadius = 8
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white , for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.alpha = 0.75
        button.isEnabled = false
        
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "Dont't have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray])
        
        attributedText.append(NSAttributedString(string: "Sign Up.", attributes:  [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor(red:0.30, green:0.44, blue:0.61, alpha:1.00)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0  else {return}

        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.view.endEditing(true)
                let popup = PopupView()
                popup.showWithMessage(message: (error?.localizedDescription)!)
                return
            }
            
            print("User id:", user?.uid ?? "")
            
            self.view.endEditing(true)
            guard let mainTabBarController =  UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    @objc func handleTextInputChange() {
        
        let isFormValid =
            emailTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.alpha = 1
            loginButton.isEnabled = true
        } else {
            loginButton.alpha = 0.75
            loginButton.isEnabled = false
        }
    }
    
    @objc func signUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(dontHaveAccountButton)
        
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, buttom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        view.addSubview(logoContainerView)
        
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, buttom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        setupInputFields()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignView))
        
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc private func resignView() {
        view.endEditing(true)
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 1

        view.addSubview(stackView)
        
        let bgView = UIView()
        stackView.addSubview(bgView)
        stackView.sendSubview(toBack: bgView)
        bgView.backgroundColor = UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        bgView.layer.cornerRadius = 8
        bgView.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, buttom: stackView.bottomAnchor, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red:0.20, green:0.23, blue:0.27, alpha:1.00)
        bgView.addSubview(separatorView)
        separatorView.anchor(top: nil, left: stackView.leftAnchor, buttom: nil, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        separatorView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
        
        
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, buttom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 100)
        
        
        
        view.addSubview(loginButton)
        loginButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, buttom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 48)
        
        
        
        
        
    }
}
