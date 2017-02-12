//
//  EventPageCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/6/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol EventTabDelegate {
    func indexDidChange(index: Int)
}

class EventTabView: UIView {
    
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var commentButton: UIButton!
    
    var delegate: EventTabDelegate?
    var index = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.commentButton.frame.size.width = self.frame.width/2
        self.commentButton.frame.origin.x = self.frame.width/2
        self.commentButton.frame.origin.y = 20
        self.aboutButton.frame.size.width = self.frame.width/2
        self.aboutButton.frame.origin.x = 0
        self.aboutButton.frame.origin.y = 20
        self.underlineView.frame.size.width = self.frame.width/2
        self.underlineView.frame.size.height = 2
        self.underlineView.frame.origin.x = 0
        self.underlineView.frame.origin.y = 68
        
        self.statusBarView.frame.size.height = 20
        self.statusBarView.frame.origin.x = 0
        self.statusBarView.frame.origin.y = 0
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 1
        
        updateIndex(index: self.index)
    }
    
    func updateIndex(index: Int){
        self.index = index
        self.underlineView.frame.origin.x = CGFloat(index)*self.frame.width/2
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.underlineView.frame.origin.x = 0
            }, completion: { (finished) in
            self.delegate?.indexDidChange(index: 0)
        })

    }
    
    @IBAction func commentAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.underlineView.frame.origin.x = self.frame.width/2
        }, completion: { (finished) in
            self.delegate?.indexDidChange(index: 1)
        })
    }
    
}
