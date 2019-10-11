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
import EventKit

let imageCache = NSCache<NSString, UIImage>()

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: HIDE KEYBOARD
    //To hide keyboard
    func hideKeyboard() {
        //Gesture recogniser so we call method when the screen is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        //if the user taps inside the keyboard, ignore
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        //dismiss the keyboard (end editing)
        view.endEditing(true)
    }
    
    //MARK: ERROR NOTIFICATION
    func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: LOADING INDICATOR
    func createSpinnerView( _ child: SpinnerViewController) {
        // add the spinner view controller
        self.view.isUserInteractionEnabled = false
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func removeSpinnerView( _ child: SpinnerViewController) {
        self.view.isUserInteractionEnabled = true
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    //MARK: GENERIC QUICK-SORT
    //Quick Sort an array of type generic
    func quickSort<T: Comparable>(array:[T]) -> [T] {
        if array.isEmpty { return [] }
        
        let first = array.first!
        
        let smallerOrEqual = array.dropFirst().filter { $0 <= first }
        let larger         = array.dropFirst().filter { $0 > first }
        
        return quickSort(array: smallerOrEqual) + [first] + quickSort(array: larger)
    }
    
    //MARK: IMAGE PICKER ACTION SHEET
    func openPhotoPopup(video: Bool, imagePicker: UIImagePickerController, title: String, message: String){
        //The UIAlertController
        let photoPopup = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        //First Choice - Camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (buttonTapped) in
            
            do {
                self.openImagePicker(imagePicker: imagePicker, source: .camera)
            }
        }
        //Second Choice - Photo Library
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) {
            (buttonTapped) in
            
            do {
                self.openImagePicker(imagePicker: imagePicker, source: .photoLibrary)
            }
        }
        
        //So choosing videos is only sometimes an option
        if video {
            
            //Third Choice - Video Library
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
    
    //MARK: IMAGE PICKER
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
    
    //MARK: DOWNLOAD IMAGE
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
    
    //MARK: IMAGE CACHE
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
    
    //MARK: VIDEO THUMBNAIL
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
    
    
    //MARK: ADD EVENT TO CALENDAR
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
//        //Check to see if "GoGig" calendar has been created - First time only
//        if DEFAULTS.object(forKey: "GoGigCalendar") == nil {
//            let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
//            newCalendar.title = "GoGig - My Gigs"
//            newCalendar.cgColor = UIColor.purple.cgColor
//            let sourcesInEventStore = eventStore.sources
//            newCalendar.source = sourcesInEventStore.filter {
//                (source: EKSource) -> Bool in
//                source.sourceType.rawValue == EKSourceType.local.rawValue
//            }.first!
//            do {
//               try eventStore.saveCalendar(newCalendar, commit: true)
//                DEFAULTS.set(newCalendar.calendarIdentifier, forKey: "GoGigCalendar")
//                print("new calendar created")
//            } catch {
//                displayError(title: "Oops", message: "Something went wrong")
//            }
//        }
        
        //Add to event to calendar
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                
                //Check to see if "GoGig" calendar has been created - First time only
                if DEFAULTS.object(forKey: "GoGigCalendar") == nil {
                    let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
                    newCalendar.title = "GoGig - My Gigs"
                    newCalendar.cgColor = UIColor.purple.cgColor
                    let sourcesInEventStore = eventStore.sources
                    newCalendar.source = sourcesInEventStore.filter {
                        (source: EKSource) -> Bool in
                        source.sourceType.rawValue == EKSourceType.local.rawValue
                    }.first!
                    do {
                       try eventStore.saveCalendar(newCalendar, commit: true)
                        DEFAULTS.set(newCalendar.calendarIdentifier, forKey: "GoGigCalendar")
                        print("new calendar created")
                    } catch {
                        self.displayError(title: "Oops", message: "Something went wrong")
                    }
                }
                
                event.calendar = eventStore.calendar(withIdentifier: DEFAULTS.object(forKey: "GoGigCalendar") as! String)
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
}



