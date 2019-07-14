//
//  PostContainerView.swift
//  GoGig
//
//  Created by Lee Chilvers on 20/02/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PostContainerView: UIView {
    
    private var dimensionHeight: CGFloat = 0.00
    private var dimensionWidth: CGFloat = 0.00
    
    private var imageView: UIImageView!
    private var avPlayer: AVPlayer!
    private var avPlayerLayer: AVPlayerLayer!
    
    override func awakeFromNib() {
        
        dimensionHeight = self.frame.size.height
        dimensionWidth = self.frame.size.width
        
        imageView = UIImageView()
        
        layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 30
        
        self.backgroundColor = #colorLiteral(red: 0.9652684959, green: 0.9729685758, blue: 1, alpha: 1)
        
    }
    
    func clearView(fit: Bool){
        //Clear the container view if there is anything
        if avPlayer != nil {
            closePlayer()
        }
        if self.subviews.count > 0 {
            imageView.removeFromSuperview()
        }
        
        if fit {
            self.frame.size.height = dimensionHeight
            self.frame.size.width = dimensionWidth
        }
    }
    
    func addPhoto(imageContent: UIImage, fit: Bool){
        
        //Clear the container view if there is anything
        clearView(fit: fit)
        
        //fit ready for posting
        if fit {
            imageView.frame.size.height = dimensionHeight
            imageView.frame.size.width = dimensionWidth
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = imageContent
        
        //resize for the feed
        } else {
            imageView = UIImageView(image: imageContent)
            layer.cornerRadius = 0
        }
        
        imageView.isHidden = true
        
        //Get ratio of how much to shrink the image by by using the width of the UIView
        //(width is set using constraints)
        //We haven't set a height, because that's what we're changing
        let ratio = self.frame.size.width / imageView.frame.size.width
        //Change the height of the UIView by setting it to the new height of the imageView
        self.frame.size.height = imageView.frame.size.height * ratio
        
        //fill the UIView with the imageView
        imageView.frame = self.bounds
        
        self.addSubview(imageView)
        imageView.isHidden = false
    }
    
    func addVideo(url: URL, fit: Bool){
        
        clearView(fit: fit)
        
        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        
        //May not work for video may cause crash??
        //        let ratio = self.frame.size.width / avPlayerLayer.frame.size.width
        //        self.frame.size.height = avPlayerLayer.frame.size.height * ratio
        
        avPlayerLayer.frame = self.bounds
        
        self.layer.insertSublayer(avPlayerLayer, at: 0)
    }
    
    func playPlayer(){
        avPlayer.play()
    }
    
    func closePlayer(){
        avPlayer.pause()
        avPlayer = nil
        avPlayerLayer.removeFromSuperlayer()
    }
    
    //Load images from NSCache
    var imageUrlString: NSString?
    func loadImageCache(url: URL, isImage: Bool) {
        
        let urlString = url.absoluteString as NSString
        imageUrlString = urlString
        
        if let cachedImage = imageCache.object(forKey: urlString) {
            self.addPhoto(imageContent: cachedImage, fit: false)
            
        } else {
            
            //to avoid flashing of images
            self.addPhoto(imageContent: UIImage(named: "blankSpace")!, fit: false)
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            
                            if self.imageUrlString == urlString {
                                self.addPhoto(imageContent: downloadedImage, fit: false)
                            }
                            
                            imageCache.setObject(downloadedImage, forKey: urlString)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
