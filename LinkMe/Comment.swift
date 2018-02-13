//
//  Comment.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 04.05.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import Foundation

struct Comment {
    let user: User
    
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
