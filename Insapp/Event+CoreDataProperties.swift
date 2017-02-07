//
//  Event+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData

extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var attendees: Array<String>?
    @NSManaged public var maybe: Array<String>?
    @NSManaged public var notgoing: Array<String>?
    @NSManaged public var comments: [Comment]?
    @NSManaged public var status: String?
    @NSManaged public var dateStart: NSDate?
    @NSManaged public var dateEnd: NSDate?
    @NSManaged public var photoURL: String?
    @NSManaged public var bgColor: String?
    @NSManaged public var fgColor: String?
    @NSManaged public var association: String?

}
