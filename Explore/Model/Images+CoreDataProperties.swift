//
//  Images+CoreDataProperties.swift
//  FlickrFinder
//
//  Created by Abdulrahman on 12/01/2019.
//  Copyright © 2019 Abdulrahman. All rights reserved.
//
//

import Foundation
import CoreData


extension Images {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Images> {
        return NSFetchRequest<Images>(entityName: "Images")
    }

    @NSManaged public var id: Int64
    @NSManaged public var imageData: NSData?
    @NSManaged public var title: String?
    @NSManaged public var imageURL: String?

}
