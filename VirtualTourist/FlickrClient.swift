//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/1/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient: NSObject {
    
    // Shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGETMethodWithParameters(parameters: [String : AnyObject],
        completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            // Build URL and configure the request
            let urlString = Constants.BaseURL + FlickrClient.escapedParameters(parameters)
            let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            // Make request
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                // Parse the received data
                if let error = downloadError {
                    let newError = FlickrClient.errorForResponse(data, response: response, error: error)
                    completionHandler(result: nil, error: newError)
                } else {
                    FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                }
            }
            // Start request
            task.resume()
    }

    func taskForGETMethod(urlString: String,
        completionHandler: (result: NSData?, error: NSError?) -> Void) {
            // Create the request
            let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            // Make the request
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                if let error = downloadError {
                    let newError = FlickrClient.errorForResponse(data, response: response, error: error)
                    completionHandler(result: nil, error: newError)
                } else {
                    completionHandler(result: data, error: nil)
                }
            }
            // Start the request
            task.resume()
    }

    // Substitute key for value that is contained within method name
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError?
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
            print("Parse error - \(parsingError!.localizedDescription)")
            return
        }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            if(!key.isEmpty) {
                // Make sure that it is a string value
                let stringValue = "\(value)"
                // Escape it
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                // Append it
                urlVars += [key + "=" + "\(escapedValue!)"]
            }
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    // Get error for response
    class func errorForResponse(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as? [String : AnyObject] {
            if let status = parsedResult[JSONResponseKeys.Status]  as? String,
                message = parsedResult[JSONResponseKeys.Message] as? String {
                    if status == "fail" {
                        return NSError(domain: "Virtual Tourist error", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
                    }
            }
        }
        return error
    }
    
    func createBoundingBoxString(latitude: Double?, longitude: Double?) -> String {
        print(latitude, longitude)
        
        let bottom_left_lon = max(longitude! - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude! - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude! + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat = min(latitude! + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}
