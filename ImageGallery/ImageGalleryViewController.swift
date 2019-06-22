//
//  ViewController.swift
//  ImageGallery
//
//  Created by Sky on 6/12/19.
//  Copyright © 2019 OU. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    var images: [(url: URL, ration: CGFloat)] = [(URL(string: "https://image.shutterstock.com/image-photo/scence-sun-rising-prachuap-khiri-260nw-1179350104.jpg")!, 0.5), (URL(string: "https://image.shutterstock.com/image-photo/scence-sun-rising-prachuap-khiri-260nw-1179350104.jpg")!, 0.5), (URL(string: "https://image.shutterstock.com/image-photo/scence-sun-rising-prachuap-khiri-260nw-1179350104.jpg")!, 0.5), (URL(string: "https://image.shutterstock.com/image-photo/scence-sun-rising-prachuap-khiri-260nw-1179350104.jpg")!, 0.5)]
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    var _scale: CGFloat = 1.0
    var scale: CGFloat {
        get {
            return _scale
        }
        set {
            if newValue > 3 {
                _scale = 3
            } else if newValue < 0.3 {
                _scale = 0.3
            } else {
                _scale = newValue
            }
            if newValue != _scale {
                let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                flowLayout.invalidateLayout()
            }
        }
    }
    
    let initialWidth: CGFloat = 300
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let (_, ratio) = images[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) {
            return CGSize(width: initialWidth * scale, height: initialWidth * scale * ratio)
        } else {
            return CGSize(width:300, height: 300)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: <#T##IndexPath#>)
        let image = images[indexPath.item]
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.spinner.isHidden = false
            DispatchQueue.global().async {
                try! Data(contentsOf: image.url)
                if let data = try? Data(contentsOf: image.url), let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageCell.imageView.image = downloadedImage
                        imageCell.spinner.isHidden = true
                    }
                }
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.item]
        performSegue(withIdentifier: "showImage", sender: image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageVC = segue.destination as? ImageViewController, let indexPath = sender as? IndexPath {
            let imageUrl = images[indexPath.item].url
            imageVC.imageUrl = imageUrl
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = session.localDragSession?.localContext as? UICollectionView == collectionView
        
        return isSelf ? UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath): UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        if let item = coordinator.items.first {
            var url: URL?
            let dragItem = item.dragItem
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    let image = images.remove(at: sourceIndexPath.item)
                    images.insert(image, at: destinationIndexPath.item)
                    collectionView.insertItems(at: [destinationIndexPath])
                    collectionView.deleteItems(at: [sourceIndexPath])
                    updateImagesForMasterViewController()
                })
                coordinator.drop(dragItem, toItemAt: destinationIndexPath)
            } else {
                
                dragItem.itemProvider.loadObject(ofClass: NSURL.self) {
                    (nsurl, error) in
                    if let _url = nsurl as? URL {
                        url = _url.imageURL
                    }
                }
                dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (_image, error) in
                    if let image = _image as? UIImage {
                        let ratio = image.size.height / image.size.width
                        DispatchQueue.main.async {
                            collectionView.performBatchUpdates({
                                let img = (url!, ratio)
                                self.images.insert(img, at: destinationIndexPath.item)
                                collectionView.insertItems(at: [destinationIndexPath])
                                self.updateImagesForMasterViewController()
                            })
                        }
                        coordinator.drop(dragItem, toItemAt: destinationIndexPath)
                    }
                }
            }
        }
        
    }
    
    func updateImagesForMasterViewController() {
        if let imageGalleryTVC = splitViewController?.viewControllers.first as? ImageGalleryViewController {
//            imageGalleryTVC.currentGalleryImages = images
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if session.localDragSession?.localContext as? UICollectionView == collectionView {
            return true
        } else {
            return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let image = images[indexPath.item]
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: NSURL(string: image.url.path)!))
        dragItem.localObject = image
        return [dragItem]
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            let recoginizer = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
            collectionView.addGestureRecognizer(recoginizer)
        }
    }
    
    @objc func zoom(_ recoginizer: UIPinchGestureRecognizer) {
        switch recoginizer.state {
        case .changed:
            scale = recoginizer.scale
        default:
            break
        }
    }
}

extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        return self.baseURL ?? self
    }

}

