//
//  APIManager+Event.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation

extension APIManager{
    
    static func fetchFutureEvents(completion:@escaping (_ events:[Event]) -> ()){
        requestWithToken(url: "/event", method: .get) { result in
            if var json = result as? [Dictionary<String, AnyObject>] {
                json = json.filter({ (event_json) -> Bool in
                    if let _ = Event.parseJson(event_json) {
                        return true
                    }else{
                        return false
                    }
                })
                let events = json.map({ (event_json) -> Event in
                    return Event.parseJson(event_json)!
                })
                completion(events)
            }else{
                return completion([])
            }
        }
    }
    
    static func fetchEvent(event_id: String, completion:@escaping (_ event:Optional<Event>) -> ()){
        requestWithToken(url: "/event/\(event_id)", method: .get) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Event.parseJson(json))
        }
    }
    
    static func participateToEvent(event_id: String, completion:@escaping (_ event:Optional<Event>) -> ()){
        let user_id = Credentials.fetch()!.userId
        requestWithToken(url: "/event/\(event_id)/participant/\(user_id)", method: .post) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            guard let json_event = json["event"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            guard let json_user = json["user"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            let _ = User.parseJson(json_user)
            completion(Event.parseJson(json_event))
        }
    }
    
    static func dismissEvent(event_id: String, completion:@escaping (_ event:Optional<Event>) -> ()){
        let user_id = Credentials.fetch()!.userId
        requestWithToken(url: "/event/\(event_id)/participant/\(user_id)", method: .delete) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            guard let json_event = json["event"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            guard let json_user = json["user"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            let _ = User.parseJson(json_user)
            completion(Event.parseJson(json_event))
        }
    }

}
