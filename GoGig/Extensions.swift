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
        //alert conroller with a title and message and 'OK' dismiss button
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: LOADING INDICATOR
    func createSpinnerView( _ child: SpinnerViewController) {
        // add the spinner view controller
        //user cannot interact with the view
        self.view.isUserInteractionEnabled = false
        addChild(child)
        //fill screen and add to view
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func removeSpinnerView( _ child: SpinnerViewController) {
        //give user control again
        self.view.isUserInteractionEnabled = true
        //and remove from view
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    //MARK: GENERIC QUICK-SORT
    //Quick Sort an array of type generic
    func quickSort<T: Comparable>(array:[T]) -> [T] {
        //Base case for recursion (escape)
        if array.isEmpty { return [] }
        //Store the first element of the array to compare it with smaller or larger number
        let first = array.first!
        //first half = all values smaller or equal to first
        let smallerOrEqual = array.dropFirst().filter { $0 <= first }
        //second half = values larger than first
        let larger         = array.dropFirst().filter { $0 > first }
        //First and secoond half are recursed and inserted either side of the first value
        return quickSort(array: smallerOrEqual) + [first] + quickSort(array: larger)
    }
    
    //MARK: IMAGE PICKER ACTION SHEET
    func openPhotoPopup(video: Bool, imagePicker: UIImagePickerController, title: String, message: String){
        //The UIAlertController with title and message
        let photoPopup = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        //First Choice - Camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (buttonTapped) in
            
            do {
                //open the camera
                self.openImagePicker(imagePicker: imagePicker, source: .camera)
            }
        }
        //Second Choice - Photo Library
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) {
            (buttonTapped) in
            
            do {
                //open the library of photos
                self.openImagePicker(imagePicker: imagePicker, source: .photoLibrary)
            }
        }
        
        //So choosing videos is only sometimes an option
        if video {
            
            //Third Choice - Video Library
            let videoAction = UIAlertAction(title: "Video Library", style: .default) { (buttonTapped) in
                
                do {
                    //open the library of videos
                    self.openImagePicker(imagePicker: imagePicker, source: .savedPhotosAlbum)
                }
            }
            photoPopup.addAction(videoAction)
        }
        
        photoPopup.addAction(cameraAction)
        photoPopup.addAction(photoAction)
        //present the action sheet
        present(photoPopup, animated: true, completion: nil)
    }
    
    //MARK: IMAGE PICKER
    func openImagePicker(imagePicker: UIImagePickerController, source: UIImagePickerController.SourceType) {
        
        //imagepicker is the user Photo Library/Camera/Video Library
        imagePicker.sourceType = source
        
        if source == .savedPhotosAlbum {
            //Limit library to videos
            imagePicker.mediaTypes = ["public.movie"]
        } else {
            //Limit library to photos
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
                //print the error if one
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
            //Get's the data of the URL
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error{
                    
                    print(error.localizedDescription)
                    
                } else {
                    
                    //So picture if first when UI loads
                    DispatchQueue.main.async() {
                        
                        //Converts the image data to a UIImage
                        if let downloadedImage = UIImage(data: data!) {
                            
                            //set the cache for reused image
                            imageCache.setObject(downloadedImage, forKey: urlString)
                            
                            handler(downloadedImage)
                        }
                    }
                }
            }
            //Resumes the task after image is set
            task.resume()
            
            //SLOW LOADING!
            
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
    
    //MARK: VIDEO THUMBNAIL
    func generateThumbnail(url: URL) -> UIImage {
        
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            //Grab an image right at the start of the video
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            //Return the image
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            //Return placeholder if there is an error
            return UIImage(named: "second")!
        }
    }
    
    
    //MARK: ADD EVENT TO CALENDAR
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        //Add to event to calendar
        //Request calendar access
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            //If given access
            if (granted) && (error == nil) {
                //Create an event
                let event = EKEvent(eventStore: eventStore)
                //Set title, start and end, and any notes
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description //Notes is the description of the event
                
                //Check to see if "GoGig" calendar has been created - First time only
                if DEFAULTS.object(forKey: "GoGigCalendar") == nil {
                    //If new create the calendar
                    let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
                    //Calendar title
                    newCalendar.title = "GoGig - My Gigs"
                    //Colour
                    newCalendar.cgColor = UIColor.purple.cgColor
                    let sourcesInEventStore = eventStore.sources
                    newCalendar.source = sourcesInEventStore.filter {
                        (source: EKSource) -> Bool in
                        source.sourceType.rawValue == EKSourceType.local.rawValue
                    }.first!
                    do {
                        //Create new calendar (first time only, then set identifier with UserDefaults)
                       try eventStore.saveCalendar(newCalendar, commit: true)
                        DEFAULTS.set(newCalendar.calendarIdentifier, forKey: "GoGigCalendar")
                        print("new calendar created")
                    } catch {
                        self.displayError(title: "Oops", message: "Something went wrong")
                    }
                }
                
                //Set calendar event will be saved to
                event.calendar = eventStore.calendar(withIdentifier: DEFAULTS.object(forKey: "GoGigCalendar") as! String)
                do {
                    //Save the event with completion
                    try eventStore.save(event, span: .thisEvent)
                //Process any errors
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



