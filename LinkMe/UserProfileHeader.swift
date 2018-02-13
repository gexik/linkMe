//
//  UserProfileHeader.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 06.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol UserProfileHeaderDelegate {
    func didChangeToGridView()
    func didChangeToListView()
}

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.userName
            
            setupEditFollowButton()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.clipsToBounds = true
        
        return iv
    }()
    
    lazy var grigButton:UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "grid").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleChangeTiGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton:UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "list").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(handleChangeTiListView), for: .touchUpInside)
        return button
    }()
    
    let bookmarkButton:UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "bookmarkButton").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.text = "User name"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    lazy var postsLabel: UILabel = {
        let label = UILabel()
        let attibutedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attibutedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attibutedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attibutedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attibutedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attibutedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let attibutedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attibutedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attibutedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
   lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type:.system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor(red:0.11, green:0.14, blue:0.19, alpha:1.00)
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, buttom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80/2
        
        setupButtomToolBar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, buttom: grigButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
        setupUserStats()
    }
    

    
    @objc func handleChangeTiGridView() {
        listButton.tintColor = .darkGray
        grigButton.tintColor = .white
        delegate?.didChangeToGridView()
    }
    
    @objc func handleChangeTiListView() {
        listButton.tintColor = .white
        grigButton.tintColor = .darkGray
        delegate?.didChangeToListView()
    }

    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            //edit profile
        } else {
            
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    self.setupFollowStyle()
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following:", err) 
            })
        }
    }
    
    @objc func handleEditProfileOrFollow() {
        print("Execute edit profile / follow / unfollow logic...")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            //edit profile
        } else {
            if editProfileFollowButton.titleLabel?.text == "Unfollow" {
                
                //unfollow
                Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                    if let err = err {
                        print("Failed to unfollow user:", err)
                        return
                    }
                    
                    self.setupFollowStyle()
                })
                
            } else {
                //follow
                let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
                
                let values = [userId: 1]
                ref.updateChildValues(values) { (err, ref) in
                    if let err = err {
                        print("Failed to follow user:", err)
                        return
                    }
                    
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    self.editProfileFollowButton.backgroundColor = UIColor(red:0.30, green:0.63, blue:1.00, alpha:1.00)
                    self.editProfileFollowButton.setTitleColor(.white, for: .normal)
                }
            }
        }
        

    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = .flatGreen
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    fileprivate func setupUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, buttom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 50)
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: stackView.bottomAnchor, left: profileImageView.rightAnchor, buttom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 30 )
    }
    
    fileprivate func setupButtomToolBar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(red:0.18, green:0.20, blue:0.22, alpha:1.00)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor(red:0.18, green:0.20, blue:0.22, alpha:1.00)
        
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        let stackView = UIStackView(arrangedSubviews: [grigButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: nil, left: leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, buttom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, buttom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
