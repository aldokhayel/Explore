//
//  API.swift
//  FlickrFinder
//
//  Created by Abdulrahman on 11/01/2019.
//  Copyright © 2019 Abdulrahman. All rights reserved.
//

import Foundation
import UIKit

class API: NSObject {
    
    var SVC = SearchViewController()
    static let shared = API()
    func FlickrURLFromParameters(parameters: [String: AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Flickr.APISchema
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    func displayImageFromFlickrBySearch(methodParameters: [String: AnyObject]){
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURLFromParameters(parameters: methodParameters))
        print("request is: \(request)")
        let task = session.dataTask(with: request){(data, response, error) in
            guard let data = data else {
                self.printError(error: "There is no data")
                return
            }
            guard error == nil else {
                self.printError(error: "errro in task func \(String(describing: error))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.printError(error: "The response is more than 2xx!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                self.printError(error: "Could not parsed the data JSON \(data)")
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                self.printError(error: "Flickr API returned an error. See error code and message in \(String(describing: parsedResult))")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
                self.printError(error: "Could not find photos \(Constants.FlickrResponseKeys.Photos) in \(String(describing: parsedResult))")
                return
            }
            
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                self.printError(error: "Could not find page number \(Constants.FlickrResponseKeys.Pages) in \(photosDictionary)")
                return
            }
            
            let pageLimit = min(totalPages, 40)
            let randomPgae = Int(arc4random_uniform(UInt32(Int32(pageLimit)))) + 1
            self.displayImageFromFlickrBySearch(methodParameters, randomPgae)
            //print(data)
        }
        task.resume()
    }
    
    func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject],_ withPageNumber: Int){
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrResponseKeys.Pages] = withPageNumber as AnyObject
        
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURLFromParameters(parameters: methodParameters))
        let task =  session.dataTask(with: request){(data, response, error) in
            guard error == nil else {
                self.printError(error: "error in \(String(describing: error))")
                return
            }
            
            guard let data = data else {
                self.printError(error: "could not load data")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.printError(error: "the status code is more than 2xx!")
                return
            }
            
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            } catch {
                self.printError(error: "could not load data \(parsedResult)")
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status], stat as! String == Constants.FlickrResponseValues.OKStatus else {
                self.printError(error: "the status is not ok")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                self.printError(error: "could not load photos ")
                return
            }
            print(photosDictionary.count)
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                self.printError(error: "could not load photo")
                return
            }
            
            if photosArray.count == 0 {
                self.printError(error: "No Photos Found. Search Again.")
                return
            } else {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    self.printError(error: "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    performUIUpdatesOnMain {
                        self.SVC.setUIEnabled(true)
                        self.SVC.photoImageView.image = UIImage(data: imageData)
                        self.SVC.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                    }
                } else {
                    self.printError(error: "Image does not exist at \(String(describing: imageURL))")
                }
            }
        }
        task.resume()
    }
    
    
    private func printError(error: String){
        print(error)
    }
}
