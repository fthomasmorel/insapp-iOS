//
//  CommentTag+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/2/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData


public class CommentTag: NSManagedObject {
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription = NSEntityDescription.entity(forEntityName: "CommentTag", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public func encode(with aCoder: NSCoder) { }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(entity: CommentTag.entityDescription!, insertInto: CommentTag.managedContext)
    }
    
    init(user: String, name: String){
        super.init(entity: CommentTag.entityDescription!, insertInto: CommentTag.managedContext)
        self.user = user
        self.name = name
    }
    
    static func parseJson(_ json:Dictionary<String, String>) -> Optional<CommentTag>{
        guard let user = json[kCommentTagUser] else { return .none }
        guard let name = json[kCommentTagName] else { return .none }
        return CommentTag(user: user, name: name)
    }
    
    static func parseArray(_ array: [Dictionary<String, String>]) -> [CommentTag] {
        let commentTagsJson = array.filter({ (json) -> Bool in
            if let tag = CommentTag.parseJson(json) {
                CommentTag.managedContext.delete(tag)
                return true
            }else{
                return false
            }
        })
        let commentTags = commentTagsJson.map { (json) -> CommentTag in
            return CommentTag.parseJson(json)!
        }
        return commentTags
    }
    
    static func toJson(tag: CommentTag) -> Dictionary<String, String>{
        return [
            kCommentTagId   : "",
            kCommentTagUser : tag.user!,
            kCommentTagName : tag.name!
        ]
    }
    
    static func toJson(tags: [CommentTag]) -> [Dictionary<String, String>]{
        return tags.map({ (tag) -> Dictionary<String, String> in
            return CommentTag.toJson(tag: tag)
        })
    }
    
    
}
