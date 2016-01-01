//
//  ViewController.swift
//  auto_timecart
//
//  Created by 小林芳樹 on 2015/12/27.
//  Copyright © 2015年 小林芳樹. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftyJSON

extension UIColor {
    class func hex (var hexStr : NSString, var alpha : CGFloat) -> UIColor {
        hexStr = hexStr.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.whiteColor();
        }
    }
}

extension UIView{
    func bottomY() -> CGFloat{
        return self.frame.origin.y + self.frame.size.height
    }
    
    func rightX() ->CGFloat{
        return self.frame.origin.x + self.frame.size.width
    }
    
    func setOrigin(point:CGPoint){
        self.frame = CGRectMake(point.x, point.y, self.frame.width, self.frame.height)
    }
}


class ViewController: UIViewController, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    private let qiitaUrl = "https://www.fc-hikaku.net/hoge"
    
    private let lblTitle = UILabel()
    private let lblAttendance = UILabel()
    private let lblClockout = UILabel()
    private let lblAttendanceTime = UILabel()
    private let lblClockoutTime = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        DBLDownloadFont.setFontNameWithBlock({ (success:Bool, error:String!) -> Void in
            self.lblAttendance.text = "loaded !"
            }, fontName: "HiraMaruProN-W4")
        */
        
        
        let baseY: CGFloat = 200.0
        
        lblTitle.frame = CGRectMake(0, 15, self.view.bounds.width, 100)
        lblTitle.text = "タイムくん"
        lblTitle.textColor = UIColor.whiteColor()
        lblTitle.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblAttendance.frame = CGRectMake(0, 0, 200, 100)
        lblAttendance.center = CGPointMake(self.view.bounds.width/2-30, baseY)
        lblAttendance.text = "出勤時間"
        lblAttendance.textColor = UIColor.whiteColor()
        lblAttendance.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblAttendanceTime.frame = CGRectMake(0, 0, 200, 100)
        lblAttendanceTime.center = CGPointMake(self.view.bounds.width/2 + 100, baseY)
        lblAttendanceTime.text = "AM 09:30"
        lblAttendanceTime.textColor = UIColor.whiteColor()
        lblAttendanceTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblClockout.frame = CGRectMake(0, 0, 200, 100)
        lblClockout.center = CGPointMake(self.view.bounds.width/2-30, baseY+150)
        lblClockout.text = "退勤時間"
        lblClockout.textColor = UIColor.whiteColor()
        lblClockout.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblClockoutTime.frame = CGRectMake(0, 0, 200, 100)
        lblClockoutTime.center = CGPointMake(self.view.bounds.width/2+100, baseY + 150)
        lblClockoutTime.text = "PM 07:30"
        lblClockoutTime.textColor = UIColor.whiteColor()
        lblClockoutTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        
        self.view.backgroundColor = UIColor.hex("26a4df", alpha: 0.8)
        
        self.view.addSubview(lblTitle)
        self.view.addSubview(lblAttendance)
        self.view.addSubview(lblAttendanceTime)
        self.view.addSubview(lblClockout)
        self.view.addSubview(lblClockoutTime)
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        //CentralManagerの状態変化を取得
        print("state: \(central.state)")
        
        switch (central.state) {
        case CBCentralManagerState.PoweredOn:
            self.centralManager = central
            //self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        default:
            break
            
        }
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        //周辺デバイスが見つかると呼ばれる
        print("発見したBLEデバイス： \(peripheral)")
        
        //見つかったデバイスがkonashiかどうか
        if(peripheral.name!.hasPrefix("konashi")) {
            self.peripheral = peripheral
            //self.centralManager.connectPeripheral(peripheral, options: nil)

        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("接続成功")
        
        
        //API実行して登録
        self.callApi(self.qiitaUrl)
        
        //もろもろ終わったら切断
        
        
        //スキャンはし続けてkonashiが存在するかは確認
        //konashiが見つからなくなったら、退勤扱いにする。
        
        //スキャンを停止
        //self.centralManager.stopScan()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        //接続が切れた時に呼ばれる
        print("接続が切れました")
        print(error)
    }
    
    private func callApi(url: String) -> Bool {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            if (error == nil && (response as! NSHTTPURLResponse).statusCode == 200) {
                let json = SwiftyJSON.JSON(data: data!)
                for(_, obj) in json {
                    if(obj != nil) {
                        print(obj["title"])
                    }
                    
                }
                
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 5)
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.alertBody = "更新成功"
                notification.alertAction = "OK"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
            }else{
                
                print("エラー")
                
                let alertController: UIAlertController = UIAlertController()
                alertController.title = "エラー"
                alertController.message = "QiitaAPIの実行でエラーが発生しました。"
                //alertController.preferredStyle = .Aler
                self.presentViewController(alertController, animated: true) { () -> Void in
                    //3秒後に閉じる
                    let delay = 2.0 * Double(NSEC_PER_SEC)
                    let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(time, dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                print(error)
            }
        })
        task.resume()
        return true
    }
    
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

