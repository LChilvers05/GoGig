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

//NSCache is used to store objects like a UIImage, NSCache requires the type to be AnyObject so you can store your cache using UIImage() if you incline to do so. Smart enough to know when to drop the images if too much memory is being used.

//subclass of the AutoComplete
//inherits methods to present the LocationAutoCompleteVC
class PortfolioPostVC: AutoComplete {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var postContainerView: PostContainerView!
    @IBOutlet weak var captionContentView: MyTextView!
    let loadingSpinner = SpinnerViewController()
    
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
    
    //dimensions to keep track of how to present the post in the portfolio
    var dimensions: [String : CGFloat] = ["height": 0.00, "width": 0.00]
    func updateDimensions(image: UIImage){
        dimensions["height"] = image.size.height
        dimensions["width"] = image.size.width
    }
    
    var height: CGFloat?
    var width: CGFloat?
    
    var placeholder = "Write a caption... |"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        captionContentView.updatePlaceholder(placeholder: placeholder)
        captionContentView.text = placeholder
        captionContentView.textColor = UIColor.lightGray
        
        hideKeyboard()
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
    }
    
    //go back to portfolio
    @IBAction func popView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: STAGE 1: OPTIONAL POST LOCATION
    
    //present Google Places view and return choice result
    @IBAction func addLocationButton(_ sender: Any) {
        presentAutocompleteVC()
        locationLabel.text = locationResult
    }
    
    
    //MARK: STAGE 2: POST CONTENT
    
    @IBAction func chooseImage(_ sender: Any) {
        //allow user to pick what to post
        openPhotoPopup(video: true, imagePicker: imagePicker!, title: "Post", message: "Take or choose a portfolio post")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //the info dictionary may contain multiple representations of the image. Use the original.
        if let selectedImage = info[.originalImage] as? UIImage {
            //add photo to preview
            postContainerView.addPhoto(imageContent: selectedImage, fit: true)
            
            imageContent = selectedImage
            //keep track of what has been added
            imageAdded = true
            videoAdded = false
            //set the dimensions of this post
            updateDimensions(image: imageContent!)
            //unique ID for the post
            imageID = "\(NSUUID().uuidString).jpg"
        }
        
        if let selectedVideo = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            postContainerView.addVideo(url: selectedVideo, fit: true)
            postContainerView.playPlayer()
            
            videoContent = selectedVideo
            videoAdded = true
            imageAdded = false
            
            let thumbnail = generateThumbnail(url: videoContent!)
            updateDimensions(image: thumbnail)
            
            imageID = "\(NSUUID().uuidString).mov"
        }
        
        
        //dismiss ImagePicker Controller
        dismiss(animated: true, completion: nil)
    }
    //upload the post to Storage
    func contentUpload(uid: String, handler: @escaping (_ returnedURLs: [URL]) ->()){
        //for video, there will be two urls (thumbnail and video itself)
        var urls = [URL]()
        
        if imageAdded {
            if let postImage =  imageContent {
                //add pic to Storage
                DataService.instance.updateSTPic(uid: uid, directory: "portfolioPost", imageContent: postImage, imageID: imageID, uploadComplete: { (success, error) in
                    if error != nil {
                        
                        self.removeSpinnerView(self.loadingSpinner)
                        self.displayError(title: "There was an Error", message: error!.localizedDescription)
                        
                    } else {
                        //get the url
                        DataService.instance.getSTURL(uid: uid, directory: "portfolioPost", imageID: self.imageID) { (returnedURL) in
                            
                            urls.append(returnedURL)
                            //return the url
                            handler(urls)
                            
                        }
                    }
                })
            }
        }
        //if video posting
        if videoAdded {
            if let postVideo = videoContent {
                //add the video to Storage
                DataService.instance.updateSTVid(uid: uid, directory: "portfolioPost", vidContent: postVideo, imageID: imageID, uploadComplete: { (success, error) in
                    if error != nil {
                        
                        self.removeSpinnerView(self.loadingSpinner)
                        self.displayError(title: "There was an Error", message: error!.localizedDescription)
                        
                    } else {
                        //get the url
                        DataService.instance.getSTURL(uid: uid, directory: "portfolioPost", imageID: self.imageID) { (returnedURL) in
                            //and upload the thumbnail as well
                            self.thumbnailUpload(uid: uid, url: postVideo) { (returnedThumbnailURL) in
                                //add both the video and thumbnail url to array
                                urls.append(returnedURL)
                                urls.append(returnedThumbnailURL)
                                //return the urls
                                handler(urls)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func thumbnailUpload(uid: String, url: URL, handler: @escaping (_ returnedThumbnailURL: URL) -> ()) {
        //generate a thumbnail from the video
        self.videoThumbnail = generateThumbnail(url: url)
        
        //upload the thumbnail
        DataService.instance.updateSTPic(uid: uid, directory: "portfolioThumbnail", imageContent: videoThumbnail!, imageID: imageID, uploadComplete: { (success, error) in
            if error != nil {
                self.removeSpinnerView(self.loadingSpinner)
                self.displayError(title: "There was an Error", message: error!.localizedDescription)
            } else {
                DataService.instance.getSTURL(uid: uid, directory: "portfolioThumbnail", imageID: self.imageID) { (returnedURL) in
                    //return the url
                    handler(returnedURL)
                }
            }
        })
    }
    
    //MARK: STAGE 3: UPLOAD POST
    
    @IBAction func postComplete(_ sender: Any) {
        
        if imageAdded || videoAdded {
            
            //postID needed for deletion
            postID = imageID
            
            let range = postID.index(postID.endIndex, offsetBy: -4)..<postID.endIndex
            postID.removeSubrange(range)//'remove the .jpg/.mov from the imageID
            
            //Get date and time posted (for feed sort)
            let timestamp = NSDate().timeIntervalSince1970
            //data dictionary
            postData = ["postID": postID, "isImage": imageAdded, "postURL": "", "thumbnailURL": "", "caption": "", "location": "", "timestamp": timestamp, "dimensions": dimensions]
            //caption is optional input
            if let caption = captionContentView.text {
                postData!["caption"] = caption
                //if not been edited
                if caption == "Write a caption... |" {
                    //set to empty string
                    postData!["caption"] = ""
                }
                if let location = locationLabel.text {
                    postData!["location"] = location
                }
            }
            
            if let uid = Auth.auth().currentUser?.uid {
                
                //upload the post content to cloud storage
                //and stop user interaction while it is uploaded
                createSpinnerView(loadingSpinner)
                self.contentUpload(uid: uid) { (returnedURLs) in
                    //set the post URL (first index of returned array
                    self.postData!["postURL"] = returnedURLs[0].absoluteString
                    //if there is two in array (will be video)
                    if returnedURLs.count == 2 {
                        //add the vid thumbnail if there is one
                        self.postData!["thumbnailURL"] = returnedURLs[1].absoluteString
                    }
                    
                    DataService.instance.updateDBPortfolioPosts(uid: uid, postID: self.postID, postData: self.postData!)
                    //allow user to interact with view again
                    self.removeSpinnerView(self.loadingSpinner)
                    //dismiss view
                    self.dismiss(animated: true, completion: nil)
                    //and refresh portfolio to show new post
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
                }
            }
            
        } else {
            
            //user not added a photo or video
            displayError(title: "Oops", message: "Please add a photo or video to post")
        }
    }
}



