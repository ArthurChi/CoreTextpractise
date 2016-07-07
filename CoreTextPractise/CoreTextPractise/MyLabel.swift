//
//  MyLabel.swift
//  CoreTextPractise
//
//  Created by Chi jie on 16/7/7.
//  Copyright © 2016年 Vread. All rights reserved.
//

import UIKit

class MyLabel: UILabel {

    lazy var content = NSMutableAttributedString(string: "这是一个测试文字, 来个图片, 还有点击事件, 多复制一些, 看看折行效果, cpoy1: 这是一个测试文字, 来个图片, 还有点击事件, cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件")
    var frameAttr: CTFrame!
    
    override func drawRect(rect: CGRect) {
        
        buildAttributeStirng()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, rect.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        let frameSetter = CTFramesetterCreateWithAttributedString(content as CFAttributedStringRef)
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        
        frameAttr = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: content.length), path, nil)
        CTFrameDraw(frameAttr, context!)
        
        let lines = CTFrameGetLines(frameAttr) as Array
        let lineOrigins = UnsafeMutablePointer<CGPoint>([CFArrayGetCount(lines)])  //Array<CGPoint>()//[CFArrayGetCount(lines)]
//        var lineOrigins1 = Array<CGPoint>.init(count: CFArrayGetCount(lines), repeatedValue: CGPointZero)
        
        CTFrameGetLineOrigins(frameAttr, CFRange(location: 0, length: 0), lineOrigins) // UnsafeMutablePointer<CGPoint>(lineOrigins)
        
        for i in 0..<CFArrayGetCount(lines) {
            
            var lineAscent: CGFloat = 0, lineDescent: CGFloat = 0, lineLeading: CGFloat = 0
            let line = lines[i] as! CTLine
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading)
            
            let runs = CTLineGetGlyphRuns(line) as Array
            
            for j in 0..<runs.count {
                
                var runAscent: CGFloat = 0, runDescent: CGFloat = 0
//                let lineOrigin = lineOrigins[j] as! CGPoint
                
                let lineOrigin = lineOrigins[j]
                
                let run = runs[j] as! CTRun
                
                let attributes = CTRunGetAttributes(run)
                
                var runRect = CGRectZero
                runRect.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, nil))
                
                runRect = CGRect(x: lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil), y: lineOrigin.y - runDescent, width: runRect.size.width, height: runAscent - runDescent)
                
                let imageName = (attributes as Dictionary)["badge_new"]
                
                if let imageName = imageName as? String {
                    if let image = UIImage(named: imageName) {
                        
                        var imageDrawRect = CGRectZero
                        imageDrawRect.size = CGSize(width: 30, height: 30)
                        imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x
                        imageDrawRect.origin.y = lineOrigin.y
                        CGContextDrawImage(context, imageDrawRect, image.CGImage)
                    }
                    
                }
                
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    private func buildAttributeStirng() {
        
        var imgName = "badge_new"
        
        /// 销毁内存
        let runDelegateDeallocCallback: CTRunDelegateDeallocateCallback = { pointer in
            
        }
        
        /// CTRun回调, 获取高度
        let runDelegateGetAscentCallback: CTRunDelegateGetAscentCallback = { pointer in
            return 30
        }
        
        let runDelegateGetDescentCallback: CTRunDelegateGetDescentCallback = { pointer in
            return 0
        }
        
        /// CTRun回调, 获取宽度
        let runDelegateGetWidthCallback: CTRunDelegateGetWidthCallback = { pointer in
            return 30
        }
        
        var imageCallbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: runDelegateDeallocCallback, getAscent: runDelegateGetAscentCallback, getDescent: runDelegateGetDescentCallback, getWidth: runDelegateGetWidthCallback)
        
        /// 创建CTRun回调
        let runDelegate = CTRunDelegateCreate(&imageCallbacks, &imgName)
        
        let imageAttributedString = NSMutableAttributedString(string: " ")
        imageAttributedString.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSRange(location: 0,length: 1))
        
        imageAttributedString.addAttribute(imgName, value: imgName, range: NSRange(location: 0, length: 1))
        content.appendAttributedString(imageAttributedString)
        
        let lastedAttributedString = NSMutableAttributedString(string: "cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件")
        content.appendAttributedString(lastedAttributedString)
        
        // TODO: - 换行模式, 段落模式
        
    }
    
    
}
