//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 2/29/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins = [Pin]()
    
    var temporaryContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uiLongPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uiLongPress)
        
        let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
        
        // Display existing pins on map
        displayExistingPins()
        
    }

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = false
        
        return annotationView
    }
    
    // Respond to taps on the annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let annotation = view.annotation else { /* no annotation */ return }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        print("Latitude: \(latitude), Longitude: \(longitude)")
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            for pin in results {
                if latitude == pin.latitude && longitude == pin.longitude {
                    let vc = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
                    vc.pin = pin
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
            
        } catch {
            print("Error in mapView: \(error)")
            showAlert("Error responding to the annotation.")
        }
    }
    
    func displayExistingPins() {
        // Debugging reference: http://stackoverflow.com/questions/25897122/executefetchrequest-throw-fatal-error-nsarray-element-failed-to-match-the-swift
        
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
            print("Error in displayExistingPins: \(error)")
            showAlert("Error displaying existing pins.")
        }
        
    }
    
    // Long press to drop pin
    // Reference: http://stackoverflow.com/questions/30858360/adding-a-pin-annotation-to-a-map-view-on-a-long-press-in-swift
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            // Save pin to Core Data
            let newPin = Pin(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude, context: self.sharedContext)
            
            self.pins.append(newPin)
            CoreDataStackManager.sharedInstance().saveContext()
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error " + error!.localizedDescription)
                    return
                }
                
                self.mapView.addAnnotation(annotation)
                
                print("Selected pin with coordinates: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")

            })
            
            // Download images from Flickr
            FlickrClient.sharedInstance().downloadPhotosForPin(newPin) { (success, error) in print("Error in downloadPhotosForPin: \(error)") }
            
        }
    }
    
}
