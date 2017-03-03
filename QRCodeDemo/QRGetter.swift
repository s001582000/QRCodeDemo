//
//  QRGetter.swift
//  QRCode
//
//  Created by 梁雅軒 on 2015/7/28.
//  Copyright (c) 2015年 梁雅軒. All rights reserved.
//

import UIKit
import AVFoundation

enum CodeType : Int {
    case UPCECode = 0,
    Code39Code,
    EAN13Code,
    Code39Mod43Code,
    EAN8Code,
    Code93Code,
    Code128Code,
    PDF417Code,
    ITF14Code,
    QRCode,
    UnKnow
}

class QRGetter: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private typealias closeBlock = (_ message:String,_ type:CodeType) -> Void
    private var mBlock:closeBlock?
    private var mCaptureSession:AVCaptureSession!
    private var mPreviewLayer:AVCaptureVideoPreviewLayer!
    private var mQRCodeFrameView:UIView!
    private var mScopeView:UIView!
    private var bScopeView = false
    
    private let METADATATYPE = [
        AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeQRCode,
        AVMetadataObjectTypeAztecCode]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSelf()
    }
    
    deinit{
        mCaptureSession = nil
        mPreviewLayer = nil
        mQRCodeFrameView = nil
        mScopeView = nil
        
    }
    
    override func layoutSubviews() {
        mPreviewLayer.frame = self.layer.bounds
    }
    
    
    private func initSelf(){
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mCaptureSession = AVCaptureSession()
        mCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let myDevices = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do{
            let myDeviceInput = try AVCaptureDeviceInput(device: myDevices)
            mCaptureSession.addInput(myDeviceInput)
        }catch{
            
        }
        
        
        let myVideoDataOutput:AVCaptureMetadataOutput! = AVCaptureMetadataOutput()
        
        
        myVideoDataOutput.setMetadataObjectsDelegate(self, queue:
            DispatchQueue.main)
        mCaptureSession.addOutput(myVideoDataOutput)
        myVideoDataOutput.metadataObjectTypes = METADATATYPE
        
        
        mPreviewLayer = AVCaptureVideoPreviewLayer(session: mCaptureSession)
        
        mPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        mPreviewLayer.frame = self.layer.bounds
        
        self.layer.insertSublayer(mPreviewLayer, at: 0)
        
        mQRCodeFrameView = UIView()
        mQRCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        mQRCodeFrameView?.layer.borderWidth = 2
        self.addSubview(mQRCodeFrameView!)
        self.bringSubview(toFront: mQRCodeFrameView!)
        
        
        
    }
    
    private func getCodeType(type:String)->CodeType{
        var codeType:CodeType!
        switch type{
        case AVMetadataObjectTypeUPCECode:
            codeType = CodeType.UPCECode
            break
        case AVMetadataObjectTypeQRCode:
            codeType = CodeType.QRCode
            break
        case AVMetadataObjectTypePDF417Code:
            codeType = CodeType.PDF417Code
            break
        case AVMetadataObjectTypeITF14Code:
            codeType = CodeType.ITF14Code
            break
        case AVMetadataObjectTypeCode128Code:
            codeType = CodeType.Code128Code
            break
        case AVMetadataObjectTypeCode39Code:
            codeType = CodeType.Code39Code
            break
        case AVMetadataObjectTypeCode39Mod43Code:
            codeType = CodeType.Code39Mod43Code
            break
        case AVMetadataObjectTypeCode93Code:
            codeType = CodeType.Code93Code
            break
        case AVMetadataObjectTypeEAN13Code:
            codeType = CodeType.EAN13Code
            break
        case AVMetadataObjectTypeEAN8Code:
            codeType = CodeType.EAN8Code
            break
        default:
            codeType = CodeType.UnKnow
            break
        }
        return codeType
    }
    
    func start(completion:@escaping (String,CodeType)->Void){
        if !mCaptureSession.isRunning{
            mCaptureSession.startRunning()
            mBlock = completion
            if bScopeView{
                self.addSubview(mScopeView!)
                self.bringSubview(toFront: mScopeView!)
                
            }
        }
    }
    
    func stop(){
        if mCaptureSession.isRunning{
            mCaptureSession.stopRunning()
        }
    }
    
    func setScopeFrame(size:CGSize){
        if size.equalTo(CGSize.zero){
            bScopeView = false
        }else{
            bScopeView = true
            if mScopeView == nil{
                mScopeView = UIView()
                mScopeView.frame = CGRect(origin: CGPoint.zero, size: size)
                mScopeView.center = self.center
                mScopeView?.layer.borderColor = UIColor.orange.cgColor
                mScopeView?.layer.borderWidth = 1
                if mCaptureSession.isRunning{
                    self.addSubview(mScopeView!)
                    self.bringSubview(toFront: mScopeView!)
                }
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            mQRCodeFrameView.frame = CGRect.zero
            
            mBlock?("not has message",getCodeType(type: ""))
            return
        }
        
        var barCodeObject:AVMetadataMachineReadableCodeObject!
        let barCodeTypes = METADATATYPE
        for metadata in metadataObjects{
            for type in barCodeTypes{
                if (metadata as AnyObject).type == type{
                    barCodeObject = mPreviewLayer?.transformedMetadataObject(for: metadata as!
                        AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                    let str = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    
                    if bScopeView{
                        if mScopeView.frame.contains(barCodeObject.bounds){
                            
                            mBlock?(str!,getCodeType(type: type))
                            mQRCodeFrameView.frame = barCodeObject.bounds
                        }
                    }else{
                        mBlock?(str!,getCodeType(type: type))
                        mQRCodeFrameView.frame = barCodeObject.bounds
                    }
                }
            }
        }
    }
    
    
    static func qrImageForString(str:String)-> UIImage{
        
        let stringData = str.data(using: String.Encoding.utf8)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        let outputImage:CIImage = qrFilter!.outputImage!
        let image = UIImage(ciImage: outputImage, scale: 1, orientation: UIImageOrientation.up)
        return image
    }
}
