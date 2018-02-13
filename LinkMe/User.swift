//
//  User.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 12.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let userName: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.userName = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
