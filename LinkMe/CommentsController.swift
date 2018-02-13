//
//  CommentsController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 04.05.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    var comments = [Comment]()
    var post: Post?
    let cellId = "cell"
    
    let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignView))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        collectionView?.addSubview(indicatorView)
        indicatorView.anchor(top: view.topAnchor, left: nil, buttom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicatorView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.indicatorView.stopAnimating()
        }
        
        fetchComments()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func resignView() {
        self.commentTextField.resignFirstResponder()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    fileprivate func fetchComments() {
    //    comments.removeAll()
        
        guard let postId = self.post?.id else {return}
        
        let ref = Database.database().reference().child("comments").child(postId)
        
        ref.observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            guard let uid = dictionary["uid"] as? String else {return}
            
            Database.fetchUserWithUID(uid: uid, complition: { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                
                self.comments.append(comment)
                
                self.indicatorView.stopAnimating()
                
                self.collectionView?.reloadData()
                
                self.scrollDownAnimated(animated: true)
                
            })
        }) { (error) in
            print(error)
        }
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red:0.10, green:0.11, blue:0.13, alpha:1.00)
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysTemplate), for: .normal)
        submitButton.tintColor = .white
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, buttom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, buttom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 7, paddingLeft: 15, paddingBottom: 7, paddingRight: 0, width: 0, height: 0)
        self.commentTextField.layer.cornerRadius = 18
        self.commentTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 36))
        self.commentTextField.leftViewMode = .always
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.25)
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, buttom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red:0.18, green:0.21, blue:0.26, alpha:0.25)
        textField.textColor = .flatWhite
        textField.keyboardAppearance = .dark
        textField.attributedPlaceholder = NSAttributedString(string: "Enter comment", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
        textField.delegate = self
        return textField
    }()
    
    fileprivate func scrollDownAnimated(animated: Bool) {
        DispatchQueue.main.async {
            if self.comments.count > 0 {
                self.collectionView?.scrollToItem(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: animated)
            }
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollDownAnimated(animated: true)
    }
    
    @objc fileprivate func handleSubmit () {
        guard let commentText = commentTextField.text, commentText.count > 0 else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let postId = post?.id ?? ""
        let values = ["text": commentTextField.text ?? "","createdDate": Date().timeIntervalSince1970,"uid": uid] as [String: Any]
        self.commentTextField.text = ""
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
