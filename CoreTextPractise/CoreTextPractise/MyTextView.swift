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

    
    fileprivate var delConform = false
    fileprivate var preSelecteRanget = NSRange()
    
    fileprivate var regex: NSRegularExpression!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // setup regex
        let pattern = "[-_a-zA-Z@\\.]+[ ,\\n]"
        do {
            try regex = NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {}
    }
    
    override func insertText(_ text: String) {
        
        let startPosition = position(from: beginningOfDocument, offset: selectedRange.location)
        let endPostion = position(from: beginningOfDocument, offset: selectedRange.location + selectedRange.length)
        
        let textRange = self.textRange(from: startPosition!, to: endPostion!)
        
        replace(textRange!, withText: text)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyTextView.textDidChanged(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyTextView.textDidChanged(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func textDidChanged(_ notification: Notification) {
        
        delConform = false
        
        let strAllRange = NSRange.init(location: 0, length: self.attributedText.string.lengthOfBytes(using: String.Encoding.utf8))
        
        let attrStr = NSMutableAttributedString(attributedString: self.attributedText)
        attrStr.removeAttribute(NSForegroundColorAttributeName, range: strAllRange)
        attrStr.removeAttribute(TextBindingAttributeName, range: strAllRange)
        attrStr.removeAttribute(NSBackgroundColorAttributeName, range: strAllRange)
        
        regex.enumerateMatches(in: self.attributedText.string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSRange.init(location: 0, length: self.attributedText.string.lengthOfBytes(using: String.Encoding.utf8))) { (result, flags, stop) in
            
            guard let result = result else {
                return
            }
            
            let range = result.range
            if range.location == NSNotFound || range.length < 1 {
                return
            }
            
            attrStr.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: range)
            attrStr.addAttributes([TextBindingAttributeName: TextBinding.init(delConfirm: true)], range: range)
        }
        
        self.attributedText = attrStr
    }
    
    override func deleteBackward() {
        
        if !hasText {
            return
        }
        
        var effectiveRange = NSRange.init()//: NSRangePointer = nil
        let binding = self.attributedText.attribute(TextBindingAttributeName, at: selectedRange.location - 1, longestEffectiveRange: &effectiveRange, in: NSRange.init(location: 0, length: self.attributedText.string.lengthOfBytes(using: String.Encoding.utf8)))
        
        if binding == nil {
            super.deleteBackward()
        } else {
            let attrbuteString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            preSelecteRanget = selectedRange
            
            if !self.delConform {
                self.delConform = true
                
                attrbuteString.addAttributes([NSBackgroundColorAttributeName: UIColor.yellow], range: effectiveRange)
                
            } else {
                
                self.delConform = false
                attrbuteString.removeAttribute(NSBackgroundColorAttributeName, range: effectiveRange)
                attrbuteString.replaceCharacters(in: effectiveRange, with: "")
                
                
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
