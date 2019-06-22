//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Sky on 6/13/19.
//  Copyright © 2019 OU. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var imageUrl: URL? {
        didSet {
            
        }
    }

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self as? UIScrollViewDelegate
            scrollView.maximumZoomScale = 5
            scrollView.minimumZoomScale = 1/10
        }
    }
    
  

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchImage()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func fetchImage() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            if let url = self?.imageUrl, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.imageView.sizeToFit()
                    self?.scrollView.contentSize = (self?.imageView.frame.size)!
                }
            }
        }
    }
}
