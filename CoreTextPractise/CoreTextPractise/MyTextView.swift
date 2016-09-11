//
//  MyTextView.swift
//  CoreTextPractise
//
//  Created by cjfire on 16/9/9.
//  Copyright © 2016年 Vread. All rights reserved.
//

import UIKit

let TextBindingAttributeName = "TextBindingAttributeName"

class MyTextView: UITextView {

    
    private var delConform = false
    private var preSelecteRanget = NSRange()
    
    private var regex: NSRegularExpression!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // setup regex
        let pattern = "[-_a-zA-Z@\\.]+[ ,\\n]"
        do {
            try regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {}
    }
    
    override func insertText(text: String) {
        
        let startPosition = positionFromPosition(beginningOfDocument, offset: selectedRange.location)
        let endPostion = positionFromPosition(beginningOfDocument, offset: selectedRange.location + selectedRange.length)
        
        let textRange = textRangeFromPosition(startPosition!, toPosition: endPostion!)
        
        replaceRange(textRange!, withText: text)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyTextView.textDidChanged(_:)), name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyTextView.textDidChanged(_:)), name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func textDidChanged(notification: NSNotification) {
        
        delConform = false
        
        let strAllRange = NSRange.init(location: 0, length: self.attributedText.string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        let attrStr = NSMutableAttributedString(attributedString: self.attributedText)
        attrStr.removeAttribute(NSForegroundColorAttributeName, range: strAllRange)
        attrStr.removeAttribute(TextBindingAttributeName, range: strAllRange)
        attrStr.removeAttribute(NSBackgroundColorAttributeName, range: strAllRange)
        
        regex.enumerateMatchesInString(self.attributedText.string, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSRange.init(location: 0, length: self.attributedText.string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))) { (result, flags, stop) in
            
            guard let result = result else {
                return
            }
            
            let range = result.range
            if range.location == NSNotFound || range.length < 1 {
                return
            }
            
            attrStr.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: range)
            attrStr.addAttributes([TextBindingAttributeName: TextBinding.init(delConfirm: true)], range: range)
        }
        
        self.attributedText = attrStr
    }
    
    override func deleteBackward() {
        
        if !hasText() {
            return
        }
        
        var effectiveRange = NSRange.init()//: NSRangePointer = nil
        let binding = self.attributedText.attribute(TextBindingAttributeName, atIndex: selectedRange.location - 1, longestEffectiveRange: &effectiveRange, inRange: NSRange.init(location: 0, length: self.attributedText.string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        
        if binding == nil {
            super.deleteBackward()
        } else {
            let attrbuteString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            preSelecteRanget = selectedRange
            
            if !self.delConform {
                self.delConform = true
                
                attrbuteString.addAttributes([NSBackgroundColorAttributeName: UIColor.yellowColor()], range: effectiveRange)
                
            } else {
                
                self.delConform = false
                attrbuteString.removeAttribute(NSBackgroundColorAttributeName, range: effectiveRange)
                attrbuteString.replaceCharactersInRange(effectiveRange, withString: "")
                
                
                preSelecteRanget = effectiveRange
                preSelecteRanget.length = 0
            }
            
            self.attributedText = attrbuteString
            self.selectedRange = preSelecteRanget
        }
    }
}

class TextBinding: NSObject {
    
    var delConfirm: Bool
    
    init(delConfirm: Bool) {
        self.delConfirm = delConfirm
        super.init()
    }
}