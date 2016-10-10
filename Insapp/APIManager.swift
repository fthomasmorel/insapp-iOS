//
//  APIManager.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import Alamofire

class APIManager: AnyObject{
    
    static var token:String!
    static let group = DispatchGroup()
    
    static func process(request: URLRequestConvertible, completion: @escaping (Optional<AnyObject>) -> (), errorBlock: @escaping (String, Int) -> (Bool)){
        { () -> Void in
            var retry = false
            //group.enter()
            //DispatchQueue.global().async {
                Alamofire.request(request).responseJSON { response in
                    guard let res = response.response else {
                        retry = errorBlock(kErrorServer, -1)
                        //group.leave()
                        return
                    }
                    var error = kErrorUnkown
                    if let dict = response.result.value as? Dictionary<String, AnyObject>{
                        if let err = dict["error"] as? String {
                            error = err
                        }
                    }
                    retry = errorBlock(error, res.statusCode)
                    if !retry {
                        completion(response.result.value as AnyObject)   
                    }
                    //group.leave()
                }
            //}
            //group.wait()
            //return retry
        }()
        
        //DispatchQueue.global().async {
            //let retry = proc()
            //if retry {
               // _ = proc()
            //}
        //}
    }
    
    static func requestWithToken(url:String, method: HTTPMethod, parameters: [String:AnyObject], completion: @escaping (Optional<AnyObject>) -> (), errorBlock:@escaping (String, Int) -> (Bool)){
        let token = APIManager.token!
        let url = URL(string: "\(kAPIHostname)\(url)?token=\(token)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        APIManager.process(request: req, completion: completion, errorBlock: errorBlock)
    }
    
    static func requestWithToken(url:String, method: HTTPMethod, completion: @escaping (Optional<AnyObject>) -> (), errorBlock:@escaping (String, Int) -> (Bool)){
        let token = APIManager.token!
        let url = URL(string: "\(kAPIHostname)\(url)?token=\(token)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        APIManager.process(request: req, completion: completion, errorBlock: errorBlock)
    }
    
    static func request(url:String, method: HTTPMethod, parameters: [String:AnyObject], completion: @escaping (Optional<AnyObject>) -> (), errorBlock:@escaping (String, Int) -> (Bool)){
        let url = URL(string: "\(kAPIHostname)\(url)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        APIManager.process(request: req, completion: completion, errorBlock: errorBlock)
    }
    
    static func request(url:String, method: HTTPMethod, completion: @escaping (Optional<AnyObject>) -> (), errorBlock:@escaping (String, Int) -> (Bool)){
        let url = URL(string: "\(kAPIHostname)\(url)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        APIManager.process(request: req, completion: completion, errorBlock: errorBlock)
    }
    
    static func requestCas(url:String, method: HTTPMethod, parameters: [String:AnyObject], completion: @escaping (Bool) -> (), errorBlock:@escaping (String, Int) -> (Bool)){
        let url = URL(string: "\(kCASHostname)\(url)")!
        var req = URLRequest(url: url)

        guard let username = parameters[kLoginUsername] else { completion(false) ; return }
        guard let password = parameters[kLoginPassword] else { completion(false) ; return }
        
        let data = "username=\(username)&password=\(password)"
        
        req.httpMethod = method.rawValue
        req.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        req.httpBody = data.data(using: .utf8, allowLossyConversion: false)
        
        Alamofire.request(req).response { (response) in
            guard let res = response.response, res.statusCode == 201 else {
                completion(false)
                return
            }
            completion(true)
        }
    }
}
