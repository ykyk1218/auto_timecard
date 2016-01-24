//
//  ViewController.swift
//  auto_timecart
//
//  Created by 小林芳樹 on 2015/12/27.
//  Copyright © 2015年 小林芳樹. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import CorePlot
import Download_Font_iOS
import QuartzCore

extension UIColor {
    class func hex (var hexStr : NSString, let alpha : CGFloat) -> UIColor {
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


class ViewController: UIViewController, CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    private var locationManager: CLLocationManager!
    private var beaconRegion: CLBeaconRegion!
    
    private var attendanceFlg = false
    private var clockoutFlg   = false
    
    /*
    private var enterRegionFlg = false
    private var exitRegionFlg  = true
    */

    private var preventDoubleCall = false
    
    private let lblDate = UILabel()
    private let lblAttendance = UILabel()
    private let lblClockout = UILabel()
    private let lblAttendanceTime = UILabel()
    private let lblClockoutTime = UILabel()
    private let lblStatus = UILabel()
    
    private let timecardModel = TimecardModel()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lblNavTitle = UILabel()
        lblNavTitle.text = "タイムカードオートメーション"
        lblNavTitle.frame = CGRectMake(0,0, self.view.frame.size.width+100,(self.navigationController?.navigationBar.frame.size.height)!)
        lblNavTitle.textAlignment = NSTextAlignment.Center
        lblNavTitle.textColor = UIColor.whiteColor()
        lblNavTitle.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 16)
        self.navigationItem.titleView = lblNavTitle
        
        let baseY: CGFloat = 100.0
        self.view.backgroundColor = UIColor.hex("00FFFF", alpha: 0.8)
        
        
        /*********************/
        
