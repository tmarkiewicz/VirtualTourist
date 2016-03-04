//
//  Photo.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/3/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import CoreData

class Photo : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let ImagePath = "image_path"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var imagePath: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Person" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Person class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        id = dictionary[Keys.ID] as! Int
        title = dictionary[Keys.Title] as! String
        imagePath = dictionary[Keys.ImagePath] as! String
    }
    
//    var posterImage: UIImage? {
//        get {
//            // return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
//            return FlickerNetworking.Caches.imageCache.imageWithIdentifier(flickerPath)
//        }
//        
//        set {
//            // TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
//            FlickerNetworking.Caches.imageCache.storeImage(newValue, withIdentifier: flickerPath!)
//        }
//    }
    
}
