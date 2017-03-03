//
//  ViewController.swift
//  QRCodeDemo
//
//  Created by 梁雅軒 on 2017/3/3.
//  Copyright © 2017年 zoaks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var qrCodeGetter:QRGetter!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnOnClick(_ sender: UIButton) {
        if qrCodeGetter == nil{
            qrCodeGetter = QRGetter(frame: self.view.bounds)
            qrCodeGetter.setScopeFrame(size: CGSize(width: 400, height: 400))
            self.view.addSubview(qrCodeGetter)
        }
        
        qrCodeGetter.start { (message, type) in
            self.qrCodeGetter.stop()
            self.qrCodeGetter.removeFromSuperview()
            self.qrCodeGetter = nil
        }
    }

    

}
