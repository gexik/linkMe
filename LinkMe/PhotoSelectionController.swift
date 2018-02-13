//
//  PhotoSelectionController.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor(red:0.09, green:0.10, blue:0.13, alpha:1.00)
        
        setupNavButtons()
        
        fetchPhotos()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.backgroundColor = UIColor(white: 0, alpha: 0.1)
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        header.backgroundColor = UIColor(white: 0, alpha: 0.1)
        header.imageView.image = selectedImage
        
        
        DispatchQueue.global(qos: .background).async {
            let imageManager = PHImageManager.default()
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            
            
            if let selectedImage = self.selectedImage {
                if let index = self.images.index(of: selectedImage) {
                    let selectedAsset = self.assets[index]
                    let targetSize = CGSize(width: 800, height: 800)
                    imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                        DispatchQueue.main.async {
                            header.imageView.image = image
                            self.selectedHeader = header
                        }
                    })
                }
            }
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 3)/4, height: (view.frame.width - 3)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.item]
        collectionView.reloadData()
        let scrollPoint = CGPoint(x: 0, y: 0)
        collectionView.setContentOffset(scrollPoint, animated: true)
    }
    
    var selectedImage: UIImage?
    var selectedHeader: PhotoSelectorHeader?
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        //   fetchOptions.fetchLimit = 10
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects({ (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let imageSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        if count == allPhotos.count - 1 {
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    }
                })
            })
        }
    }
    
    fileprivate func setupNavButtons() {
        navigationItem.title = "All Photos"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc      func handleNext() {
        let sharePhotoConcroller = SharePhotoController()
        print(selectedHeader?.imageView.image ?? "")
        sharePhotoConcroller.imageView.image = selectedHeader?.imageView.image
        navigationController?.pushViewController(sharePhotoConcroller, animated: true)
    }
}
