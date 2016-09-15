//
//  Post+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit


let kPostId             = "ID"
let kPostTitle          = "title"
let kPostAssociation    = "association"
let kPostDescription    = "description"
let kPostEvent          = "event"
let kPostDate           = "date"
let kPostLikes          = "likes"
let kPostComments       = "comments"
let kPostPhotoURL       = "photourl"
let kPostStatus         = "status"
let kPostImageSize      = "imageSize"

public class Post: NSManagedObject {

    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription = NSEntityDescription.entity(forEntityName: "Post", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(post_id: String, title: String, association: String, description: String, event: String, date: NSDate, likes: [String], comments: [Comment], photoURL: String, status: String, size:Dictionary<String, CGFloat>){
        super.init(entity: Post.entityDescription!, insertInto: Post.managedContext)
        self.id = post_id
        self.title = title
        self.desc = description
        self.association = association
        self.event = event
        self.date = date
        self.photourl = photoURL
        self.likes = likes
        self.comments = comments
        self.status = status
        self.imageSize = size
    }
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<Post>{
        guard let id            = json[kPostId] as? String          else { return .none }
        guard let title         = json[kPostTitle] as? String       else { return .none }
        guard let desc          = json[kPostDescription] as? String else { return .none }
        guard let association   = json[kPostAssociation] as? String else { return .none }
        guard let dateStr       = json[kPostDate] as? String        else { return .none }
        guard let event         = json[kPostEvent] as? String       else { return .none }
        guard let likes         = json[kPostLikes] as? [String]     else { return .none }
        guard let commentsJson  = json[kPostComments] as? [Dictionary<String, String>] else { return .none }
        guard let photoURL      = json[kPostPhotoURL] as? String    else { return .none }
        guard let status        = json[kPostStatus] as? String      else { return .none }
        guard let size          = json[kPostImageSize] as? Dictionary<String, CGFloat> else { return .none }
    
        guard let _             = size["width"]                     else { return .none }
        guard let _             = size["height"]                    else { return .none }
        guard let date          = dateStr.dateFromISO8602           else { return .none }
        
        let comments = Comment.parseJsonArray(commentsJson)
        
        return Post(post_id: id, title: title, association: association, description: desc, event: event, date: date, likes: likes, comments: comments, photoURL: photoURL, status: status, size: size)
    }
}
