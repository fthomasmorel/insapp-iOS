//
//  User+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let kUserId             = "ID"
let kUserName           = "name"
let kUserUsername       = "username"
let kUserDescription    = "description"
let kUserEmail          = "email"
let kUserEmailIsPublic  = "emailpublic"
let kUserPromotion      = "promotion"
let kUserEvents         = "events"
let kUserPostLiked      = "postsliked"
let kUserPhotoURL       = "photourl"

public class User: NSManagedObject {
    
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription =  NSEntityDescription.entity(forEntityName: "User", in:managedContext)
    static var userInstance: User?
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(user_id: String, username: String){
        super.init(entity: User.entityDescription!, insertInto: User.managedContext)
        self.id = user_id
        self.username = username
        self.name = ""
        self.desc = ""
        self.email = ""
        self.isEmailPublic = false
        self.promotion = ""
        self.events = []
    }
    
    static func fetch() -> Optional<User>{
        return User.userInstance
    }
    
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<User>{
        guard let id            = json[kUserId] as? String          else { return .none }
        guard let username      = json[kUserUsername] as? String    else { return .none }
        
        let user = User(user_id: id, username: username)
        
        if Credentials.fetch()!.userId == id {
            User.userInstance = user
        }
        
        guard let name          = json[kUserName] as? String        else { return user }
        guard let desc          = json[kUserDescription] as? String else { return user }
        guard let email         = json[kUserEmail] as? String       else { return user }
        guard let isEmailPublic = json[kUserEmailIsPublic] as? Bool else { return user }
        guard let promotion     = json[kUserPromotion] as? String   else { return user }
        guard let events        = json[kUserEvents] as? [String]    else { return user }
        
        user.name = name
        user.desc = desc
        user.email = email
        user.isEmailPublic = isEmailPublic
        user.promotion = promotion
        user.events = events
        
        return user
    }
    
    static func toJson(_ user: User) -> Dictionary<String, AnyObject> {
        return [
            kUserId: user.id! as AnyObject,
            kUserName: user.name! as AnyObject,
            kUserUsername: user.username! as AnyObject,
            kUserEmail: user.email! as AnyObject,
            kUserPromotion: user.promotion! as AnyObject,
            kUserEmailIsPublic: user.isEmailPublic as AnyObject,
            kUserDescription: user.desc! as AnyObject
        ]
    }
}
