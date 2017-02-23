//
//  Image+CoreDataClass.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/17/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Image: NSManagedObject {

    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription =  NSEntityDescription.entity(forEntityName: "Image", in:managedContext)
    static let savingQueue = DispatchQueue(label: "savingQueue")
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(data: Data, url: String){
        super.init(entity: Image.entityDescription!, insertInto: Image.managedContext)
        self.data = data as NSData?
        self.url = url
        self.lastUsed = NSDate()
    }
    
    static func download(link: String, completion: @escaping (UIImage) -> ()){
        let url = URL(string: link)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil
                else { return }
            var image:UIImage?
            if link.hasSuffix(".gif") {
                image = UIImage.gifImageWithData(data: data as NSData)
            }else{
                image = UIImage(data: data)
//                Image.store(image: image!, forUrl: link)
            }
            completion(image!)
        }.resume()
    }
    
//    static func fetchImage(url:String) -> UIImage? {
//        let results = try! Image.managedContext.fetch(Image.fetchRequest()) as! [Image]
//        let images = results.filter { (image) -> Bool in
//            return image.url! == url
//        }
//        
//        if images.count > 0 {
//            let image = images.first!
//            image.lastUsed = NSDate()
//            Image.saveContext()
//            return UIImage(data: image.data as! Data, scale: 1.0)
//        }
//        return .none
//    }
//    
//    static func store(image: UIImage, forUrl url: String){
//        let width = UIScreen.main.bounds.size.width
//        let data = UIImageJPEGRepresentation(image.resize(width:  width), 0)
//        _ = Image(data: data!, url: url)
//        Image.saveContext()
//    }
//    
//    static func clean(){
//        let results = try! Image.managedContext.fetch(Image.fetchRequest()) as! [Image]
//        for image in results {
//            if Int(image.lastUsed!.timeIntervalSinceNow) > kMaxTimestampForImage {
//                Image.managedContext.delete(image)
//            }
//        }
//    }
    
    static func saveContext(){
        savingQueue.sync{
            do {
//                Image.clean()
                try Image.managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
}
