//
//  PhotoViewController.swift
//  MobileUpTestProject
//
//  Created by Максим on 01.04.2022.
//

import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomGallery: UICollectionView!
    
    @IBOutlet weak var mainImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageLeadingConstraint: NSLayoutConstraint!
    
    weak var dataSource: UICollectionViewDataSource?
    var initialIndexPath: IndexPath?
    var initialImage: UIImage?
    
    var topBarHeight: CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        top += view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return top
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomGallery.dataSource = dataSource
        bottomGallery.delegate = self

        updateConstraintsForSize(view.bounds.size)
        updateMinZoomingScaleForSize(view.bounds.size)
        
        navigationItem.title = "Date"
        showChosenPhoto(in: initialIndexPath)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateConstraintsForSize(scrollView.bounds.size)
        updateMinZoomingScaleForSize(view.bounds.size)
    }
    
    func showChosenPhoto(in indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        adaptBottomGallery(for: indexPath)
        
        if let image = initialImage {
            self.mainImage.image = image
            initialImage = nil
            return
        }
        
        if let cell = bottomGallery.cellForItem(at: indexPath) as? PhotoViewPhotoCell {
            self.mainImage.image = cell.getImage()
        }
    }
    
    func adaptBottomGallery(for indexPath: IndexPath) {
        bottomGallery.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        guard let image = self.mainImage.image else { return }
        let avc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        avc.completionWithItemsHandler = { activity, _, _, error in
            guard error == nil else { return }
            if activity == .saveToCameraRoll {
                self.didSaveImage()
            }
        }
        self.present(avc, animated: true, completion: nil)
    }
    
    func didSaveImage() {
        let alert =
        UIAlertController(title: "You've just saved image :)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showChosenPhoto(in: indexPath)
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    
    func updateMinZoomingScaleForSize(_ size: CGSize) {
        let widthScale = size.width / mainImage.bounds.width
        let heightScale = size.height / mainImage.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3
        scrollView.zoomScale = minScale
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - mainImage.frame.height) / 2) - topBarHeight
        mainImageTopConstraint.constant = yOffset
        mainImageBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - mainImage.frame.width) / 2)
        mainImageLeadingConstraint.constant = xOffset
        mainImageTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: bottomGallery.frame.height, height: bottomGallery.frame.height)
    }
}
