//
//  Image+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/17/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image");
    }

    @NSManaged public var url: String?
    @NSManaged public var data: NSData?
    @NSManaged public var lastUsed: NSDate?

}
