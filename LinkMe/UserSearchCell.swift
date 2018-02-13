//
//  UserSearchCell.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 14.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            self.contentView.backgroundColor = isHighlighted ? UIColor(red:0.19, green:0.21, blue:0.25, alpha:1.00) : UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        }
    }
    var user: User? {
        didSet {
            guard let username = user?.userName else { return }
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            userProfileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = username
        }
    }
    
    var separatorView = UIView()
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        
        userProfileImageView.anchor(top: nil, left: leftAnchor, buttom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        userProfileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userProfileImageView.layer.cornerRadius = 25
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(red:0.18, green:0.20, blue:0.22, alpha:1.00)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: usernameLabel.leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
