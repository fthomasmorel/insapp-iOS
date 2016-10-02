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
        self.invalidateIntrinsicContentSize()
    }
    
    func initFrame(keyboardFrame: CGRect){
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.keyboardFrame = keyboardFrame
        self.textView.delegate = self
        self.frame = CGRect(x: 0, y: keyboardFrame.origin.y - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight) + 1, width: keyboardFrame.width, height: kCommentEmptyTextViewHeight + kCommentViewEmptyHeight)
        self.checkTextView()
        self.invalidateIntrinsicContentSize()
    }

    
    override var intrinsicContentSize: CGSize {
        let textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        self.textView.isScrollEnabled = textSize.height > 4*CGFloat(kCommentViewEmptyHeight)
        self.textView.frame.size.height = min(textSize.height, 4*CGFloat(kCommentViewEmptyHeight))
        let height = self.textView.isScrollEnabled ? 5*CGFloat(kCommentViewEmptyHeight) : textSize.height + CGFloat(kCommentViewEmptyHeight)
        self.textView.scrollToBotom()
        return CGSize(width: self.bounds.width, height: height)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == kDarkGreyColor {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Commenter"
            textView.textColor = kDarkGreyColor
        }
    }
    
    func checkTextView(){
        if let text = textView.text {
            self.postButton.isEnabled = text.characters.count > 0
        }else{
            self.postButton.isEnabled = false
        }
    }
    
    func clearText(){
        self.textView.text = "Commenter"
        self.textView.textColor = kDarkGreyColor
        self.checkTextView()
        self.invalidateIntrinsicContentSize()
    }
    
    @IBAction func postAction(_ sender: AnyObject) {
        delegate?.postComment(self.textView.text)
        self.textView.text = ""
    }
    
}
