//
//  PhotosCollectionViewModel.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 22.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit

class PhotosCollectionViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var photos = [UIImage]()
    var openImagePickerComplition: (() -> Void)?
    var selectedImageComplition: (() -> Void)?
    var isEditable: (() -> Bool)?
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEditable!() {
            return self.photos.count + 1
        }
        return self.photos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCellReuseID", for: indexPath) as! PhotosCollectionViewCell
        
        if indexPath.item == 3 {
            cell.imageView.image = nil
            return cell
        }
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1 && self.photos.count < 3 && isEditable!() {
            cell.imageView.image = UIImage.init(named: "bigPlus")
            cell.imageView.contentMode = .scaleAspectFit
        }
        else if indexPath.item < self.photos.count {
            cell.imageView.image = photos[indexPath.item]
            cell.imageView.contentMode = .scaleToFill
        }
        cell.imageView!.layer.cornerRadius = cell.imageView!.bounds.size.width * 0.1
        cell.imageView!.layer.masksToBounds = true
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditable!() {
            if indexPath.item == self.photos.count && self.photos.count < 3 {
                openImagePickerComplition!()
            }
            else if indexPath.item != collectionView.numberOfItems(inSection: indexPath.section) - 1 {
                self.photos.remove(at: indexPath.item)
                collectionView.deleteItems(at: [indexPath])
                
                let section = indexPath.section
                let index = collectionView.numberOfItems(inSection: section) - 1
                let indexPath = IndexPath.init(item: index, section: section)
                let cell = collectionView.cellForItem(at: indexPath) as! PhotosCollectionViewCell
                
                cell.imageView.image = UIImage.init(named: "bigPlus")
                cell.imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photos.append(pickedImage)
            selectedImageComplition!()
        }
        picker.dismiss(animated: true, completion: nil) 
    }
}
