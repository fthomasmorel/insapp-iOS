//
//  Post+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post");
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var association: String?
    @NSManaged public var desc: String?
    @NSManaged public var event: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var likes: Array<String>?
    @NSManaged public var comments: [Comment]?
    @NSManaged public var photourl: String?
    @NSManaged public var status: String?
    @NSManaged public var imageSize: Dictionary<String,CGFloat>?

}
