//
//  Constants.swift
//  FlickrFinder
//
//  Created by Abdulrahman on 06/12/2018.
//  Copyright © 2018 Abdulrahman. All rights reserved.
//

import Foundation

struct Constants: Codable {
    struct Flickr: Codable {
        static let APISchema = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0,180.0)
    }
    
    struct FlickrParameterKeys: Codable {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extra = "extras"
        static let Format = "format"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct FlickrParameterValues: Codable {
        static let SearchMethod = "flickr.photos.search"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let APIKey = "b5d1ea4acc2308faa3010482092e46c7"
        static let GalleryID = "50736-72157623680420409"
        static let Extra = "url_m"
        static let Format = "json"
        static let SafeSearch = "1"
        static let BoundingBox = ""
        static let Page = ""
        static let DisableJsonCallBack = "1"
    }
    
    struct FlickrResponseKeys: Codable {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Page = "page"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues: Codable {
        static let OKStatus = "ok"
    }
}

