//
//  Extension.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func changeStatusBarForColor(colorStr: String? = "ffffff"){
        if colorStr == "ffffff" {
            self.lightStatusBar()
        }else{
            self.darkStatusBar()
        }
    }
    
    func darkStatusBar(){
        UIApplication.shared.statusBarStyle = .default
    }
    
    func lightStatusBar(){
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
}

extension UIColor{
    
    static func hexToRGB(_ hex: String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines))
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIImageView {
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill, completion: Optional<() -> ()> = nil ){
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.startAnimating()
        loader.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        DispatchQueue.main.async {
            if self.image == nil {
                self.addSubview(loader)
            }
        }
        guard let url = URL(string: link) else { return }
        contentMode = mode
        
        if let image = Image.fetchImage(url: link){
            self.displayImage(image, completion: completion)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }
            Image.store(image: image, forUrl: link)
            self.displayImage(image, completion: completion)
            }.resume()
    }
    
    func displayImage(_ image: UIImage, completion: Optional<() -> ()> = nil){
        DispatchQueue.main.async() { () -> Void in
            for subview in self.subviews{
                if subview is UIActivityIndicatorView {
                    subview.removeFromSuperview()
                }
            }
            if self.image == nil {
                self.alpha = 0
                self.image = image
                if let ack = completion { ack() }
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 1
                })
            }else{
                self.image = image
                if let ack = completion { ack() }
            }
        }
    }
}

extension Date {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ssX"
            return formatter
        }()
        static let iso8602: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()
    }
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    var iso8602: String {
        return Formatter.iso8602.string(from: self)
    }
}

extension NSDate {
    static func stringForInterval(start: NSDate, end: NSDate, day: Bool = true) -> String {
        let calendar = NSCalendar.current
        
        let days = [ "Samedi", "Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi" ]
        
        let startWeekDay = days[calendar.component(.weekday, from: start as Date)]
        let startDay = calendar.component(.day, from: start as Date)
        let startMonth = calendar.component(.month, from: start as Date)
        let startHour = calendar.component(.hour, from: start as Date)
        let startMinute = calendar.component(.minute, from: start as Date)
        
        let endWeekDay = days[calendar.component(.weekday, from: end as Date)]
        let endDay = calendar.component(.day, from: end as Date)
        let endMonth = calendar.component(.month, from: end as Date)
        
        if end.timeIntervalSince(start as Date) < 86400 {
            if day {
                return "\(startWeekDay) \(startDay)/\(startMonth) à \(startHour):\(startMinute)"
            }else{
                return "Le \(startDay)/\(startMonth) à \(startHour):\(startMinute)"
            }
        }else{
            if day {
                return "Du \(startWeekDay) \(startDay)/\(startMonth) au \(endWeekDay) \(endDay)/\(endMonth)"
            }else{
                return "Du \(startDay)/\(startMonth) au \(endDay)/\(endMonth)"
            }
        }
    }
    
    func timestamp() -> String {
        let timeInterval = -Int(self.timeIntervalSinceNow)
        switch timeInterval {
        case let interval where interval < 3600:        //minutes
            let minutes = Int(floor(Double(interval/60)))
            return "\(minutes)m"
        case let interval where interval < 86400:       //hours
            let hours = Int(floor(Double(interval/3600)))
            return "\(hours)h"
        case let interval where interval < 604800:      //days
            let days = Int(floor(Double(interval/86400)))
            return "\(days)d"
        default:                                        //weeks
            let weeks = Int(floor(Double(timeInterval/604800)))
            return "\(weeks)w"
        }
    }
}


extension String {
    var dateFromISO8601: NSDate? {
        return Date.Formatter.iso8601.date(from: self) as NSDate?
    }
    var dateFromISO8602: NSDate? {
        return Date.Formatter.iso8602.date(from: self) as NSDate?
    }
}

extension UITextView {
    
    static func heightForContent(_ content: String, andWidth width: CGFloat) -> CGFloat {
        let fixedWidth = width
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let contentSize = textView.sizeThatFits(textView.bounds.size)
        return contentSize.height
    }
}
