//
//  APIManager+Post.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation

extension APIManager {
    
//    Route{"GetPost", "GET", "/post/{id}", GetPostController},
//    Route{"GetLastestPost", "GET", "/post", GetLastestPostsController},
//    Route{"LikePost", "POST", "/post/{id}/like/{userID}", LikePostController},
//    Route{"DislikePost", "DELETE", "/post/{id}/like/{userID}", DislikePostController},
//    Route{"CommentPost", "POST", "/post/{id}/comment", CommentPostController},
//    Route{"UncommentPost", "DELETE", "/post/{id}/comment/{commentID}", UncommentPostController},
    
    static func fetchLastestPosts(completion:@escaping (_ posts:[Post]) -> ()){
        requestWithToken(url: "/post", method: .get) { result in
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
        }
    }
    
    static func fetchPost(post_id: String, completion:@escaping (_ post:Optional<Post>) -> ()){
        requestWithToken(url: "/post/\(post_id)", method: .get) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Post.parseJson(json))
        }
    }
    
    static func likePost(post_id: String, completion:@escaping (_ post:Optional<Post>) -> ()){
        let user_id = User.fetch()!.id!
        requestWithToken(url: "/post/\(post_id)/like/\(user_id)", method: .post) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            guard let json_post = json["post"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            guard let json_user = json["user"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            let _ = User.parseJson(json_user)
            completion(Post.parseJson(json_post))
        }
    }
    
    static func dislikePost(post_id: String, completion:@escaping (_ post:Optional<Post>) -> ()){
        let user_id = User.fetch()!.id!
        requestWithToken(url: "/post/\(post_id)/like/\(user_id)", method: .delete) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            guard let json_post = json["post"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            guard let json_user = json["user"] as? Dictionary<String, AnyObject> else{ completion(.none) ; return }
            let _ = User.parseJson(json_user)
            completion(Post.parseJson(json_post))
        }
    }
    
    static func comment(post_id: String, comment: Comment, completion:@escaping (_ post:Optional<Post>) -> ()){
        let params = Comment.toJson(comment)
        requestWithToken(url: "/post/\(post_id)/comment", method: .post, parameters: params as [String : AnyObject]) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Post.parseJson(json))
        }
    }
    
    static func uncomment(post_id: String, comment_id: String, completion:@escaping (_ post:Optional<Post>) -> ()){
        requestWithToken(url: "/post/\(post_id)/comment/\(comment_id)", method: .delete) { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Post.parseJson(json))
        }
    }
    

    
}
