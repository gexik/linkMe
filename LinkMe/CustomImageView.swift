//
//  CustomImageView.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import Kingfisher

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastUrlUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        self.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.3))], progressBlock: { (i, j) in
            
        }) { (image, error, cacheType, url) in
            
        }
    }
}
