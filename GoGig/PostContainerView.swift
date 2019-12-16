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
    
    //play button for videos (setup in a closure)
    let playButton: UIImageView = {
        let pb = UIImageView(image: UIImage(named: "playButton"))
        pb.translatesAutoresizingMaskIntoConstraints = false
        return pb
    }()
    
    override func awakeFromNib() {
        //default dimensions
        dimensionHeight = self.frame.size.height
        dimensionWidth = self.frame.size.width
        
        imageView = UIImageView()
        //give a shadow, border and rounded edges
        layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 30
        //make the UIView clear
        self.backgroundColor = UIColor.clear
        
    }
    
    func clearView(fit: Bool){
        //clear the container view if there is anything
        //if there is a video, close it
        if avPlayer != nil {
            closePlayer()
        }
        //if there is an image remove it
        if self.subviews.count > 0 {
            imageView.removeFromSuperview()
        }
        //if choosing to fit, return to default dimensions
        if fit {
            self.frame.size.height = dimensionHeight
            self.frame.size.width = dimensionWidth
        }
    }
    
    func addPhoto(imageContent: UIImage, fit: Bool){
        
        //clear the container view if there is anything
        clearView(fit: fit)
        
        //fit = true means UIView decides dimensions of post
        //fit = false means post decides dimensions of UIView
        if fit {
            imageView.frame.size.height = dimensionHeight
            imageView.frame.size.width = dimensionWidth
            imageView.translatesAutoresizingMaskIntoConstraints = true
            imageView.contentMode = .scaleAspectFit
            imageView.image = imageContent
        
        //resize for the feed
        } else {
            imageView = UIImageView(image: imageContent)
            layer.cornerRadius = 0
        
        }
        //hide until sizing is right
        imageView.isHidden = true
    
        //get ratio of how much to shrink the image by by using the width of the UIView
        //(width is set using constraints)
        //height is not set, because that is what is changing
        let ratio = self.frame.size.width / imageView.frame.size.width
        //change the height of the UIView by setting it to the new height of the imageView
        self.frame.size.height = imageView.frame.size.height * ratio
        
        //fill the UIView with the imageView
        imageView.frame = self.bounds
        
        //add image to view and show it
        self.addSubview(imageView)
        imageView.isHidden = false
        
    }
    
    func addVideo(url: URL, fit: Bool){
        
        //clear
        clearView(fit: fit)
        //add a video player
        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        //fill the UIView with the video player
        avPlayerLayer.frame = self.bounds
        //add it
        self.layer.insertSublayer(avPlayerLayer, at: 0)
        //show the play button
        playButton.isHidden = true
    }
    
    func addPlayButton(){
        //add the playbutton in the middle of the UIView
        playButton.isHidden = false
        self.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func removePlayButton(){
        playButton.removeFromSuperview()
    }
    
    func playPlayer(){
        avPlayer.play()
    }
    //remove the video player
    func closePlayer(){
        avPlayer.pause()
        avPlayer = nil
        avPlayerLayer.removeFromSuperlayer()
    }
    
    //load images from NSCache
    var imageUrlString: NSString?
    func loadImageCache(url: URL, isImage: Bool) {
        //url as a string
        let urlString = url.absoluteString as NSString
        imageUrlString = urlString
        //check for a chached image
        if let cachedImage = imageCache.object(forKey: urlString) {
            //if there is one, add it to UIView
            self.addPhoto(imageContent: cachedImage, fit: false)
            //if post is a video, add a playbutton too
            if !isImage {
                self.addPlayButton()
            }
        //not cached, need to download
        } else {
            
            //to avoid flashing of images
            self.clearView(fit: false)
            //download task
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            
                            if self.imageUrlString == urlString {
                                self.addPhoto(imageContent: downloadedImage, fit: false)
                            }
                            
                            if !isImage {
                                self.addPlayButton()
                            }
                            //add it to cache once downloaded
                            imageCache.setObject(downloadedImage, forKey: urlString)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
