//
//  UserProfilePhotoCell.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let urlString = post?.imageUrl  else { return }
            imageView.loadImage(urlString: urlString )
        }
    }
    
    let imageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, buttom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
