//
//  FirebaseUtils.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 14.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

extension Database {
    static func fetchUserWithUID(uid: String, complition: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            complition(user)
            
        }) { (error) in
            
        }
    }
}
