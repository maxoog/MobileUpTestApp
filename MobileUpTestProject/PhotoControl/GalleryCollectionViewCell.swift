//
//  GalleryCollectionViewPhotoCell.swift
//  MobileUpTestProject
//
//  Created by Максим on 01.04.2022.
//

import UIKit

protocol GalleryCell: UICollectionViewCell {
    func setImage(_: UIImage?)
    func getImage() -> UIImage?
}

class PhotoViewPhotoCell: UICollectionViewCell, GalleryCell {
    @IBOutlet weak var imageView: UIImageView!
    func setImage(_ someImage: UIImage?) {
        imageView.image = someImage
    }
    
    func getImage() -> UIImage? {
        return imageView.image
    }
}

class GalleryCollectionViewCell: UICollectionViewCell, GalleryCell {
    @IBOutlet weak var imageView: UIImageView!
    func setImage(_ someImage: UIImage?) {
        imageView.image = someImage
    }
    
    func getImage() -> UIImage? {
        return imageView.image
    }
}
