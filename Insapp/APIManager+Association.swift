//
//  APIManager+Association.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


extension APIManager{
    
    static func fetchAssociations(controller: UIViewController, completion:@escaping ([Association]) -> ()){
        requestWithToken(url: "/association", method: .get, completion: { result in
            if var json = result as? [Dictionary<String, AnyObject>] {
                json = json.filter({ (association_json) -> Bool in
                    if let _ = Association.parseJson(association_json) {
                        return true
                    }else{
                        return false
                    }
                })
                let associations = json.map({ (association_json) -> Association in
                    return Association.parseJson(association_json)!
                })
                completion(associations)
            }else{
                return completion([])
            }
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func fetchAssociation(association_id: String, controller: UIViewController, completion:@escaping (Optional<Association>) -> ()){
        requestWithToken(url: "/association/\(association_id)", method: .get, completion: { result in
            if let json = result as? Dictionary<String, AnyObject> {
                completion(Association.parseJson(json))
            }else{
                return completion(.none)
            }
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }

}
