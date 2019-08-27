//
//  Extensions.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import GoogleMaps
import GooglePlaces

let imageCache = NSCache<NSString, UIImage>()

//MARK: General
extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //To hide keyboard
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Display Error Notification
    func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //Quick Sort an array of type generic
    func quickSort<T: Comparable>(array:[T]) -> [T] {
        if array.isEmpty { return [] }
        
        let first = array.first!
        
        let smallerOrEqual = array.dropFirst().filter { $0 <= first }
        let larger         = array.dropFirst().filter { $0 > first }
        
        return quickSort(array: smallerOrEqual) + [first] + quickSort(array: larger)
    }
    
    //ActionSheet for Before Image Picker
    func openPhotoPopup(video: Bool, imagePicker: UIImagePickerController, title: String, message: String){
        
        let photoPopup = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (buttonTapped) in
            
            do {
                self.openImagePicker(imagePicker: imagePicker, source: .camera)
            }
        }
        
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) {
            (buttonTapped) in
            
            do {
                self.openImagePicker(imagePicker: imagePicker, source: .photoLibrary)
            }
        }
        
        //So choosing videos is only sometimes an option
        if video {
            
            let videoAction = UIAlertAction(title: "Video Library", style: .default) { (buttonTapped) in
                
                do {
                    self.openImagePicker(imagePicker: imagePicker, source: .savedPhotosAlbum)
                }
            }
            photoPopup.addAction(videoAction)
        }
        
        photoPopup.addAction(cameraAction)
        photoPopup.addAction(photoAction)
        present(photoPopup, animated: true, completion: nil)
    }
    
    //The Image Picker
    func openImagePicker(imagePicker: UIImagePickerController, source: UIImagePickerController.SourceType) {
        
        //imagepicker is the user Photo Library/Camera/Video Library
        imagePicker.sourceType = source
        
        if source == .savedPhotosAlbum {
            imagePicker.mediaTypes = ["public.movie"]
        } else {
            imagePicker.mediaTypes = ["public.image"]
        }
        
        //Present View Controller
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Dismiss the imagePicker if the OS Cancels
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func downloadImage(url: URL, handler: @escaping (_ returnedImage: UIImage) -> ()) {
        //Get's the data of the URL
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                
                print(error.localizedDescription)
                
            } else {
                
                //So picture if first when UI loads
                DispatchQueue.main.async() {
                    
                    //Converts the image data to a UIImage
                    if let downloadedImage = UIImage(data: data!) {
                        
                        handler(downloadedImage)
                    }
                }
            }
        }
        //Resumes the task after image is set
        task.resume()
        
    }
    
    //Storing images as chache reduces the network usage of the app
    
    func loadImageCache(url: URL, isImage: Bool, handler: @escaping (_ returnedImage: UIImage) -> ()) {
        
        let urlString = url.absoluteString as NSString
        
        //Check for a chached image under that URL
        if let cachedImage = imageCache.object(forKey: urlString) {
            
            handler(cachedImage)
            
        } else {
            
            //if isImage {
            
            //Get's the data of the URL
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error{
                    
                    print(error.localizedDescription)
                    
                } else {
                    
                    //So picture if first when UI loads
                    DispatchQueue.main.async() {
                        
                        //Converts the image data to a UIImage
                        if let downloadedImage = UIImage(data: data!) {
                            
                            imageCache.setObject(downloadedImage, forKey: urlString)
                            
                            handler(downloadedImage)
                        }
                    }
                }
            }
            //Resumes the task after image is set
            task.resume()
            
            //            } else {
            //
            //                //If post is video, then generate a thumbnail to add
            //                let thumbnail = generateThumbnail(url: url)
            //
            //                imageCache.setObject(thumbnail, forKey: urlString)
            //                handler(thumbnail)
            //            }
        }
    }
    
    //SLOW LOADING!
    
    //Creates a thumnail from a video url
    func generateThumbnail(url: URL) -> UIImage {
        
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            
            return UIImage(named: "second")!
        }
    }
    
    //MARK: PUSH NOTIFICATIONS
    
    //Send a notification from a device to another device
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=SERVER-KEY", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    //FCM Server key: AAAAjb8BHzs:APA91bEBkZ3IfE6dU4xclXlP4qGVqyFhMLQEuCTA8NtFjKC7WGN_L8LeuaH_t7142RWGLbuYqjSHozuiz7HtmAADhGEz67yMOjN416Z-EdbIE9FXJ-0uyI37mcQ6bcMzbohxSzF4nCUJ
}



