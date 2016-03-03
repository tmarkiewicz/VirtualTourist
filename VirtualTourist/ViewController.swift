//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 2/29/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.delegate = self
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uiLongPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uiLongPress)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setLocations() {
        // create an MKPointAnnotation for each pin in CoreData
        
    }
    
    // Respond to taps on the annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
//        
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CollectionController") as! CollectionViewController
//        controller.setMapViewAnnotation(view.annotation!)
//        self.presentViewController(controller, animated: true, completion: nil)
        
        guard let annotation = view.annotation else { /* no annotation */ return }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        //let title = annotation.title
        mapView.deselectAnnotation(annotation, animated: true)
        
        print("lat: \(latitude), long: \(longitude)")
    }
    
    // http://stackoverflow.com/questions/30858360/adding-a-pin-annotation-to-a-map-view-on-a-long-press-in-swift
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                self.mapView.addAnnotation(annotation)
            })
        }
    }
    
}
