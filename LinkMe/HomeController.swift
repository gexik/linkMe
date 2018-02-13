//
//  HomeController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    var posts = [Post]()
    let cellId = "cellId"
    
    let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.addSubview(indicatorView)
        
        indicatorView.anchor(top: view.topAnchor, left: nil, buttom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicatorView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.indicatorView.stopAnimating()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        self.fetchAllPosts()
        
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserId()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        if posts.count > 0 {
            cell.post = posts[indexPath.item]
        }
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Feed"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera_button").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleCamera))
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    func didTapComment(post: Post) {
        let commetnsController = CommentsController(collectionViewLayout:UICollectionViewFlowLayout())
        commetnsController.hidesBottomBarWhenPushed = true
        commetnsController.post = post
        navigationController?.pushViewController(commetnsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        var post = posts[indexPath.item]
        guard let postId = post.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let values = [uid: post.hasLiked == true ? 0 : 1]
        
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (error, ref) in
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    func didTapOptions(post: Post) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let userPostRef = Database.database().reference().child("posts").child(uid).child(post.id!)
            
            userPostRef.removeValue(completionBlock: { (error, ref) in
                self.fetchPosts()
            })
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = .white
        
        if let visualEffectView = searchVisualEffectsSubview(view: alertController.view) {
            visualEffectView.effect = UIBlurEffect(style: .dark)
        }
        
    }
    
    func searchVisualEffectsSubview(view: UIView) -> UIVisualEffectView?
    {
        if let visualEffectView = view as? UIVisualEffectView
        {
            return visualEffectView
        }
        else
        {
            for subview in view.subviews
            {
                if let found = searchVisualEffectsSubview(view: subview)
                {
                    return found
                }
            }
        }
        
        return nil
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
     fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.indicatorView.stopAnimating()
            self.fetchPostWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostWithUser(user: User) {
        Database.database().reference().child("posts").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as?  [String: Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                print("Key: \(key) Value: \(value)")
                
                guard let dictionary = value as?  [String: Any] else {return}
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else {return}
                
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshor) in
                    
                    if let value = snapshor.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                       post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        p1.creationDate > p2.creationDate
                    })
                    
                    self.collectionView?.reloadData()
                    
                }, withCancel: { (error) in
                    
                })
            })

        }) { (error) in
            print("Failed to fetch posts:", error)
        }
    }
    
    fileprivate func fetchFollowingUserId() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as?  [String: Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, complition: { (user) in
                    self.fetchPostWithUser(user: user)
                })
            })
        }) { (error) in
            
        }
        
    }
}
