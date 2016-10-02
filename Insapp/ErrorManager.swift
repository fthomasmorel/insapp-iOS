//
//  ErrorManager.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController{
    
    func triggerError(_ message: String, _ statusCode: Int) -> Bool {
        if statusCode == 406 {
            self.stopLoading()
            self.displayError(message: kErrorUserExist)
            if self.responds(to: Selector("askForChangePhone")) {
                self.perform(Selector("askForChangePhone"))
            }
        }
        else if statusCode != 200 && statusCode != 401 {
            self.stopLoading()
            self.displayError(message: message)
        }
        return shouldRetry(statusCode)
    }
    
    func displayError(message: String){
        let frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 80)
        let view = UIView(frame: frame)
        view.backgroundColor = kDarkGreyColor
        
        let label = UILabel(frame: view.bounds)
        label.text = message
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: kNormalFont, size: 15)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        
        view.addSubview(label)
        
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.25, animations: {
            view.frame.origin.y = 0
        }) { (completed) in
            UIView.animate(withDuration: 0.25, delay: 5, options: .allowAnimatedContent, animations: {
                view.frame.origin.y = -view.frame.height
                }, completion: { (completed) in
                    view.isHidden = true
            })
        }
    }
    
    private func shouldRetry(_ code: Int) -> Bool{
        switch code {
        case 200:
            return false
        case 401:
            return false
        default:
            return false
        }
    }
}
