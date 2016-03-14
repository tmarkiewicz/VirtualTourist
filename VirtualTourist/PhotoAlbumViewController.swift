//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/5/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var pin: Pin? = nil
    var photos = [Photo]()
    
    // Start off not deleting, with bottom button title labeled "Refresh Collection"
    // If user selects a picture, button switches to delete mode
    var isDeleteMode = false
    
    // Array of selected image cells to delete
    var selectedCollectionViewCells = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomButton.backgroundColor = UIColor(white: 1, alpha: 1.0)
        noImagesLabel.hidden = true
        
        // Load the map view for selected pin
        mapView.delegate = self
        displayPinLocation()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Fetch photos for selected pin
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("\(error)")
        }
        
        // Set delegate to this view controller
        fetchedResultsController.delegate = self
        
        // Look for notifications from FlickrConvenience, in order to know when to reload photos in collection view
        // Reference: https://discussions.udacity.com/t/virtual-tourist-app-architecture-for-pre-fetching-photos/46756/5
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadPhotos:", name: "com.tmarkiewicz.downloadedPhotos", object: nil)
        
    }
    
    func reloadPhotos(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
        })
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func bottomButton(sender: AnyObject) {
        if isDeleteMode == true {
            // Remove each selected photo from array
            for indexPath in selectedCollectionViewCells {
                let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
                print("Deleting photo: \(photo)")
                sharedContext.deleteObject(photo)
            }
            
            selectedCollectionViewCells.removeAll()
            
            // Save new collection to Core Data
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance().saveContext()
            })
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("\(error)")
            }
            
            collectionView.reloadData()
            bottomButton.setTitle("Refresh Collection", forState: UIControlState.Normal)
            isDeleteMode = false
            
        } else {
            // Delete existing photos
            for photo in fetchedResultsController.fetchedObjects as! [Photo]{
                sharedContext.deleteObject(photo)
            }
            
            // Save to Core Data
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance().saveContext()
            })
            
            // Refresh collection from Flickr
            print("Reloading from Flickr")
            FlickrClient.sharedInstance().downloadPhotosForPin(pin!, completionHandler: {
                success, error in
                
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        CoreDataStackManager.sharedInstance().saveContext()
                    })
                    
                } else {
                    print("Error refreshing collection from Flickr")
                    
                }
                
                // Finally, update the cells with new photo collection
                dispatch_async(dispatch_get_main_queue(), {
                    // Fetch photos for selected pin
                    do {
                        try self.fetchedResultsController.performFetch()
                    } catch let error as NSError {
                        print("\(error)")
                    }
                    self.collectionView.reloadData()
                })
            })
            
        }
    }
    
    // Display pin's location on map
    func displayPinLocation(){
        let span = MKCoordinateSpanMake(3, 3)
        let annotation = MKPointAnnotation()
        let cord = CLLocationCoordinate2D(latitude: Double((pin!.latitude)), longitude: Double((pin!.longitude)))
        annotation.coordinate = cord
        let region = MKCoordinateRegion(center: cord, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    // Fetched results controller
    // Lazily computed property pointing to the Photo entity objects, sorted by image URL, predicated on the pin
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create fetch request for photos which match the Pin
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        // Limit the fetch request to just those photos related to the Pin
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        // Sort the fetch request by url path, ascending
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        
        // Create fetched results controller with the new fetch request
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Return the number of photos from fetchedResultsController
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("Number of photos returned from fetchedResultsController: \(sectionInfo.numberOfObjects)")

        // If no images for a pin, then show no images label
        if sectionInfo.numberOfObjects == 0 {
            noImagesLabel.hidden = false
        }
        
        return sectionInfo.numberOfObjects
    }
    
    // Remove photos from an album when user select a cell(s)
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        if let index = selectedCollectionViewCells.indexOf(indexPath){
            selectedCollectionViewCells.removeAtIndex(index)
            let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            cell.photoImageView.image = photo.image
            print("Removed cell from deletion")
            
        } else {
            selectedCollectionViewCells.append(indexPath)
            cell.photoImageView.image = UIImage(named: "placeholder")
            print("Selected cell for deletion")
        }
        
        print(selectedCollectionViewCells)
        
        if selectedCollectionViewCells.count > 0 {
            isDeleteMode = true
            print("Delete mode: \(isDeleteMode)")
            bottomButton.setTitle("Delete selected photos", forState: UIControlState.Normal)
            
        } else {
            isDeleteMode = false
            print("Delete mode: \(isDeleteMode)")
        }
    }
    
    // Retrieve and configure cell image
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Set the placeholder image
        cell.photoImageView.image = UIImage(named: "placeholder")
        
        if photo.image != nil {
            cell.photoImageView.image = photo.image
        }
        
        return cell
    }
}
