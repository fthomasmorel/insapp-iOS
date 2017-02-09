//
//  Event+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Event: NSManagedObject {
    
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription =  NSEntityDescription.entity(forEntityName: "Event", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(event_id: String, name: String, association: String, attendes: [String], maybe: [String], notgoing: [String], dateStart: NSDate, dateEnd: NSDate, fgColor: String, bgColor: String, photoURL: String, description: String){
        super.init(entity: Event.entityDescription!, insertInto: Event.managedContext)
        self.id = event_id
        self.name = name
        self.desc = description
        self.association = association
        self.attendees = attendes
        self.maybe = maybe
        self.notgoing = notgoing
        self.comments = []
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.photoURL = photoURL
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<Event>{
        guard let id            = json[kEventId] as? String          else { return .none }
        guard let name          = json[kEventName] as? String        else { return .none }
        guard let desc          = json[kEventDescription] as? String else { return .none }
        guard let association   = json[kEventAssociation] as? String else { return .none }
        guard let dateStartStr  = json[kEventDateStart] as? String   else { return .none }
        guard let dateEndStr    = json[kEventDateEnd] as? String     else { return .none }
        guard let fgColor       = json[kEventFgColor] as? String     else { return .none }
        guard let bgColor       = json[kEventBgColor] as? String     else { return .none }
        guard let photoURL      = json[kEventPhotoURL] as? String    else { return .none }
        
        guard let dateStart = dateStartStr.dateFromISO8601           else { return .none }
        guard let dateEnd = dateEndStr.dateFromISO8601               else { return .none }
        
        let event = Event(event_id: id, name: name, association: association, attendes: [], maybe: [], notgoing: [], dateStart: dateStart, dateEnd: dateEnd, fgColor: fgColor, bgColor: bgColor, photoURL: photoURL, description: desc)
        
        if let attendees = json[kEventAttendees] as? [String] {
            event.attendees = attendees
        }
        if let maybe = json[kEventMaybe] as? [String] {
            event.maybe = maybe
        }
        if let notgoing = json[kEventNotGoing] as? [String] {
            event.notgoing = notgoing
        }
        if let status = json[kEventStatus] as? String {
            event.status = status
        }
        if let commentsJson  = json[kEventComments] as? [Dictionary<String, AnyObject>] {
            let comments = Comment.parseJsonArray(commentsJson as [Dictionary<String, AnyObject>])
            event.comments = comments
        }
        return event
    }
    
    static func parseArray(_ array: [Dictionary<String, AnyObject>]) -> [Event] {
        let eventsJson = array.filter({ (json) -> Bool in
            if let event = Event.parseJson(json) {
                Event.managedContext.delete(event)
                return true
            }else{
                return false
            }
        })
        
        let events = eventsJson.map { (json) -> Event in
            return Event.parseJson(json)!
        }
        return events
    }
    
    static func sort(events: [Event]) -> [Event] {
        return events.sorted { (a, b) -> Bool in
            return a.dateStart!.timeIntervalSince(b.dateStart! as Date) < 0
        }
    }
    
    static func filter(events: [Event]) -> [Event] {
        return events.filter({ (event) -> Bool in
            return event.dateEnd!.timeIntervalSinceNow > 0
        })
    }
    
    static func filterPast(events: [Event]) -> [Event] {
        return events.filter({ (event) -> Bool in
            return event.dateEnd!.timeIntervalSinceNow < 0
        })
    }
    
    static func sortAndFilter(events: [Event]) -> [Event] {
        return sort(events: filter(events: events))
    }
    
    static func filterToday(events: [Event]) -> [Event] {
        return sort(events: events.filter({ (event) -> Bool in
            return event.dateStart!.isToday()
        }))
    }
    
    static func filterWeek(events: [Event]) -> [Event] {
        return sort(events: events.filter({ (event) -> Bool in
            return !event.dateStart!.isToday() && event.dateStart!.isThisWeek()
        }))
    }
    
    static func filterMonth(events: [Event]) -> [Event] {
        return sort(events: events.filter({ (event) -> Bool in
            return !event.dateStart!.isToday() && !event.dateStart!.isThisWeek() && event.dateStart!.isThisMonth()
        }))
    }
    
    static func filterOther(events: [Event]) -> [Event] {
        return sort(events: events.filter({ (event) -> Bool in
            return !event.dateStart!.isToday() && !event.dateStart!.isThisWeek() && !event.dateStart!.isThisMonth()
        }))
    }
}
