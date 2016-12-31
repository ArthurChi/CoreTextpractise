//
//  ViewController.swift
//  CoreTextPractise
//
//  Created by Chi jie on 16/7/7.
//  Copyright © 2016年 Vread. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var fpsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var lastTime: CFTimeInterval = 0
    var count: Double = 0
    
    lazy var link: CADisplayLink = {
        
        let link = CADisplayLink(target: self, selector: #selector(ViewController.fpsCalculater(link:)))
        
        return link
    }()
    
    var attrbuteStr: NSAttributedString = {
        
        let attrbuteStr = NSMutableAttributedString(string: "这是一个测试文字, 来个图片, 还有点击事件, 多复制一些, 看看折行效果, cpoy1: 这是一个测试文字, 来个图片, 还有点击事件, cpoy2: 这是一个测试文字, 来个图片, 还有点击事件, cpoy3: 这是一个测试文字, 来个图片, 还有点击事件, 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫")
        
        attrbuteStr.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: attrbuteStr.length))
        
        return attrbuteStr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        link.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        tableView.dataSource = self
//        showLabel.attributedText = attrbuteStr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 500
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(tableView.classForCoder)") {
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "\(tableView.classForCoder)")

            let showLabel = MyLabel()
            showLabel.attributedText = attrbuteStr
            cell.contentView.addSubview(showLabel)
            showLabel.frame = cell.contentView.bounds
            
            return cell
        }
    }
    
    @objc private func fpsCalculater(link: CADisplayLink) {
        let delta = link.timestamp - lastTime
        
        count += 1
        if delta < 1 {
            return
        }
        
        lastTime = link.timestamp
        fpsLabel.text = "\(count / delta)"
        count = 0
    }
}

