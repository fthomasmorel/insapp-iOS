//
//  Credentials+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData


extension Credentials {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Credentials> {
        return NSFetchRequest<Credentials>(entityName: "Credentials");
    }

    @NSManaged public var authToken: String
    @NSManaged public var userId: String
    @NSManaged public var username: String

}
