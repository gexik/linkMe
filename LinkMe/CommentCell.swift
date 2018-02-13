//
//  CommentCell.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 04.05.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }

            let attibutedText = NSMutableAttributedString(string: comment.user.userName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.white])
            attibutedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
            
            commentTextView.attributedText = attibutedText
            
            userProfileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .gray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(commentTextView)
        addSubview(userProfileImageView)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, buttom: nil, right: nil, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 20
        
        commentTextView.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red:0.18, green:0.20, blue:0.22, alpha:1.00)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: commentTextView.leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
