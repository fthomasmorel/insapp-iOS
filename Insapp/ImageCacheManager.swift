//
//  ImageCacheManager.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/23/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
class ImageCacheManager: AnyObject {

    private static var instance: ImageCacheManager?
    
    private var cache:[String: Image]
    
    static func sharedInstance() -> ImageCacheManager{
        if let result = instance {
            return result
        }
        instance = ImageCacheManager()
        return instance!
    }
    
    static func initialize(){
        instance = ImageCacheManager()
    }
    
    init() {
        self.cache = [:]
        let images = try! Image.managedContext.fetch(Image.fetchRequest()) as! [Image]
        for image in images {
            self.cache[image.url!] = image
        }
    }
    
    func fetchImage(url:String) -> UIImage? {
        if let image = self.cache[url]{
            image.lastUsed = NSDate()
            return UIImage(data: image.data as! Data, scale: 1.0)
        }
        return .none
    }
    
    func store(image: UIImage, forUrl url: String){
        let width = UIScreen.main.bounds.size.width
        let data = UIImageJPEGRepresentation(image.resize(width:  width), 0)
        let image = Image(data: data!, url: url)
        self.cache[url] = image
    }
    
    func save(){
        for image in self.cache.values  {
            if Int(image.lastUsed!.timeIntervalSinceNow) > kMaxTimestampForImage {
                Image.managedContext.delete(image)
            }
        }
        Image.saveContext()
    }
}
