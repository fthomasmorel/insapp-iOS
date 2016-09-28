//
//  Association+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Association: NSManagedObject {

    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription =  NSEntityDescription.entity(forEntityName: "Association", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(association_id: String, name: String, email: String, description: String){
        super.init(entity: Association.entityDescription!, insertInto: Association.managedContext)
        self.id = association_id
        self.name = name
        self.email = email
        self.desc = description
        self.events = []
        self.profilePhotoURL = ""
        self.coverPhotoURL = ""
        self.bgColor = ""
        self.fgColor = ""
    }
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<Association>{
        guard let id        = json[kAssociationId] as? String           else { return .none }
        guard let name      = json[kAssociationName] as? String         else { return .none }
        guard let email     = json[kAssociationEmail] as? String        else { return .none }
        guard let desc      = json[kAssociationDescription] as? String  else { return .none }
        guard let profile   = json[kAssociationProfile] as? String      else { return .none }
        guard let cover     = json[kAssociationCover] as? String        else { return .none }
        guard let bgColor   = json[kAssociationBgColor] as? String      else { return .none }
        guard let fgColor   = json[kAssociationFgColor] as? String      else { return .none }
        
        let association = Association(association_id: id, name: name, email: email, description: desc)
        association.profilePhotoURL = profile
        association.coverPhotoURL = cover
        association.bgColor = bgColor
        association.fgColor = fgColor
        
        guard let events    = json[kAssociationEvents] as? Array<String>else { return association }
        association.events = events
    
        return association
    }
    
}
