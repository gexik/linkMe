//
//  UserProfileController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 06.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    let headerId = "headerId"
    
    var userId: String?
    
    var isGridView = true
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupLogOutButton()
        fetchUser()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        self.fetchUser()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.backgroundColor = UIColor(white: 0, alpha: 0.1)
            if posts.count > 0 {
                cell.post = posts[indexPath.item]
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            if posts.count > 0 {
                cell.post = posts[indexPath.item]
            }
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            return CGSize(width: view.frame.width/3-1, height: view.frame.width/3-1)
        } else {
            var height: CGFloat = 40 + 8 + 8
            height += view.frame.width
            height += 40 + 8 + 8
            
            let post = posts[indexPath.item]
            
            if post.caption.count > 0 {
                
                let captionTextSize = post.caption.boundingRect(with: CGSize(width: collectionView.frame.width - 20 , height: 1000), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)], context: nil)
                
                return CGSize(width: view.frame.width, height: height + captionTextSize.height + 10)
            } else {
                return CGSize(width: view.frame.width, height: height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var user: User?
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    @objc      func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            
            do {
                try Auth.auth().signOut()
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalTransitionStyle = .flipHorizontal
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutError {
                print("Failed to sign out:", signOutError)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    var posts = [Post]()
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid else { return }
        
        Database.database().reference().child("posts").child(uid).observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as?  [String: Any] else {return}
            guard let user = self.user else {return}
            
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (error) in
            
        }
    }
    
     func fetchUser() {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            
            self.navigationItem.title = self.user?.userName
            
            self.collectionView?.reloadData()

            self.fetchOrderedPosts()
        }
    }
}
