//
//  APIManager.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import Alamofire

let kAPIHostname = "https://api.thomasmorel.io"
let kCDNHostname = "https://cdn.thomasmorel.io/"
let kLoginPassword = "password"
let kLoginUsername = "username"

class APIManager: AnyObject{
    
    static var token:String!
    
    static func requestWithToken(url:String, method: HTTPMethod, parameters: [String:AnyObject], completion: @escaping (Optional<AnyObject>) -> ()){
        let token = APIManager.token!
        let url = URL(string: "\(kAPIHostname)\(url)?token=\(token)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Alamofire.request(req).responseJSON { response in
            completion(response.result.value as AnyObject)
        }
    }
    
    static func requestWithToken(url:String, method: HTTPMethod, completion: @escaping (Optional<AnyObject>) -> ()){
        let token = APIManager.token!
        let url = URL(string: "\(kAPIHostname)\(url)?token=\(token)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(req).responseJSON { response in
            completion(response.result.value as AnyObject)
        }
    }
    
    static func request(url:String, method: HTTPMethod, parameters: [String:AnyObject], completion: @escaping (Optional<AnyObject>) -> ()){
        let url = URL(string: "\(kAPIHostname)\(url)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Alamofire.request(req).responseJSON { response in
            completion(response.result.value as AnyObject)
        }
    }
    
    static func request(url:String, method: HTTPMethod, completion: @escaping (Optional<AnyObject>) -> ()){
        let url = URL(string: "\(kAPIHostname)\(url)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(req).responseJSON { response in
            completion(response.result.value as AnyObject)
        }
    }
}
