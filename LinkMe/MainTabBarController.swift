//
//  MainTabBarController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 06.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorViewController = PhotoSelectionController(collectionViewLayout: layout)
            let photoSelectorNavViewController = UINavigationController(rootViewController: photoSelectorViewController)
            present(photoSelectorNavViewController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        tabBar.barTintColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        if Auth.auth().currentUser == nil {

            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalTransitionStyle = .flipHorizontal
                self.present(navController, animated: false, completion: nil)
            }
            
            return
        }
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        let homeNavController = templeteNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        let searchNavNavController = templeteNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        let plusNavNavController = templeteNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        let likesNavNavController = templeteNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))

        let userProfileNavController = templeteNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .white
        
        viewControllers = [homeNavController, searchNavNavController, plusNavNavController, likesNavNavController, userProfileNavController]
        
        guard let items = tabBar.items else {
            return
        }
        
        for item in items {
            let index = items.index(of: item)
            item.isEnabled = index != 3
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            item.title = ""
        }
    }
    
    fileprivate func templeteNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
