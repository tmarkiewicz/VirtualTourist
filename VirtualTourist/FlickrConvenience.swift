//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/8/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import CoreData

extension FlickrClient {
    
    // Start download of pin images from Flickr
    func downloadPhotosForPin(pin: Pin, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        // Set a random page number for Flickr API
        // Reference: https://discussions.udacity.com/t/virtual-tourist-flickr-api-random-page-problem/45977/7
        var randomPageNumber: Int
        randomPageNumber = Int((arc4random_uniform(UInt32(40)))) + 1
        print("Random page number: \(randomPageNumber)")
        
        // request parameters
        let parameters: [String : AnyObject] = [
            JSONBodyKeys.Method : Methods.Search,
            JSONBodyKeys.APIKey : Constants.APIKey,
            JSONBodyKeys.Format : "json",
            JSONBodyKeys.NoJSONCallback : 1,
            JSONBodyKeys.Latitude : pin.latitude,
            JSONBodyKeys.Longitude : pin.longitude,
            JSONBodyKeys.Extras : "url_m",
            JSONBodyKeys.Page : randomPageNumber,
            JSONBodyKeys.PerPage : 21
        ]
        
        // Make GET request for get photos for pin
        taskForGETMethodWithParameters(parameters, completionHandler: {
            results, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                // Response dictionary
                if let photosDictionary = results.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject],
                    photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]],
                    numberOfPhotoPages = photosDictionary[JSONResponseKeys.Pages] as? Int {
                        
                        print("Number of photo pages from Flickr: \(numberOfPhotoPages)")
                        
                        // Dictionary with photos
                        for photoDictionary in photosArray {
                            
                            let photoURLString = photoDictionary[JSONValues.URLMediumPhoto] as! String
                            
                            // Create the Photos model
                            dispatch_async(dispatch_get_main_queue(), {
                                let newPhoto = Photo(imageURL: photoURLString, imagePath: "", pin: pin, context: self.sharedContext)
                            
                                print(newPhoto)
                                
                                // Download photo by URL
                                self.downloadPhotoImage(newPhoto, completionHandler: {
                                    success, error in
                                    
                                    print("Downloading photo by URL: \(success): \(error)")
                                    
                                    // Post NSNotification
                                    NSNotificationCenter.defaultCenter().postNotificationName("com.tmarkiewicz.downloadedPhotos", object: nil)
                                    
                                    // Save the context
                                    dispatch_async(dispatch_get_main_queue(), {
                                        CoreDataStackManager.sharedInstance().saveContext()
                                    })
                                })
                            })
                        }
                        completionHandler(success: true, error: nil)
                        
                } else {
                    completionHandler(success: false, error: NSError(domain: "downloadPhotosForPin", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to download photos for pin."]))
                }
            }
        })
    }
    

    // Download save image and change file path for photo
    func downloadPhotoImage(photo: Photo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let imageURLString = photo.imageURL
        
        // Make GET request for download photo by URL
        taskForGETMethod(imageURLString, completionHandler: {
            result, error in
            
            // If there is an error - set file path to error to show blank image
            if let error = error {
                print("Error from downloading images: \(error.localizedDescription )")
                photo.imagePath = "error"
                completionHandler(success: false, error: error)
                
            } else {
                if let result = result {
                    
                    // Get file name and file url
                    let fileName = (imageURLString as NSString).lastPathComponent
                    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                    let pathArray = [dirPath, fileName]
                    let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
                    print(fileURL)
                    
                    // Save file
                    NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: result, attributes: nil)
                    
                    // Update the photo model
                    dispatch_async(dispatch_get_main_queue(), {
                        photo.imagePath = fileURL.path!
                    })

                    completionHandler(success: true, error: nil)
                }
            }
        })
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}
