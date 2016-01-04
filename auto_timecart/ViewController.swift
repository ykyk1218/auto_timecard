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


class ViewController: UIViewController, CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, UITextFieldDelegate {
    
    private var locationManager: CLLocationManager!
    private var beaconRegion: CLBeaconRegion!
    
    private var attendanceFlg = false
    private var clockoutFlg   = false
    
    //private let checkUrl = "http://tc.basicinc.jp/api/check.php?email=kobayashi@basicinc.jp"
    private let attendanceUrl = "http://tc.basicinc.jp/api/attendance.php?email=kobayashi@basicinc.jp"
    private let clockoutUrl = "http://tc.basicinc.jp/api/clock_out.php?email=kobayashi@basicinc.jp"
    
    private let lblEmail = UILabel()
    private let txtEmail = UITextField()
    private let btnSubmit = UIButton()
    
    
    private let lblTitle = UILabel()
    private let lblAttendance = UILabel()
    private let lblClockout = UILabel()
    private let lblAttendanceTime = UILabel()
    private let lblClockoutTime = UILabel()
    
    private var alamoManager : Manager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseY: CGFloat = 200.0
        self.view.backgroundColor = UIColor.hex("26a4df", alpha: 0.8)

        
        /*
        DBLDownloadFont.setFontNameWithBlock({ (success:Bool, error:String!) -> Void in
            self.lblAttendance.text = "loaded !"
            }, fontName: "HiraMaruProN-W4")
        */
        
        lblEmail.frame = CGRectMake(0,0,240,50)
        lblEmail.center = CGPointMake(self.view.bounds.width/2-30, baseY)
        lblEmail.text = "メールアドレス"
        lblEmail.textColor = UIColor.whiteColor()
        lblEmail.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        txtEmail.frame = CGRectMake(0,0,240,50)
        txtEmail.center = CGPointMake(self.view.bounds.width/2-30, baseY+50)
        txtEmail.text = "kobayashi@basicinc.jp"
        txtEmail.borderStyle = UITextBorderStyle.Line
        txtEmail.backgroundColor = UIColor.whiteColor()
        let paddingView:UIView = UIView(frame: CGRectMake(0,0,10,10))
        txtEmail.leftView = paddingView
        txtEmail.textColor = UIColor.hex("333333", alpha: 1)
        txtEmail.leftViewMode = UITextFieldViewMode.Always
        txtEmail.delegate = self
        
        btnSubmit.frame = CGRectMake(20, baseY+105, self.view.bounds.width-30, 40)
        //btnSubmit.center = CGPointMake(15 , baseY+105)
        btnSubmit.backgroundColor = UIColor.hex("ADB367", alpha: 1)
        btnSubmit.setTitle(" 入力したないようで送信 ", forState: UIControlState.Normal)
        btnSubmit.setTitle(" 入力したないようで送信 ", forState: UIControlState.Highlighted)
        btnSubmit.showsTouchWhenHighlighted = true
        
        self.view.addSubview(lblEmail)
        self.view.addSubview(txtEmail)
        self.view.addSubview(btnSubmit)
        
