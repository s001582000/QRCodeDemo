//
//  ViewController.swift
//  QRCodeDemo
//
//  Created by 梁雅軒 on 2017/3/3.
//  Copyright © 2017年 zoaks. All rights reserved.
//

import UIKit

class ViewController: UIViewController,QRGetterDelegate {
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
            qrCodeGetter.delegate = self
            self.view.addSubview(qrCodeGetter)
        }
        
        qrCodeGetter.start()
    }

    func qrGetterOnMessage(message: String, type: CodeType) {
        qrCodeGetter.stop()
        qrCodeGetter.removeFromSuperview()
        qrCodeGetter = nil
        print("message=\(message),type=\(type.hashValue)")
    }

}
