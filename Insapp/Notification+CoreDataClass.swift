//
//  Notification+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/3/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData

public class Notification: NSManagedObject {
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription = NSEntityDescription.entity(forEntityName: "Notification", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public func encode(with aCoder: NSCoder) { }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(entity: Notification.entityDescription!, insertInto: Notification.managedContext)
    }
    
    init(id: String, sender: String, receiver: String, content: String, type: String, message: String, seen: Bool, date: NSDate){
        super.init(entity: Notification.entityDescription!, insertInto: Notification.managedContext)
        self.id = id
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.type = type
        self.message = message
        self.seen = seen
        self.date = date
    }
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<Notification>{
        guard let id        = json[kNotificationId] as? String          else { return .none }
        guard let sender    = json[kNotificationSender] as? String      else { return .none }
        guard let receiver  = json[kNotificationReceiver] as? String    else { return .none }
        guard let content   = json[kNotificationContent] as? String     else { return .none }
        guard let type      = json[kNotificationType] as? String        else { return .none }
        guard let message   = json[kNotificationMessage] as? String     else { return .none }
        guard let seen      = json[kNotificationSeen] as? Bool          else { return .none }
        guard let dateStr   = json[kNotificationDate] as? String        else { return .none }
        guard let date      = dateStr.dateFromISO8602                   else { return .none }
        guard type == kNotificationTypeEvent ||
              type == kNotificationTypePost  ||
              type == kNotificationTypeTag   ||
              type == kNotificationTypeEventTag else { return .none }
        
        let notification = Notification(id: id, sender: sender, receiver: receiver, content: content, type: type, message: message, seen: seen, date: date as NSDate)
        
        if type == kNotificationTypeTag || type == kNotificationTypeEventTag {
            guard let commentJson   = json[kNotificationComment] as? Dictionary<String, AnyObject>  else { return .none }
            guard let comment       = Comment.parseJson(commentJson)                                else { return .none }
            notification.comment = comment
        }
        
        
        
        return notification
    }
    
    static func parseArray(_ array: [Dictionary<String, AnyObject>]) -> [Notification] {
        let notificationsJson = array.filter({ (json) -> Bool in
            if let tag = Notification.parseJson(json) {
                Notification.managedContext.delete(tag)
                return true
            }else{
                return false
            }
        })
        let notifications = notificationsJson.map { (json) -> Notification in
            return Notification.parseJson(json)!
        }
        return notifications
    }
}
