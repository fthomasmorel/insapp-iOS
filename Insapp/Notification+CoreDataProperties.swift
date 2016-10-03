//
//  Notification+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/3/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData


extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification");
    }

    @NSManaged public var content: String?
    @NSManaged public var receiver: String?
    @NSManaged public var sender: String?
    @NSManaged public var type: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var comment: Comment?
    @NSManaged public var id: String?
    @NSManaged public var seen: Bool
    @NSManaged public var message: String?

}
