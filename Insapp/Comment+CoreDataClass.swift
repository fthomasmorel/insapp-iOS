//
//  Comment+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Comment: NSManagedObject, NSCoding {

    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription = NSEntityDescription.entity(forEntityName: "Comment", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public func encode(with aCoder: NSCoder) { }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(entity: Comment.entityDescription!, insertInto: Comment.managedContext)
    }
    
    init(comment_id: String, user_id: String, content: String, date: NSDate){
        super.init(entity: Comment.entityDescription!, insertInto: Comment.managedContext)
        self.id = comment_id
        self.user_id = user_id
        self.content = content
        self.date = date
        self.tags = []
    }
    
    static func parseJson(_ json: Dictionary<String, AnyObject>) -> Optional<Comment> {
        guard let id        = json[kCommentId] as? String       else { return .none }
        guard let user_id   = json[kCommentUserId] as? String   else { return .none }
        guard let content   = json[kCommentContent] as? String  else { return .none }
        guard let dateStr   = json[kCommentDate] as? String     else { return .none }
        guard let date      = dateStr.dateFromISO8602           else { return .none }
        
        let comment = Comment(comment_id: id, user_id: user_id, content: content, date: date)
        
        guard let tags   = json[kCommentTags] as? [Dictionary<String, String>] else { return comment }
        comment.tags = CommentTag.parseArray(tags)
        return comment
    }
    
    static func parseJsonArray(_ array: [Dictionary<String, AnyObject>]) -> [Comment] {
        let commentsJson = array.filter({ (json) -> Bool in
            if let post = Comment.parseJson(json) {
                Comment.managedContext.delete(post)
                return true
            }else{
                return false
            }
        })
        
        let comments = commentsJson.map { (json) -> Comment in
            return Comment.parseJson(json)!
        }
        return comments
    }
    
    static func toJson(_ comment:Comment) -> Dictionary<String, AnyObject>{
        return [
            kCommentId: comment.id as AnyObject!,
            kCommentUserId: comment.user_id as AnyObject!,
            kCommentContent: comment.content as AnyObject!,
            //kCommentDate: String(describing: comment.date!) as AnyObject!,
            kCommentTags: CommentTag.toJson(tags: comment.tags!) as AnyObject!
        ]
    }
    

}
