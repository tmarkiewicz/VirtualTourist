//
//  Common.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/1/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
}
