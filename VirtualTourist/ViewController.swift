//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 2/29/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // var pins = [NSManagedObject]()
    var pins = [Pin]()
    
    var temporaryContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.delegate = self
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uiLongPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uiLongPress)
        
        let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
        
        // TODO: display existing pins on map
        displayExistingPins()
        
    }

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // Respond to taps on the annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
//        
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CollectionController") as! CollectionViewController
//        controller.setMapViewAnnotation(view.annotation!)
//        self.presentViewController(controller, animated: true, completion: nil)
        
        guard let annotation = view.annotation else { /* no annotation */ return }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        mapView.deselectAnnotation(annotation, animated: true)
        
        print("lat: \(latitude), long: \(longitude)")
    }

    func displayExistingPins() {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            
            for pin in results {
                let annotation = MKPointAnnotation()
                let core = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
                annotation.coordinate = core
                mapView.addAnnotation(annotation)
            }
            
        } catch {
            print("Error in displayExistingPins(): \(error)")
            showAlert("Error displaying existing pins.")
        }
        
    }
    
    // Long press to drop pin
    // Reference: http://stackoverflow.com/questions/30858360/adding-a-pin-annotation-to-a-map-view-on-a-long-press-in-swift
    //
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            // save pin to Core Data
            // let newPin = Pin(dictionary: coordinates, context: self.sharedContext)
            let newPin = Pin(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude, context: self.sharedContext)
            
            self.pins.append(newPin)
            CoreDataStackManager.sharedInstance().saveContext()
            
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                self.mapView.addAnnotation(annotation)
                
                print("selected pin with coordinates: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")

            })
        }
    }
    
}
