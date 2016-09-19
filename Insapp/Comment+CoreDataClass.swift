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
    }
    
    static func parseJson(_ json: Dictionary<String, String>) -> Optional<Comment> {
        guard let id        = json[kCommentId]          else { return .none }
        guard let user_id   = json[kCommentUserId]      else { return .none }
        guard let content   = json[kCommentContent]     else { return .none }
        guard let dateStr   = json[kCommentDate]        else { return .none }
        guard let date      = dateStr.dateFromISO8602   else { return .none }
        
        let comment = Comment(comment_id: id, user_id: user_id, content: content, date: date)
        
        return comment
    }
    
    static func parseJsonArray(_ array: [Dictionary<String, String>]) -> [Comment] {
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
    
    static func toJson(_ comment:Comment) -> Dictionary<String, String>{
        return [
            kCommentId: comment.id!,
            kCommentUserId: comment.user_id!,
            kCommentContent: comment.content!,
            kCommentDate: String(describing: comment.date!)
        ]
    }
    

}
