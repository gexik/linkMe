//
//  HomePostCell.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapOptions(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            
            likeButton.tintColor = post?.hasLiked == true ? .red : .gray
            
            photoImageView.loadImage(urlString: imageUrl)
            userProfileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = post?.user.userName
            
            setupAttibutedCaption()
        }
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "User name"
        label.textColor = .white
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(handleOptions), for: .touchUpInside)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_button").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        button.tintColor = .gray
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comments_button").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(handleComments), for: .touchUpInside)
        return button
    }()
    
    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bookmarkButton").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .gray

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        addSubview(photoImageView)
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(dateLabel)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, buttom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 20
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, buttom: photoImageView.topAnchor, right: dateLabel.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)

        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, buttom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        dateLabel.anchor(top: topAnchor, left: nil, buttom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 120, height: 0)
        
        setupActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        //#2D3238
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red:0.18, green:0.20, blue:0.22, alpha:1.00)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)        
    }
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
    
    @objc fileprivate func handleOptions() {
        guard let post = post else {return}
        delegate?.didTapOptions(post: post)
    }
    
    @objc fileprivate func handleComments() {
        guard let post = post else {return}
        delegate?.didTapComment(post: post)
    }
    
    fileprivate func setupAttibutedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: "\(post.caption)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        
        captionLabel.attributedText = attributedText
        
        dateLabel.attributedText = NSAttributedString(string: post.creationDateString, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray])
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, buttom: nil, right: nil, paddingTop: 0, paddingLeft: -3, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        
        addSubview(optionsButton)
        optionsButton.anchor(top: photoImageView.bottomAnchor, left: nil, buttom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
