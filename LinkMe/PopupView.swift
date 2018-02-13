//
//  PopupView.swift
//  Link-Me
//
//  Created by Roman Bogomolov on 09.05.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit

class PopupView: UIView {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .white
        textView.textAlignment = .right
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
     //   button.backgroundColor = .green
        return button
    }()
    
    let blurEffectView: UIVisualEffectView = {
        let window = UIApplication.shared.keyWindow!
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    fileprivate func commonInitWithSize(size: CGSize) {
        layer.cornerRadius = 8
        alpha = 0
        blurEffectView.alpha = 0
        
        guard let window = UIApplication.shared.keyWindow else {return}

        window.addSubview(blurEffectView)
        
        window.addSubview(self)
        
        anchor(top: nil, left: nil, buttom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 220, height: size.height + 70)
        centerXAnchor.constraint(equalTo: (window.centerXAnchor)).isActive = true
        centerYAnchor.constraint(equalTo: (window.centerYAnchor)).isActive = true
        
        backgroundColor = UIColor(red:0.08, green:0.09, blue:0.12, alpha:1.00)
        
        addSubview(messageTextView)
        addSubview(dismissButton)
        messageTextView.anchor(top: topAnchor, left: leftAnchor, buttom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: size.height + 20)
        dismissButton.anchor(top: messageTextView.bottomAnchor, left: leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        
        layoutIfNeeded()
        
        animateIn()
    }
    
    func showWithMessage(message: String) {
        let textSize = message.boundingRect(with: CGSize(width: 220 - 10, height: 1000), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
        self.messageTextView.text = message

        commonInitWithSize(size: textSize.size)
    }
    
    fileprivate func animateIn() {
        layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.alpha = 1
            self.blurEffectView.alpha = 1
 
        }, completion: { (complition) in
           
        })
    }
    
    fileprivate func animateOut() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.alpha = 0
            self.blurEffectView.alpha = 0
        }, completion: { (complition) in
            self.blurEffectView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    @objc func handleDismiss() {
        self.animateOut()
    }
    
}
