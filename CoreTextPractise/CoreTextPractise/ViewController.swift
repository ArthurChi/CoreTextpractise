//
//  ViewController.swift
//  CoreTextPractise
//
//  Created by Chi jie on 16/7/7.
//  Copyright © 2016年 Vread. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var showLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attrbuteStr = NSMutableAttributedString(string: "这是一个测试文字, 来个图片, 还有点击事件, 多复制一些, 看看折行效果, cpoy1: 这是一个测试文字, 来个图片, 还有点击事件, cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件, 这是一个测试文字, 来个图片, 还有点击事件, 多复制一些, 看看折行效果, cpoy1: 这是一个测试文字, 来个图片, 还有点击事件, cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件, 这是一个测试文字, 来个图片, 还有点击事件, 多复制一些, 看看折行效果, cpoy1: 这是一个测试文字, 来个图片, 还有点击事件, cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件, 这是一个测试文字, 来个图片, 还有点击事件, 多复制一些, 看看折行效果")
        
        attrbuteStr.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: attrbuteStr.length))
        
        showLabel.attributedText = attrbuteStr
    }
}

