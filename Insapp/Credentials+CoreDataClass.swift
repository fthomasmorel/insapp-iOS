//
//  Credentials+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let kCredentialsAuthToken  = "authtoken"
let kCredentialsUsername   = "username"
let kCredentialsUserId     = "user"

public class Credentials: NSManagedObject {
    
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription =  NSEntityDescription.entity(forEntityName: "Credentials", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(username: String, userId: String, authToken: String){
        super.init(entity: Credentials.entityDescription!, insertInto: Credentials.managedContext)
        self.authToken = authToken
        self.username = username
        self.userId = userId
    }
    
    static func fetch() -> Optional<Credentials>{
        do {
            let results = try Credentials.managedContext.fetch(Credentials.fetchRequest()) as! [Credentials]
            return results.first
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return .none
    }
    
    static func saveContext(){
        do {
            try Credentials.managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    static func delete(){
        let results = try! Credentials.managedContext.fetch(Credentials.fetchRequest()) as! [Credentials]
        for credentials in results {
            Credentials.managedContext.delete(credentials)
        }
        Credentials.saveContext()
    }
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<Credentials>{
        guard let authToken = json[kCredentialsAuthToken] as? String  else { return .none }
        guard let username  = json[kCredentialsUsername] as? String   else { return .none }
        guard let userId    = json[kCredentialsUserId] as? String     else { return .none }
        
        Credentials.delete()
        
        let credentials = Credentials(username: username, userId: userId, authToken: authToken)
        return credentials
    }
}
