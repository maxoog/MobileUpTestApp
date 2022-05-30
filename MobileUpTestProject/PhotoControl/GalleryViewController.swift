//
//  GalleryViewController.swift
//  MobileUpTestProject
//
//  Created by Максим on 01.04.2022.
//

import UIKit

class GalleryViewController: UICollectionViewController {
    
    var photoProvider: PhotoProvider?
    
    private let numOfPhotos: Int = 30
    var logoutAction: (() -> Void)?
    
    convenience init(coder: NSCoder, session: VkApiSession) {
        self.init(coder: coder)!
        self.photoProvider = PhotoProvider(session: session)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let alert =
        UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] (_) in
            self?.logoutAction?()
            self?.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }
    
}

extension GalleryViewController {
    
    /*
     
    UICollectionDataSourse methods
     
    */
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfPhotos
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! GalleryCell
        photoProvider?.fetchPhoto(index: indexPath.row, completion: { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.setImage(image)
                }
            case .failure:
                AlertService.networkAlert(in: self)
            }
        })
        return cell
    }
    
}

extension GalleryViewController {
    
    /*
     
    UICollectionDelegate methods
     
    */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PhotoViewController")
        if let photoViewController = controller as? PhotoViewController {
            let cell = (collectionView.cellForItem(at: indexPath) as! GalleryCell)
            photoViewController.initialIndexPath = indexPath
            photoViewController.initialImage = cell.getImage()
            photoViewController.dataSource = self
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2 - 1, height: view.frame.width / 2 - 1)
    }
    
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
