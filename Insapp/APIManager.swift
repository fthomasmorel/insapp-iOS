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
    
    static func process(request: URLRequestConvertible, completion: @escaping (Optional<AnyObject>) -> (), errorBlock: @escaping (String, Int) -> (Bool)){
        let queue = DispatchQueue(label: "io.thomasmorel.insapp2")
        let proc: () -> (Bool) = {
            let group = DispatchGroup()
            var retry = false
            group.enter()
            DispatchQueue.global().async {
                Alamofire.request(request).responseJSON { response in
                    guard let res = response.response else {
                        retry = errorBlock(kErrorServer, -1)
                        group.leave()
                        return
                    }
                    retry = errorBlock(kErrorUnkown, res.statusCode)
                    if !retry {
                        completion(response.result.value as AnyObject)   
                    }
                    group.leave()
                }
            }
            group.wait()
            return retry
        }
        
        queue.async {
            let retry = proc()
            if retry {
                _ = proc()
            }
        }
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
        let token = APIManager.token!// + "fdsa"
        let url = URL(string: "\(kAPIHostname)\(url)?token=\(token)")!
        var req = URLRequest(url: url)
        
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        APIManager.process(request: req, completion: completion, errorBlock: errorBlock)
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
