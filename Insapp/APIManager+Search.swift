//
//  APIManager+Search.swift
//  Insapp
//
//  Created by Guillaume Courtet on 03/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

extension APIManager {
    
    /*
 Route{"SearchUser", "GET", "/search/users/{name}", SearchUserController},
	Route{"SearchAssociation", "GET", "/search/associations/{name}", SearchAssociationController},
	Route{"SearchEvent", "GET", "/search/events/{name}", SearchEventController},
	Route{"SearchPost", "GET", "/search/posts/{name}", SearchPostController},
	Route{"SearchUniversal", "GET", "/search/{name}", SearchUniversalController},
 */
    
    static func searchUser(word: String, controller: UIViewController, completion:@escaping (_ users:[User]) -> ()){
        let word = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        requestWithToken(url: "/search/users/\(word)", method: .get, completion: { (result) in
            guard let dict = result as? Dictionary<String, AnyObject>, let users = dict["users"] as? [Dictionary<String, AnyObject>] else { completion([]) ; return }
            completion(User.parseArray(users))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func searchPost(word: String, controller: UIViewController, completion:@escaping (_ posts:[Post]) -> ()){
        let word = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        requestWithToken(url: "/search/posts/\(word)", method: .get, completion: { (result) in
            guard let dict = result as? Dictionary<String, AnyObject>, let posts = dict["posts"] as? [Dictionary<String, AnyObject>] else { completion([]) ; return }
            completion(Post.parseArray(posts))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func searchEvent(word: String, controller: UIViewController, completion:@escaping (_ events:[Event]) -> ()){
        let word = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        requestWithToken(url: "/search/events/\(word)", method: .get, completion: { (result) in
            guard let dict = result as? Dictionary<String, AnyObject>, let events = dict["events"] as? [Dictionary<String, AnyObject>] else { completion([]) ; return }
            completion(Event.parseArray(events))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func searchAssociation(word: String, controller: UIViewController, completion:@escaping (_ associations:[Association]) -> ()){
        let word = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        requestWithToken(url: "/search/assosciation/\(word)", method: .get, completion: { (result) in
            guard let dict = result as? Dictionary<String, AnyObject>, let associations = dict["associations"] as? [Dictionary<String, AnyObject>] else { completion([]) ; return }
            completion(Association.parseArray(associations))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func search(word: String, controller: UIViewController, completion:@escaping (_ associations: [Association], _ users: [User], _ events: [Event], _ posts: [Post]) -> ()){
        let word = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        requestWithToken(url: "/search/\(word)", method: .get, completion: { (result) in
            guard let dict = result as? Dictionary<String, AnyObject> else { completion([], [], [], []) ; return }
            var associations:[Association] = []
            if let json = dict["associations"] as? [Dictionary<String, AnyObject>]{
                associations = Association.parseArray(json)
            }
            var users: [User] = []
            if let json = dict["users"] as? [Dictionary<String, AnyObject>]{
                users = User.parseArray(json)
            }
            var events: [Event] = []
            if let json = dict["events"] as? [Dictionary<String, AnyObject>]{
                events = Event.parseArray(json)
            }
            var posts: [Post] = []
            if let json = dict["posts"] as? [Dictionary<String, AnyObject>]{
                posts = Post.parseArray(json)
            }
            
            completion(associations, users, events, posts)
        }) { (errorMessage, statusCode) in
            return controller.triggerError(errorMessage, statusCode)
        }
    }
}

