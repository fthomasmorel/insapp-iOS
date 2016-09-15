//
//  User+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var desc: String?
    @NSManaged public var email: String?
    @NSManaged public var events: [String]?
    @NSManaged public var id: String?
    @NSManaged public var isEmailPublic: Bool
    @NSManaged public var name: String?
    @NSManaged public var promotion: String?
    @NSManaged public var username: String?

}
