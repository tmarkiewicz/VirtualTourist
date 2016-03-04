//
//  Pin.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/3/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import MapKit
import CoreData

@objc(Pin)

class Pin : NSManagedObject {

    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double, long: Double, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Person" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Person class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        // id = dictionary[Keys.ID] as! Int
//        latitude = dictionary[Keys.Latitude] as! Double
//        longitude = dictionary[Keys.Longitude] as! Double
        self.latitude = lat
        self.longitude = long
        
    }
    
//    var location : CLLocationCoordinate2D {
//        get {
//            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        }
//        
//        set {
//            latitude = newValue.latitude
//            longitude = newValue.longitude
//        }
//    }
    
}
