//
//  Association+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData

extension Association {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Association> {
        return NSFetchRequest<Association>(entityName: "Association");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var desc: String?
    @NSManaged public var profilePhotoURL: String?
    @NSManaged public var coverPhotoURL: String?
    @NSManaged public var bgColor: String?
    @NSManaged public var fgColor: String?
    @NSManaged public var events: Array<String>?
    @NSManaged public var posts: Array<String>?

}
