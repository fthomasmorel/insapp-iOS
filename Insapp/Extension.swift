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
    
    var loadingView:UIView {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = .black
        view.alpha = 0.7
        
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loader.startAnimating()
        loader.center = view.center
        
        view.addSubview(loader)
        view.tag = 2
        
        return view
    }
    
    func notifyGoogleAnalytics(){
        var name = NSStringFromClass(type(of: self)).replacingOccurrences(of: "ViewController", with: "")
        if self is AssociationViewController {
            name+="-\((self as! AssociationViewController).association.name!)"
        }
        if self is EventViewController {
            name+="-\((self as! EventViewController).event.name!)"
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder!.build() as [NSObject : AnyObject])
    }
    
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
    
    func startLoading(){
        self.view.addSubview(self.loadingView)
    }
    
    func stopLoading(){
        self.view.viewWithTag(2)?.removeFromSuperview()
    }
    
    func hideNavBar(){
        self.navigationController?.navigationBar.isHidden = true
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

extension UIImage{
    
    func resize(width: CGFloat) -> UIImage{
        let image = self
        let ratio = width/image.size.width
        let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
        let hasAlpha = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

extension UIImageView {
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill, animated: Bool = true, completion: Optional<() -> ()> = nil ){
        
        guard let url = URL(string: link) else { return }
        contentMode = mode
        
        if let image = ImageCacheManager.sharedInstance().fetchImage(url: link){
            self.displayImage(image, animated: animated, completion: completion)
            return
        }
        
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.startAnimating()
        loader.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        DispatchQueue.main.async {
            if self.image == nil {
                self.addSubview(loader)
            }
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
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
                ImageCacheManager.sharedInstance().store(image: image!, forUrl: link)
            }
            self.displayImage(image!, animated: animated, completion: completion)
        }.resume()
    }
    
    func displayImage(_ image: UIImage, animated: Bool, completion: Optional<() -> ()> = nil){
        DispatchQueue.main.async() { () -> Void in
            for subview in self.subviews{
                if subview is UIActivityIndicatorView {
                    subview.removeFromSuperview()
                }
            }
            if self.image == nil {
                if let ack = completion { ack() }
                if animated {
                    self.alpha = 0
                    self.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alpha = 1
                    })
                }else{
                    self.image = image
                }
            }else{
                self.image = image
                if let ack = completion { ack() }
            }
        }
    }
    
    func load(barcode: String){
        let data = barcode.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.applying(transform) {
                self.image = UIImage(ciImage: output)
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
    
    func day() -> Int {
        let calendar = NSCalendar.current
        let day = calendar.component(.day, from: self as Date)
        return day
    }
    
    func monthName() -> String {
        let calendar = NSCalendar.current
        let month = calendar.component(.month, from: self as Date)
        return DateFormatter().monthSymbols[month - 1]
    }
    
    func isToday() -> Bool {
        let calendar = NSCalendar.current
        let day = calendar.component(.day, from: self as Date)
        let month = calendar.component(.month, from: self as Date)
        let year = calendar.component(.year, from: self as Date)
        
        let today = NSDate()
        let todayDay = calendar.component(.day, from: today as Date)
        let todayMonth = calendar.component(.month, from: today as Date)
        let todayYear = calendar.component(.year, from: today as Date)
        
        return todayDay == day && todayMonth == month && todayYear == year
    }
    
    func isThisWeek() -> Bool {
        return self.timeIntervalSinceNow < 604800
    }
    
    func isThisMonth() -> Bool {
        return self.timeIntervalSinceNow < 2592000
    }
    
    
    static func stringForInterval(start: NSDate, end: NSDate, day: Bool = true) -> String {
        let calendar = NSCalendar.current
        
        let days = [ "Samedi", "Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi" ]
        
        let startWeekDay = days[calendar.component(.weekday, from: start as Date) % 7]
        let startDay = calendar.component(.day, from: start as Date)
        let startMonth = calendar.component(.month, from: start as Date)
        let startYear = calendar.component(.year, from: start as Date)
        let startHour = calendar.component(.hour, from: start as Date)
        let startMinute = String(format: "%02d", calendar.component(.minute, from: start as Date))
        
        let endWeekDay = days[calendar.component(.weekday, from: end as Date) % 7]
        let endDay = calendar.component(.day, from: end as Date)
        let endMonth = calendar.component(.month, from: end as Date)
        let endYear = calendar.component(.year, from: end as Date)
        let endHour = calendar.component(.hour, from: end as Date)
        let endMinute = String(format: "%02d", calendar.component(.minute, from: end as Date))
        
        var startYearStr = "\(startYear)"
        var endYearStr = "\(endYear)"
        startYearStr = startYearStr[startYearStr.index(startYearStr.startIndex, offsetBy: 2)..<startYearStr.endIndex]
        endYearStr = endYearStr[endYearStr.index(endYearStr.startIndex, offsetBy: 2)..<endYearStr.endIndex]
        startYearStr = (startYear != endYear ? "/\(startYearStr)" : "")
        endYearStr = (startYear != endYear ? "/\(endYearStr)" : "")
        
        if end.timeIntervalSince(start as Date) < 86400 {
            if day {
                return "\(startWeekDay) \(startDay)/\(startMonth) de \(startHour):\(startMinute) à \(endHour):\(endMinute)"
            }else{
                return "Le \(startDay)/\(startMonth) à \(startHour):\(startMinute)"
            }
        }else{
            if day {
                return "Du \(startWeekDay) \(startDay)/\(startMonth)\(startYearStr) à \(startHour):\(startMinute)\nAu \(endWeekDay) \(endDay)/\(endMonth)\(endYearStr) à \(endHour):\(endMinute)"
            }else{
                return "Du \(startDay)/\(startMonth)\(startYearStr) au \(endDay)/\(endMonth)\(endYearStr)"
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
    
    mutating func condenseNewLine(){
        let parts = self.components(separatedBy: "\n").filter { (str) -> Bool in return !str.isEmpty }
        self = parts.joined(separator: "\n\n")
    }
    
    func searchLast(string: String, from: Int) -> Int{
        if let range = self.range(of: string, options: CompareOptions.backwards){
            return distance(from: self.startIndex, to: range.upperBound)
        }
        return 0
    }
}

extension UITextView {
        
    func scrollToBotom() {
        let range = NSMakeRange(text.characters.count - 1, 1);
        scrollRangeToVisible(range);
    }
    
    static func heightForContent(_ content: String, andWidth width: CGFloat) -> CGFloat {
        let fixedWidth = width
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let contentSize = textView.sizeThatFits(textView.bounds.size)
        return contentSize.height
    }
}

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}

