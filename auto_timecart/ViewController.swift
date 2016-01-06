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
    private var didEnterFlg   = false
    private var didExit       = false
    
    //private let checkUrl = "http://tc.basicinc.jp/api/check.php?email=kobayashi@basicinc.jp"
    private let attendanceUrl = "http://tc.basicinc.jp/api/attendance.php?email=kobayashi@basicinc.jp"
    private let isAttendUrl   = "http://tc.basicinc.jp/api/is_attend.php?email=kobayashi@basicinc.jp"
    private let clockoutUrl   = "http://tc.basicinc.jp/api/clock_out.php?email=kobayashi@basicinc.jp"
    
    
    private let lblTitle = UILabel()
    private let lblAttendance = UILabel()
    private let lblClockout = UILabel()
    private let lblAttendanceTime = UILabel()
    private let lblClockoutTime = UILabel()
    private let lblStatus = UILabel()
    
    private var alamoManager : Manager?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseY: CGFloat = 200.0
        self.view.backgroundColor = UIColor.hex("26a4df", alpha: 0.8)
        
        /*********************/
        
        //出勤時間と退勤時間を取得するAPIを実行
        
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
        lblAttendanceTime.text = "--:--"
        lblAttendanceTime.textColor = UIColor.whiteColor()
        lblAttendanceTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblClockout.frame = CGRectMake(0, 0, 200, 100)
        lblClockout.center = CGPointMake(self.view.bounds.width/2-30, baseY+150)
        lblClockout.text = "退勤時間"
        lblClockout.textColor = UIColor.whiteColor()
        lblClockout.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblClockoutTime.frame = CGRectMake(0, 0, 200, 100)
        lblClockoutTime.center = CGPointMake(self.view.bounds.width/2+100, baseY + 150)
        lblClockoutTime.text = "--:--"
        lblClockoutTime.textColor = UIColor.whiteColor()
        lblClockoutTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        lblStatus.frame = CGRectMake(0, 0, 200, 100)
        lblStatus.center = CGPointMake(self.view.bounds.width/2, baseY + 250)
        lblStatus.text = "ビーコン領域内 or 外"
        lblStatus.textColor = UIColor.whiteColor()
        lblStatus.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        self.view.addSubview(lblTitle)
        self.view.addSubview(lblAttendance)
        self.view.addSubview(lblAttendanceTime)
        self.view.addSubview(lblClockout)
        self.view.addSubview(lblClockoutTime)
        self.view.addSubview(lblStatus)
            
        //Notificationのおまじない
        //通知をキャンセル
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
            
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    


    //ビーコンの領域にはいった時に呼ばれるデリゲートメソッド
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
        if(self.didEnterFlg) {
            //2重呼び出し防止
            return
        }
        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
        self.didEnterFlg = true
        
        //出勤時間が既に登録されていれば登録しない
        let params = ["email": "kobayashi@basicinc.jp"]
        self.callApi(self.isAttendUrl, params: params) {(data)->() in
            let str: String = String(data:data, encoding:NSUTF8StringEncoding)!
            print(str)
            //if(str == "false") {
                //API実行して登録
                self.callApi(self.attendanceUrl, params: params) { (data)->() in
                    
                    if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
                        //let json = SwiftyJSON.JSON(data: data)
                        UIApplication.sharedApplication().cancelAllLocalNotifications()
                        let notification = UILocalNotification()
                        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                        notification.timeZone = NSTimeZone.defaultTimeZone()
                        notification.alertBody = "おはようございます！"
                        notification.alertAction = "OK"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        
                    }else{
                        let alert:UIAlertController = UIAlertController(title: "出勤", message: "おはようございます！", preferredStyle: UIAlertControllerStyle.Alert)
                        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                            (action:UIAlertAction!) -> Void in
                                print("default")
                        })
                        self.presentViewController(alert, animated: true, completion: {
                            // 表示完了時の処理
                        })
                        alert.addAction(alertAction)

                    }
                    
                    let attendanceTime = self.getCunnrentTime()
                    self.lblAttendanceTime.text = attendanceTime
                    
                    self.attendanceFlg = true
                    self.didEnterFlg = false
                }
            //}
            
        }
       
    }
    
    //ビーコン領域から外に出た後に呼ばれるデリゲートメソッド
    //領域外にでてから30秒後ぐらいに実行される
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
        if(self.didExit) {
            //2重呼び出し防止
            return
        }
        self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
        self.didExit = true
        
        //出勤チェック
        let params = ["email": "kobayashi@basicinc.jp"]
        self.callApi(self.isAttendUrl, params: params) {(data)->() in
        
            //18時半以降、1時間たっても戻ってこなければタイムカードに退勤時間を登録する
            self.callApi(self.clockoutUrl, params: ["email": "kobayashi@basicinc.jp"]) { (data)->() in
                
                if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                    let notification = UILocalNotification()
                    notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    notification.timeZone = NSTimeZone.defaultTimeZone()
                    notification.alertBody = "お疲れ様でした"
                    notification.alertAction = "OK"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }else{
                    let alert:UIAlertController = UIAlertController(title: "退勤", message: "お疲れ様でした", preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                        (action:UIAlertAction!) -> Void in
                        print("default")
                    })
                    self.presentViewController(alert, animated: true, completion: {
                        // 表示完了時の処理
                    })
                    alert.addAction(alertAction)
                }
                
                let clockoutTime = self.getCunnrentTime()
                self.lblClockoutTime.text = clockoutTime
                self.attendanceFlg = false
                self.didExit = false

            }
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("観測開始")
        print(region.identifier)
        self.locationManager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
        switch(state) {
        case CLRegionState.Inside:
            print("inside")
            self.lblStatus.text = "in beacon region"
            //既にリージョン内にいる場合にはdidEnterRegionが呼ばれないため、このメソッドを実行
            self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
            
        case CLRegionState.Outside:
            print("outside")
            self.lblStatus.text = "out beacon region"
            
        case CLRegionState.Unknown:
            print("unknown")
            self.lblStatus.text = "unknown beacon region"
            //self.locationManager.requestStateForRegion(region)
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
    
    private func callApi(url: String, params: [String: AnyObject]?, complete:(data:NSData)->()) {
        print(url)
        
        //バックグランドで通信ができる
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(url)
        let _manager = Alamofire.Manager(configuration: config)
        self.alamoManager = _manager
        self.alamoManager!.startRequestsImmediately = true
        self.alamoManager!.request(.POST, url, parameters: params, encoding: ParameterEncoding.URL).response { request, response, data, error in
            print(response)
            if(error != nil) {
                
                print(error)
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 5)
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.alertBody = "通信エラーが発生しました。手動でタイムカードを登録してください。\n\(url)\n\(error)"
                notification.alertAction = "OK"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
            }else{
                complete(data: data!)
            }
        }
        
    }
    
    private func getCunnrentTime() -> String {
        let now = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        //let calendar = NSCalendar(identifier: NSCalendarIdentifierJapanese)
        let comps:NSDateComponents = calendar!.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: now)
        
        let hour  = comps.hour
        let minute = comps.minute
        let currentTime = String(hour) + ":" + String(minute)
        return currentTime

    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print(response)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print(data)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if((error) != nil) {
            print(error)
        }else{
            
            print("成功")
            
        }
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("aaa")
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        //バックグラウンド時からフォアグラウンド時に呼ばれるデリゲート
        print("bbb")
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("ccc")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

