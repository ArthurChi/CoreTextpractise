//
//  MyLabel.swift
//  CoreTextPractise
//
//  Created by Chi jie on 16/7/7.
//  Copyright © 2016年 Vread. All rights reserved.
//

import UIKit

class MyLabel: UILabel {
    
    var frameAttr: CTFrame!
    var imgName = "badge_new"
    let kClickeableAttributeString = "ClickeableAttributeString"
    lazy var content = NSMutableAttributedString()
    
    override func drawRect(rect: CGRect) {
        
        if let contentAttr = attributedText {
            content.appendAttributedString(contentAttr)
        }
        
        build()
        
        let context = UIGraphicsGetCurrentContext()
        
        // 可以理解为 - 要旋转画布了
        CGContextSaveGState(context)
        
        // 旋转画布
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, rect.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        /*
         * 1. 通过AttributeString->CTFramesetter
         * 2. 创建路径, 你可以做点形变, 可以修改渲染的路径
         * 3. 通过以上两个对象, 创建CTFrame
         * 4. 将CTFrame对象渲染上去
         */
        
        let frameSetter = CTFramesetterCreateWithAttributedString(content as CFAttributedString)
        
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        
        frameAttr = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: content.length), path, nil)
        
        CTFrameDraw(frameAttr, context!)
        // 属性文字渲染完毕
        
        // 这里要理解一个模型, CTFrame包含CTLine, CTLine包含CTRun
        
        /*
         * 1. 从CTFrame中获取所有的CTLine
         * 2. 建立一个CGPoint的数组, 用来存放没个CTLine的原点
         * 3. 遍历所有的CTLine
         * 4. 遍历当前CTLine中的CTRun
         * 5. 从CTRun中获取属性字典中的值(这里需要知道CTRun是什么)
         * 6. 找到后, 用Core Graphics画上去
         */
        
        let lines = CTFrameGetLines(frameAttr) as Array
        var lineOrigins = [CGPoint](count:lines.count, repeatedValue: CGPointZero)
        CTFrameGetLineOrigins(frameAttr, CFRange(location: 0, length: 0), &lineOrigins)
        
        for i in 0..<lines.count {
            
            var
            lineAscent = CGFloat(),
            lineDescent = CGFloat(),
            lineLeading = CGFloat()
            
            let line = lines[i] as! CTLine
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading)
            
            let runs = CTLineGetGlyphRuns(line) as Array
            
            for j in 0..<runs.count {
                
                var
                runAscent = CGFloat(),
                runDescent = CGFloat()
                
                let run = runs[j] as! CTRun
                
                var runRect = CGRectZero
                runRect.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, nil))
                
                // 获取当前CTRun的Range, 用来控制画图所用的X
                let strRangeLocation = CTRunGetStringRange(run).location
                // 获取当前CTLine的原点, 用来控制画图所用的Y
                let lineOrigin = lineOrigins[i]
                // 算出绘图所需的Rect
                runRect = CGRect(x: lineOrigin.x + CTLineGetOffsetForStringIndex(line, strRangeLocation, nil), y: lineOrigin.y - runDescent, width: runRect.size.width, height: runAscent - runDescent)
                
                // 这里是要取出刚才你起的attribute的名字
                let attributes = CTRunGetAttributes(run)
                let imageName = (attributes as Dictionary)[imgName]
                
                // 生成Image并渲染
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
        
        // 把刚旋转的画布转回来
        CGContextRestoreGState(context)
    }
    
    private func build() {
        
        // 声明代理回调, 决定描述图片的大小
        var imageCallback = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (pointer) in
            
            }, getAscent: { (pointer) -> CGFloat in
                return 30
            }, getDescent: { (pointer) -> CGFloat in
                return 0
            }) { (pointer) -> CGFloat in
                return 30
        }
        
        // 创建CTRun回调
        let runDelegate = CTRunDelegateCreate(&imageCallback, nil)
        
        // 为要画的图片留一个占位符
        let imageAttributedString = NSMutableAttributedString(string: " ")
        // 有这行, 才会在绘制的时候, 调用代理, 留下代理中的rect
        imageAttributedString.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSRange(location: 0,length: 1))
        // 存下你的图片名或URL
        imageAttributedString.addAttribute(imgName, value: imgName, range: NSRange(location: 0, length: 1))
        
        content.appendAttributedString(imageAttributedString)
        
        let lastedAttributedString = NSMutableAttributedString(string: "123cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件")
        content.appendAttributedString(lastedAttributedString)
        
        let clickeableString = NSMutableAttributedString(string: "这段文字可点击")
        clickeableString.addAttributes([NSForegroundColorAttributeName: UIColor.greenColor()], range: NSRange(location: 0, length: clickeableString.length))
        
        let action = Action { 
            print(NSDate() ,"WTF")
        }
        
        clickeableString.addAttribute(kClickeableAttributeString, value: action, range: NSRange(location: 0, length: clickeableString.length))
        content.appendAttributedString(clickeableString)
        
        // TODO: - 换行模式, 段落模式
    }
    
    // 主要思想就是通过你点击的手指的point和你要找的string的范围做比较
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        var location = touch?.locationInView(self) ?? CGPointZero
        
        let lines = CTFrameGetLines(frameAttr) as Array
        var origins = [CGPoint](count:lines.count, repeatedValue: CGPointZero)
        CTFrameGetLineOrigins(frameAttr, CFRangeMake(0, 0), &origins)
        
        var line: CTLine?
        var lineOrigin = CGPointZero
        
        for i in 0..<lines.count {
            
            let origin = origins[i]
            let path = CTFrameGetPath(frameAttr)
            let rect = CGPathGetBoundingBox(path)
            let y = rect.origin.y + rect.size.height - origin.y
            
            if location.y <= y && location.x >= origin.x {
                line = (lines[i] as! CTLine)
                lineOrigin = origin
                break
            }
        }
        
        location.x -= lineOrigin.x
        
        if let line = line {
            
            // 模拟YYText可点击文字
            let runs = CTLineGetGlyphRuns(line) as Array
            
            for j in 0..<runs.count {
                
                let run = runs[j] as! CTRun
                
                // 这里是要取出刚才你起的attribute的名字
                let attributes = CTRunGetAttributes(run)
                if let action = (attributes as Dictionary)[kClickeableAttributeString] as? Action {
                    let index = CTLineGetStringIndexForPosition(line, location)
                    
                    let strLocation = CTRunGetStringRange(run).location
                    let strLength = CTRunGetStringRange(run).length
                    
                    if index >= strLocation && index <= strLocation + strLength {
                        action.callback()
                    }
                }
            }
        }
    }
}

class Action: NSObject {
    
    var callback: () -> Void
    
    init(callback: (()->Void)) {
        self.callback = callback
        super.init()
    }
}
