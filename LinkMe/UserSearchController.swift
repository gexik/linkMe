//
//  UserSearchController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 14.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
  lazy var searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Enter username"
        searchBar.barTintColor = .gray
        searchBar.delegate = self
        UITextField.appearance(whenContainedInInstancesOf:[UISearchBar.self]).backgroundColor = UIColor(red:0.18, green:0.21, blue:0.26, alpha:1.00)
        UITextField.appearance(whenContainedInInstancesOf:[UISearchBar.self]).keyboardAppearance = .dark
        UITextField.appearance(whenContainedInInstancesOf:[UISearchBar.self]).textColor = .white
        return searchBar
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { (user) -> Bool in
                return user.userName.lowercased().contains(searchText.lowercased())
            }
        }

        self.collectionView?.reloadData()
        
        findUsers(text: searchText)
    }
    
    func findUsers(text: String)->Void{
        let ref = Database.database().reference()
        
        ref.child("users").queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observe(.value, with: { snapshot in
            print(snapshot.value ?? "")
            
            self.filteredUsers.removeAll()
            self.users.removeAll()
            
            guard let dictionaries = snapshot.value as?  [String: Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as?  [String: Any] else {return}
                
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
                
                self.users.sort(by: { (user1, user2) -> Bool in
                    return user1.userName.compare(user2.userName) == .orderedAscending
                })
                
                self.filteredUsers = self.users
                self.collectionView?.reloadData()
            })
        })
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, buttom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
      //  fetchUsers()
    }
    
    var filteredUsers = [User]()
    var users = [User]()
    
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users").queryLimited(toLast: 21)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as?  [String: Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as?  [String: Any] else {return}
                
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
                
                self.users.sort(by: { (user1, user2) -> Bool in
                    return user1.userName.compare(user2.userName) == .orderedAscending
                })
                
                self.filteredUsers = self.users
                self.collectionView?.reloadData()
            })
            
        }) { (error) in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        cell.separatorView.isHidden = indexPath.item == filteredUsers.count - 1
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let  userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.5, left: 0, bottom: 0, right: 0)
    }
}
