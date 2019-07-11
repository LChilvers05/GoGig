//
//  PortfolioPostVC.swift
//
//
//  Created by Lee Chilvers on 22/12/2018.
//

import UIKit
import AVKit
import AVFoundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GooglePlaces
import GoogleMaps

//Pretty much NSCache is just a collection that you use to store objects like a UIImage, NSCache requires the type to be AnyObject so you can store your cache using UIImage() if you incline to do so. iOS/Swift is also smart enough to know when to drop the images if too much memory is being used and it is automatic so no worries there.

//Subclass of the AutoComplete
//Inherits methods to present the LocationAutoCompleteVC
class PortfolioPostVC: AutoComplete {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var postContainerView: PostContainerView!
    @IBOutlet weak var captionContentView: UITextView!
    
    var postData: Dictionary<String, Any>?
    
    var imagePicker: UIImagePickerController?
    
    var postID = ""
    var imageID = ""
    var imageAdded = false
    var videoAdded = false
    var imageContent: UIImage?
    var videoContent: URL?
    var videoThumbnail: UIImage?
    var thumbnailURL: URL?
    
    var dimensions: [String : CGFloat] = ["height": 0.00, "width": 0.00]
    func updateDimensions(image: UIImage){
        dimensions["height"] = image.size.height
        dimensions["width"] = image.size.width
    }
    
    var height: CGFloat?
    var width: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
    }
    
    @IBAction func popView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: STAGE 1: OPTIONAL POST LOCATION
    
    @IBAction func addLocationButton(_ sender: Any) {
        presentAutocompleteVC()
        
        locationLabel.text = locationResult
    }
    
    
    //MARK: STAGE 2: POST CONTENT
    
    @IBAction func chooseImage(_ sender: Any) {
        
        openPhotoPopup(video: true, imagePicker: imagePicker!, title: "Post", message: "Take or choose a portfolio post")
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. Use the original.
        if let selectedImage = info[.originalImage] as? UIImage {
            
            postContainerView.addPhoto(imageContent: selectedImage)
            
            imageContent = selectedImage
            imageAdded = true
            videoAdded = false
            
            updateDimensions(image: imageContent!)
            
            imageID = "\(NSUUID().uuidString).jpg"
        }
        
        if let selectedVideo = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            postContainerView.addVideo(url: selectedVideo)
            postContainerView.playPlayer()
            
            videoContent = selectedVideo
            videoAdded = true
            imageAdded = false
            
            let thumbnail = generateThumbnail(url: videoContent!)
            updateDimensions(image: thumbnail)
            
            imageID = "\(NSUUID().uuidString).mov" //may not be .mov file type?
        }
        
        
        //Dismiss ImagePicker Controller
        dismiss(animated: true, completion: nil)
    }
    
    func contentUpload(uid: String, handler: @escaping (_ returnedURLs: [URL]) ->()){
        
        var urls = [URL]()
        
        if imageAdded {
            if let postImage =  imageContent {
                
                DataService.instance.updateSTPic(uid: uid, directory: "portfolioPost", imageContent: postImage, imageID: imageID, uploadComplete: { (success, error) in
                    if error != nil {
                        
                        self.displayError(title: "There was an Error", message: error!.localizedDescription)
                        
                    } else {
                        
                        DataService.instance.getSTURL(uid: uid, directory: "portfolioPost", imageID: self.imageID) { (returnedURL) in
                            
                            urls.append(returnedURL)
                            
                            handler(urls)
                            
                        }
                    }
                })
            }
        }
        
        if videoAdded {
            if let postVideo = videoContent {
                
                DataService.instance.updateSTVid(uid: uid, directory: "portfolioPost", vidContent: postVideo, imageID: imageID, uploadComplete: { (success, error) in
                    if error != nil {
                        
                        self.displayError(title: "There was an Error", message: error!.localizedDescription)
                        
                    } else {
                        
                        DataService.instance.getSTURL(uid: uid, directory: "portfolioPost", imageID: self.imageID) { (returnedURL) in
                            
                            self.thumbnailUpload(uid: uid, url: postVideo) { (returnedThumbnailURL) in
                                
                                urls.append(returnedURL)
                                urls.append(returnedThumbnailURL)
                                
                                handler(urls)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func thumbnailUpload(uid: String, url: URL, handler: @escaping (_ returnedThumbnailURL: URL) -> ()) {
        
        self.videoThumbnail = generateThumbnail(url: url)
        
        imageID = "\(NSUUID().uuidString).jpg"
        
        DataService.instance.updateSTPic(uid: uid, directory: "portfolioThumbnail", imageContent: videoThumbnail!, imageID: imageID, uploadComplete: { (success, error) in
            if error != nil {
                self.displayError(title: "There was an Error", message: error!.localizedDescription)
            } else {
                DataService.instance.getSTURL(uid: uid, directory: "portfolioThumbnail", imageID: self.imageID) { (returnedURL) in
                    
                    handler(returnedURL)
                }
            }
        })
    }
    
    //MARK: STAGE 3: UPLOAD POST
    
    @IBAction func postComplete(_ sender: Any) {
        
        if imageAdded || videoAdded {
            
            let range = imageID.index(imageID.endIndex, offsetBy: -4)..<imageID.endIndex
            imageID.removeSubrange(range)//'remove the .jpg/.mov from the imageID
            //postID needed for deletion
            postID = imageID
            
            //Get date and time posted (for feed sort)
            let timestamp = NSDate().timeIntervalSince1970
            
            postData = ["postID": postID, "isImage": imageAdded, "postURL": "", "thumbnailURL": "", "caption": "", "location": "", "timestamp": timestamp, "dimensions": dimensions]
            
            if let caption = captionContentView.text {
                postData!["caption"] = caption
                if let location = locationLabel.text {
                    postData!["location"] = location
                }
            }
            
            if let uid = Auth.auth().currentUser?.uid {
                
                //Upload the post content to cloud storage
                self.contentUpload(uid: uid) { (returnedURLs) in
                    
                    self.postData!["postURL"] = returnedURLs[0].absoluteString
                    if returnedURLs.count == 2 {
                        self.postData!["thumbnailURL"] = returnedURLs[1].absoluteString
                    }
                    
                    //Add the vid theumbnail if there is one
                    DataService.instance.updateDBPortfolioPosts(uid: uid, postID: self.postID, postData: self.postData!)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        } else {
            
            // User not added a photo
            displayError(title: "Oops", message: "Please add a photo or video to post")
        }
    }
}



