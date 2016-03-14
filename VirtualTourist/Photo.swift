//
//  Photo.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/3/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    
    // Flickr URL image path
    @NSManaged var imageURL: String
    
    // Local file system image path
    @NSManaged var imagePath: String
    
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageURL: String, imagePath: String, pin: Pin, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Person" type.  This is an object that contains
        // the information from the VirtualTourist.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Person class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        self.imageURL = imageURL
        self.imagePath = imagePath
        self.pin = pin
        
    }
    
    var image: UIImage? {
        let fileName = (imagePath as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray = [dirPath, fileName]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
        
        return UIImage(contentsOfFile: fileURL.path!)
    }
    
    // Remove the photo's image when photo is deleted
    override func prepareForDeletion() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let pathArray = [dirPath, imagePath]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
        do {
            try NSFileManager.defaultManager().removeItemAtURL(fileURL)
        } catch let error as NSError {
            print("Error in prepareForDeletion: \(error)")
        }
    }
    
}
