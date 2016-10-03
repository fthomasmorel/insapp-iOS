//
//  CommentTag+CoreDataProperties.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/2/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData


extension CommentTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CommentTag> {
        return NSFetchRequest<CommentTag>(entityName: "CommentTag");
    }

    @NSManaged public var user: String?
    @NSManaged public var name: String?

}
