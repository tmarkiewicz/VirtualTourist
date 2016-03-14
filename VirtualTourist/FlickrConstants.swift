//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Tom Markiewicz on 3/8/16.
//  Copyright © 2016 Tom Markiewicz. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        static let APIKey = "e729ad2419e46eded60b92ee5feb7fe3"
        static let BaseURL : String = "https://api.flickr.com/services/rest/"

        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
    
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    struct JSONBodyKeys {
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let Format = "format"
        static let Extras = "extras"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
        static let SAFE_SEARCH = "1"
    }
    
    struct JSONValues {
        static let JSONFormat = "json"
        static let URLMediumPhoto = "url_m"
    }
    
    struct JSONResponseKeys {
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Pages = "pages"
        static let Photos = "photos"
        static let Photo = "photo"
    }
    
}