        let aSelector = Selector("tapGesture:")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: aSelector)
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        /*********************/
        
        /*
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
        lblClockoutTime.text = "PM 07:30"
        lblClockoutTime.textColor = UIColor.whiteColor()
        lblClockoutTime.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        
        
        
        self.view.addSubview(lblTitle)
        self.view.addSubview(lblAttendance)
        self.view.addSubview(lblAttendanceTime)
        self.view.addSubview(lblClockout)
        self.view.addSubview(lblClockoutTime)
        */
        
        //Notificationのおまじない
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        /*
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound,
                UIUserNotificationType.Badge,
                UIUserNotificationType.Alert], categories: nil)
        )
        */
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        
        //let params = "attendanceTime=hogehoge&email=kobayashi@basicinc.jp"
        //self.callApi(self.apiUrl, params: params)
    }
    
    func tapGesture(gestureRecognizer: UITapGestureRecognizer){
        self.txtEmail.resignFirstResponder()
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
        if status == CLAuthorizationStatus.AuthorizedAlways {
            print("認証ok")
            
            //let uuid: NSUUID! = NSUUID(UUIDString: "1454CBD0-3C5B-9CB3-5F4B-39825248ABD4")
            let uuid: NSUUID! = NSUUID(UUIDString: "C708AA89-A0FE-47DB-A422-31621C6FC5FA")
            //let uuid: NSUUID! = NSUUID(UUIDString: "47ED9932-6064-29D1-3B3D-6E2259DDE092")
            
            
            let message = "konashiが近くにあります。"
            let notification = createRegionNotification(uuid, message: message)
            
            //ビーコン領域にはいった時のプッシュ通知設定
            //UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            if(status == CLAuthorizationStatus.NotDetermined) {
                
            }else if (status == CLAuthorizationStatus.AuthorizedAlways) {
                print("hoge")
                manager.startMonitoringForRegion(self.beaconRegion)
                manager.startRangingBeaconsInRegion(self.beaconRegion)
            }else{
                print("その他")
            }
        }
    }

    //ビーコンの領域にはいった時に呼ばれるデリゲートメソッド
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
        
        let attendanceTime = getCunnrentTime()
        self.lblAttendanceTime.text = attendanceTime
        
        //出勤時間が既に登録されていれば登録しない
        
        //API実行して登録
        //let params = "attendanceTime=\(attendanceTime)&email=kobayashi@basicinc.jp"
        let params = ["attendanceTime":attendanceTime, "email": "kobayashi@basicinc.jp"]
        
        self.callApi(self.attendanceUrl, params: params)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
        
        //出勤チェック
        //出勤してない場合は退勤処理は走らせない

            
        //18時半以降、1時間たっても戻ってこなければタイムカードに退勤時間を登録する
        self.callApi(self.clockoutUrl, params: ["email": "kobayashi@basicinc.jp"])
        
        
        /*
        //退勤フラグ設定
        self.clockoutFlg = true
        //ビーコンの領域を抜けた時間を取得
        
        let delay = 10.0 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            print("dispatch after!")
            if(self.clockoutFlg) {
                
                print("clockoutFlg")
                
                
                
                self.attendanceFlg = false
            }
        })
        */
            
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
            self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
            
        case CLRegionState.Outside:
            print("outside")
            
        case CLRegionState.Unknown:
            print("unknown")
            //self.locationManager.requestStateForRegion(region)
        }
    }
    
    private func createRegionNotification(uuid: NSUUID, message: String) -> UILocalNotification {
        
        // ## ビーコン領域を作成 ##
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "iPod touch hoge")
        self.beaconRegion.notifyEntryStateOnDisplay = true
        self.beaconRegion.notifyOnEntry = true
        // 領域に入ったときにも出たときにも通知される
        // 今回は領域から出たときの通知はRegion側でOFFにしておく
        self.beaconRegion.notifyOnExit = true
        
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
        
        
        return notification
    }
    
    private func callApi(url: String, params: [String: AnyObject]?) {
        print(url)
        /*
        let postData = params.dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        */
        
        //バックグランドで通信ができる
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("auto_timecard")
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
                if(url.containsString("attendance")) {
                    self.handleNotification(data!, type: "attendance")
                }else{
                    self.handleNotification(data!, type: "clock_out")
                }
            }
        }
        
    }
    
    private func handleNotification(data: NSData, type: String) {
        print(data)
        let json = SwiftyJSON.JSON(data: data)
        print(json)
        
        if(type == "attendance") {
            let notification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: 1)
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = "おはようございます！"
            notification.alertAction = "OK"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
        }else if(type == "clock_out") {
            let notification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: 1)
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = "お疲れ様でした"
            notification.alertAction = "OK"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //テキストフィールドからフォーカスを外して、キーボードを閉じる
        textField.resignFirstResponder()
        return true
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

