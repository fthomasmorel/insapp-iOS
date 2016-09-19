//
//  CommentView.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol CommentViewDelegate {
    func postComment(_ content: String)
    func updateFrame(_ frame: CGRect)
}

class CommentView: UIView, UITextViewDelegate {
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var delegate:CommentViewDelegate?
    var keyboardFrame: CGRect!
    
    class func instanceFromNib() -> CommentView {
        return UINib(nibName: "CommentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CommentView
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.checkTextView()
        self.computeNewSize()
    }
    
    
    func initFrame(keyboardFrame: CGRect){
        self.keyboardFrame = keyboardFrame
        self.textView.delegate = self
        self.frame = CGRect(x: 0, y: keyboardFrame.origin.y - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight), width: keyboardFrame.width, height: kCommentEmptyTextViewHeight + kCommentViewEmptyHeight)
        self.checkTextView()
        self.computeNewSize()
    }
    
    func computeNewSize(){
        let textFieldHeight = ( self.textView.text.characters.count > 0 ? self.textView.contentSize.height : kCommentEmptyTextViewHeight )
        let height = textFieldHeight + CGFloat(kCommentViewEmptyHeight)
        
        var frame = self.textView.frame
        frame.size = CGSize(width: self.frame.width, height: height)
        frame.origin = CGPoint(x: 0, y: keyboardFrame.origin.y - height)

        var newFrame = self.textView.frame
        newFrame.size.height = height
        self.textView.frame = newFrame
        
        delegate?.updateFrame(frame)
    }
    
    func checkTextView(){
        if let text = textView.text {
            self.postButton.isEnabled = text.characters.count > 0
        }else{
            self.postButton.isEnabled = false
        }
    }
    
    func clearText(){
        self.textView.text = ""
        self.checkTextView()
    }
    
    @IBAction func postAction(_ sender: AnyObject) {
        delegate?.postComment(self.textView.text)
    }
    
}
