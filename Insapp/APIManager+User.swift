//
//  APIManager+User.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation

enum Result {
    case success
    case failure
}

extension APIManager{
    
    static func fetch(user_id: String, completion:@escaping (_ user:Optional<User>) -> ()){
        requestWithToken(url: "/user/\(user_id)", method: .get) { (result) in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(User.parseJson(json))
        }
    }
    
    static func update(user: User, completion:@escaping (_ user:Optional<User>) -> ()){
        let params = User.toJson(user)
        requestWithToken(url: "/user/\(user.id!)", method: .put, parameters: params) { (result) in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(User.parseJson(json))
        }
    }
    
    static func delete(user: User, completion:@escaping (_ user:Result) -> ()){
        requestWithToken(url: "/user/\(user.id!)", method: .delete) { (result) in
            guard let _ = result as? Dictionary<String, AnyObject> else { completion(.failure)  ; return }
            completion(.success)
        }
    }
}
