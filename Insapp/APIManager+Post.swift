//
//  APIManager+Post.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

extension APIManager {
    
    static func fetchLastestPosts(controller: UIViewController, completion:@escaping (_ posts:[Post]) -> ()){
        requestWithToken(url: "/post", method: .get, completion: { result in
            guard let postJsonArray = result as? [Dictionary<String, AnyObject>] else { completion([]) ; return }
            let json = postJsonArray.filter({ (post_json) -> Bool in
                if let _ = Post.parseJson(post_json) {
                    return true
                }else{
                    return false
                }
            })
            let posts = json.map({ (post_json) -> Post in
                return Post.parseJson(post_json)!
            })
            completion(posts)
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func fetchPost(post_id: String, controller: UIViewController, completion:@escaping (_ post:Optional<Post>) -> ()){
        requestWithToken(url: "/post/\(post_id)", method: .get, completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Post.parseJson(json))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func likePost(post_id: String, controller: UIViewController, completion:@escaping (_ post:Optional<Post>) -> ()){
        let user_id = User.fetch()!.id!
        requestWithToken(url: "/post/\(post_id)/like/\(user_id)", method: .post, completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            guard let json_post = json["post"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            guard let json_user = json["user"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            let _ = User.parseJson(json_user)
            completion(Post.parseJson(json_post))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func dislikePost(post_id: String, controller: UIViewController, completion:@escaping (_ post:Optional<Post>) -> ()){
        let user_id = User.fetch()!.id!
        requestWithToken(url: "/post/\(post_id)/like/\(user_id)", method: .delete, completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            guard let json_post = json["post"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            guard let json_user = json["user"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            let _ = User.parseJson(json_user)
            completion(Post.parseJson(json_post))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func comment(post_id: String, comment: Comment, controller: UIViewController, completion:@escaping (_ post:Optional<Post>) -> ()){
        let params = Comment.toJson(comment)
        requestWithToken(url: "/post/\(post_id)/comment", method: .post, parameters: params as [String : AnyObject], completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Post.parseJson(json))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func uncomment(post_id: String, comment_id: String, controller: UIViewController, completion:@escaping (_ post:Optional<Post>) -> ()){
        requestWithToken(url: "/post/\(post_id)/comment/\(comment_id)", method: .delete, completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Post.parseJson(json))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func report(comment: Comment, post: Post, controller: UIViewController){
        requestWithToken(url: "/report/\(post.id!)/comment/\(comment.id!)", method: .put, completion: { (_) in
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
}