        lblDate.frame = CGRectMake(0, baseY - 60, self.view.frame.width, 100)
        //lblDate.center = CGPointMake(0, baseY)
        lblDate.text = self.getCunnrentDate("yyyy年 MM月 dd日")
        lblDate.textColor = UIColor.whiteColor()
        lblDate.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 22)
        lblDate.textAlignment = NSTextAlignment.Center
        
        
        lblAttendance.frame = CGRectMake(0, 0, 200, 100)
        lblAttendance.center = CGPointMake(self.view.bounds.width/2-30, baseY+50)
        lblAttendance.text = "出勤時間"
        lblAttendance.textColor = UIColor.whiteColor()
        lblAttendance.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 22)
        
        lblAttendanceTime.frame = CGRectMake(0, 0, 200, 100)
        lblAttendanceTime.center = CGPointMake(self.view.bounds.width/2 + 100, baseY+50)
        lblAttendanceTime.text = "--:--"
        lblAttendanceTime.textColor = UIColor.whiteColor()
        lblAttendanceTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 22)
        
        lblClockout.frame = CGRectMake(0, 0, 200, 100)
        lblClockout.center = CGPointMake(self.view.bounds.width/2-30, baseY+85)
        lblClockout.text = "退勤時間"
        lblClockout.textColor = UIColor.whiteColor()
        lblClockout.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 22)
        
        lblClockoutTime.frame = CGRectMake(0, 0, 200, 100)
        lblClockoutTime.center = CGPointMake(self.view.bounds.width/2+100, baseY+85)
        lblClockoutTime.text = "--:--"
        lblClockoutTime.textColor = UIColor.whiteColor()
        lblClockoutTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 22)
        
        lblStatus.frame = CGRectMake(0, 0, self.view.bounds.width-30, 40)
        lblStatus.center = CGPointMake(self.view.bounds.width/2, self.view.bounds.height-15)
        lblStatus.text = "ビーコン領域内"
        lblStatus.textColor = UIColor.whiteColor()
        lblStatus.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 15)
        lblStatus.textAlignment = NSTextAlignment.Center
        lblStatus.clipsToBounds = true
        lblStatus.layer.cornerRadius = 10.0
        lblStatus.backgroundColor = UIColor.hex("dbe159", alpha: 0.5)
        lblStatus.numberOfLines = 0

        
        
        //グラフViewの表示
        let timecardGraph = TimecardGraphView()
        timecardGraph.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width-5, 300)
        timecardGraph.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, baseY+180)
        
        self.view.addSubview(lblDate)
        self.view.addSubview(lblAttendance)
        self.view.addSubview(lblAttendanceTime)
        self.view.addSubview(lblClockout)
        self.view.addSubview(lblClockoutTime)
        self.view.addSubview(timecardGraph)
        self.view.addSubview(lblStatus)
        
        let now = getCunnrentDate("yyyy-MM-dd")
        //出勤・退勤の時間を取得
        if(defaults.objectForKey(now + ":attendanceTime") != nil) {
            self.lblAttendanceTime.text = defaults.objectForKey(now + ":attendanceTime") as? String
        }
        if(defaults.objectForKey("clockoutTime") != nil) {
            self.lblClockoutTime.text = defaults.objectForKey(now + ":clockoutTime")as? String
        }

        //位置情報の取得
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    //ビーコンの領域にはいった時に呼ばれるデリゲートメソッド
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
        if(self.preventDoubleCall) {
            //デリゲートメソッドの2重呼び出し防止
            print("2重呼び出し防止")
            return
        }
        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
        self.preventDoubleCall = true
        
        let now = self.getCunnrentDate("yyyy-MM-dd")
        if(self.defaults.objectForKey(now + ":attendanceTime") == nil) {
        
            let params = ["email": defaults.objectForKey("email")!, "in_region":"true"]
            self.timecardModel.attendance(params) {(clockoutProcessed)->() in
                
                //出勤処理をした場合
                if(clockoutProcessed) {
                    let attendanceTime = self.getCunnrentTime()
                    self.lblAttendanceTime.text = attendanceTime
                    
                    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
                    let comp = NSDateComponents()
                    comp.day = -1
                    let d:NSDate = calendar!.dateByAddingComponents(comp, toDate: NSDate(), options: NSCalendarOptions())!
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let y = dateFormatter.stringFromDate(d)
                    self.defaults.removeObjectForKey(y+":attendanceTime")
                    
                    self.defaults.setObject(attendanceTime, forKey: now + ":attendanceTime")
                    
                }
                self.attendanceFlg = true
                self.preventDoubleCall = false
                
                //ログ登録用
                self.timecardModel.record(params)
            }
        }
    
        self.lblStatus.text = "ビーコン領域内"
    }
    
    //ビーコン領域から外に出た後に呼ばれるデリゲートメソッド
    //領域外にでてから30秒後ぐらいに実行される
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
        if(self.preventDoubleCall) {
            //デリゲートメソッドの2重呼び出し防止
            return
        }
        //self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
        self.preventDoubleCall = true
        
        //出勤チェックをしてから退勤処理を実行する
        let params = ["email": defaults.objectForKey("email")!, "in_region":"false"]
        
        let now = self.getCunnrentDate("yyyy-MM-dd")
        if(self.defaults.objectForKey(now + ":clockoutTime") == nil) {
            self.timecardModel.clockout(params) { (clockoutProcessed)->() in
                
                if(clockoutProcessed) {
                    let clockoutTime = self.getCunnrentTime()
                    self.lblClockoutTime.text = clockoutTime
                    
                    
                    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
                    let comp = NSDateComponents()
                    comp.day = -1
                    let d:NSDate = calendar!.dateByAddingComponents(comp, toDate: NSDate(), options: NSCalendarOptions())!
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let y = dateFormatter.stringFromDate(d)
                    self.defaults.removeObjectForKey(y+":clockoutTime")

                    
                    self.defaults.setObject(clockoutTime, forKey: now + ":clockoutTime")
                }
                self.preventDoubleCall = false
                
                
                //ログ登録用
                self.timecardModel.record(params)
            }
        }
        
        self.lblStatus.text = "ビーコン領域外"
    }
    

    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
        switch(state) {
        case CLRegionState.Inside:
            print("inside")
            self.lblStatus.text = "in beacon region"
            //既にリージョン内にいる場合にはdidEnterRegionが呼ばれないため、デリゲートメソッドを実行メソッドを実行
            if(self.beaconRegion != nil) {
                self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
                self.locationManager(manager, didEnterRegion: region)
                
            }
            //notificationの設定がされていればキャンセル
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
        case CLRegionState.Outside:
            print("outside")
            self.lblStatus.text = "out beacon region"
            
        case CLRegionState.Unknown:
            print("unknown")
            self.lblStatus.text = "unknown beacon region"
        }
    }
    
    
    //位置情報取得の認証ステータスが変更になったら呼ばれる
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
        if status == CLAuthorizationStatus.AuthorizedAlways {
            print("認証ok")
            //ビーコンからアドバタイズされるUUIDを指定
            let uuid: NSUUID! = NSUUID(UUIDString: "C708AA89-A0FE-47DB-A422-31621C6FC5FA")
            
            //beacon領域を作成
            createRegion(uuid)
            
            //ビーコン領域にはいった時のプッシュ通知設定
            //UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            if(status == CLAuthorizationStatus.NotDetermined) {
                
            }else if (status == CLAuthorizationStatus.AuthorizedAlways) {
                //端末側で位置情報取得の許可をした
                manager.startMonitoringForRegion(self.beaconRegion)
            }else{
                print("その他")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("観測開始")
        self.locationManager.requestStateForRegion(self.beaconRegion)
    }
    
    private func createRegion(uuid: NSUUID) {
        
        // ## ビーコン領域を作成 ##
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "iBeacon")
        self.beaconRegion.notifyEntryStateOnDisplay = true
        self.beaconRegion.notifyOnEntry = true
        // 領域に入ったときにも出たときにも通知される
        // 今回は領域から出たときの通知はRegion側でOFFにしておく
        self.beaconRegion.notifyOnExit = true
        
        /*
        // ## 通知を作成し、領域を設定 ##
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = message
        
        // 通知の対象となる領域 *今回のポイント
        notification.region = self.beaconRegion
        // 一度だけの通知かどうか
        notification.regionTriggersOnce = false
        // 後述するボタン付き通知のカテゴリ名を指定
        notification.category = "NOTIFICATION_CATEGORY_INTERACTIVE"
        */
    }
    
    private func getCunnrentDate(format: String) ->String {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(now)
    }
    
    private func getCunnrentTime() -> String {
        let now = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        //let calendar = NSCalendar(identifier: NSCalendarIdentifierJapanese)
        let comps:NSDateComponents = calendar!.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: now)
        
        let hour  = comps.hour
        let minute = comps.minute
        let currentTime = String(format: "%02d", hour) + ":" + String(format: "%02d", minute)
        return currentTime

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

