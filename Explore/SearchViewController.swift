//
//  SearchViewController.swift
//  FlickrFinder
//
//  Created by Abdulrahman on 06/12/2018.
//  Copyright © 2018 Abdulrahman. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    var keyboardOnScreen = false
    
    var imageURL: String = " "
    var imageData: Data!
    var imageTitle: String = " "
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var phraseSearchButton: UIButton!
    @IBOutlet weak var photoTitleLabel: UILabel!
    var dataController: DataController!
    let context = AppDelegate.viewContext
    
    override func viewDidLoad() {
        phraseTextField.delegate = self
        super.viewDidLoad()
        phraseTextField.borderStyle = UITextField.BorderStyle.roundedRect
        saveButton.layer.cornerRadius = 5
        phraseSearchButton.layer.cornerRadius = 5
        saveButton.isEnabled = false
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
        saveButton.sizeToFit()
        phraseSearchButton.sizeToFit()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromAllNotifications()
    }
    
    @IBAction func searchByPhrase(_ sender: Any) {
        guard !phraseTextField.text!.isEmpty else {
            photoTitleLabel.text = "phrase is empty"
            return
        }
        photoTitleLabel.text = "Searching ..."
        let parameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Text: phraseTextField.text!,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.SafeSearch,
            Constants.FlickrParameterKeys.Extra: Constants.FlickrParameterValues.Extra,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.Format,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJsonCallBack
        ]
        displayImageFromFlickrBySearch(methodParameters: parameters as [String : AnyObject])
    }

    
    private func FlickrURLFromParameters(parameters: [String: AnyObject]) -> URL {
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
    
    private func displayImageFromFlickrBySearch(methodParameters: [String: AnyObject]){
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURLFromParameters(parameters: methodParameters))
        print("request is: \(request)")
        let task = session.dataTask(with: request){(data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.printError(error: "could not load data")
                }
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
        }
        task.resume()
    }
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject],_ withPageNumber: Int){
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
                DispatchQueue.main.async {
                     self.printError(error: "could not load data")
                }
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
                                            self.setUIEnabled(true)
                                            self.photoImageView.image = UIImage(data: imageData)
                                            self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                                            //self.saveImage(imageURL: imageUrlString, imageData: imageData, imageTitle: photoTitle ?? "nil")
                                            self.imageData = imageData
                                            self.imageURL = imageUrlString
                                            self.imageTitle = photoTitle ?? "nil"
                                            self.saveButton.isEnabled = true
                                            print(self.imageTitle)
                                        }
                } else {
                    self.printError(error: "Image does not exist at \(String(describing: imageURL))")
                }
            }
        }
        task.resume()
    }
    

    private func printError(error: String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print(error)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        print(self.imageTitle)
        saveImage(imageURL: self.imageURL, imageData: self.imageData, imageTitle: self.imageTitle)
        let alert = UIAlertController(title: "Saved", message: "It's saved successfuly", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveImage(imageURL: String, imageData: Data?, imageTitle: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Images", in: context)
        let newImage = NSManagedObject(entity: entity!, insertInto: context)
        newImage.setValue(imageTitle, forKey: "title")
        newImage.setValue(imageData, forKey: "imageData")
        newImage.setValue(imageURL, forKey: "imageURL")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        print(keyboardHeight(notification))
        if keyboardHeight(notification) > 0 && !keyboardOnScreen{
            view.frame.origin.y = -keyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        if !keyboardOnScreen {
            view.frame.origin.y = 0
        }
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as Notification).userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func resignIfFirstResponder(_ textfield: UITextField){
        if textfield.isFirstResponder {
            textfield.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTabView(_ sender: AnyObject){
        resignIfFirstResponder(phraseTextField)
    }
    
    func isTextFieldValid(_ textField: UITextField, forRange: (Double, Double)) -> Bool{
        if let value = Double(textField.text!), !textField.text!.isEmpty{
            return isValueInRange(value, min: forRange.0, max: forRange.1)
        }
        return false
    }
    
    func isValueInRange(_ value: Double, min: Double, max: Double) -> Bool{
        return !(value < min || value > max)
    }
}

extension SearchViewController {
    func setUIEnabled(_ enabled: Bool){
        phraseTextField.isEnabled = enabled
        photoTitleLabel.isEnabled = enabled
        phraseSearchButton.isEnabled = enabled
    }
}

extension SearchViewController {
    func subscribeToNotification(_ notification: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
}


extension SearchViewController: NSFetchedResultsControllerDelegate {
}

