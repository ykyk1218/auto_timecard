//
//  TimecardModel.swift
//  auto_timecard
//
//  Created by 小林芳樹 on 2016/01/10.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TimecardModel: NSObject {
    
    private let attendanceUrl = "http://tc.basicinc.jp/api/attendance.php"
    private let isAttendUrl   = "http://tc.basicinc.jp/api/is_attend.php"
    private let clockoutUrl   = "http://tc.basicinc.jp/api/clock_out.php"
    private let getTimeUrl    = "http://tc.basicinc.jp/api/getTime.php"
    private let worktimeUrl   = "http://tc.basicinc.jp/api/overtime.php"
    private let checkUserUrl  = "http://tc.basicinc.jp/api/check_user.php"
    private let recordLogUrl  = "http://tc.basicinc.jp/api/record.php"

    
    private var alamoManager : Manager?
    var email: String?
    override init() {
        super.init()
    }
    
    func getTime(params: [String: AnyObject]?, callback:(json:JSON)->()) {

        self.callApi(self.getTimeUrl, params: params) {(data)->() in
            let json = SwiftyJSON.JSON(data: data)
            
            callback(json: json)
        }
    }
    
    //出勤処理
    func attendance(params: [String: AnyObject]?, callback:(attendanceProcessed: Bool)->()) {
        
        //既に出勤しているかどうかをチェック
        self.callApi(self.isAttendUrl, params: params) {(data)->() in
            
            let str: String = String(data:data, encoding:NSUTF8StringEncoding)!
            if(str == "false") {
                
                //まだ出勤していない
                self.callApi(self.attendanceUrl, params: params) { (data)->() in
                    
                    if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
                        //バックグラウンドの場合の処理
                        //プッシュ通知をする
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
                        //アプリがアクティブの場合
                        SweetAlert().showAlert("出勤", subTitle: "おはようございます！", style: AlertStyle.Success)
                    }
                    
                    callback(attendanceProcessed: true)
                }
            }else{
                callback(attendanceProcessed: false)
            }
        }
    }
    
    
    //退勤処理
    func clockout(params: [String: AnyObject]?, callback:(clockoutProcessed: Bool)->()) {
        
        //出勤チェック
        self.callApi(self.isAttendUrl, params: params) {(data)->() in
            
            let str: String = String(data:data, encoding:NSUTF8StringEncoding)!
            if(str == "true") {
            
                self.callApi(self.clockoutUrl, params: params) { (data)->() in
                    
                    if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
                        /*
                        いつ退勤したかの判定が難しいので、push通知やめる
                        UIApplication.sharedApplication().cancelAllLocalNotifications()
                        let notification = UILocalNotification()
                        notification.fireDate = NSDate(timeIntervalSinceNow: 30)
                        notification.timeZone = NSTimeZone.defaultTimeZone()
                        notification.alertBody = "お疲れ様でした"
                        notification.alertAction = "OK"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        */
                    }else{
                        /*
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            SweetAlert().showAlert("退勤", subTitle: "お疲れ様でした", style: AlertStyle.Success)
                        }
                        */
                        
                    }
                    
                    callback(clockoutProcessed: true)
                    
                }
            }else{
                callback(clockoutProcessed: false)
            }
        }
    }
    
    //メールアドレスを元にユーザーの存在チェック
    func checkUser(params: [String: AnyObject]?, callback:(Bool)->()) {
        self.callApi(self.checkUserUrl, params: params) { (data)->() in
            let str: String = String(data:data, encoding:NSUTF8StringEncoding)!
            if(str == "false") {
                callback(false)
            }else{
                callback(true)
            }
        }
    }
    
    
    //作業時間の取得
    func worktime(params: [String: AnyObject]?, callback: (json: JSON)->()) {
        self.callApi(self.worktimeUrl, params: params) { (data)->() in
            let json = SwiftyJSON.JSON(data: data)
            callback(json: json)
        }
    }
    
    func record(params: [String: AnyObject]?) {
        self.callApi(self.recordLogUrl, params: params) { (data)->() in
            
            //特に何もしない
            
        }
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
                
                if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {

                    let notification = UILocalNotification()
                    notification.fireDate = NSDate(timeIntervalSinceNow: 5)
                    notification.timeZone = NSTimeZone.defaultTimeZone()
                    notification.alertBody = "通信エラーが発生しました。\n\(url)\n\(error)"
                    notification.alertAction = "OK"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }else{
                    SweetAlert().showAlert("通信エラー", subTitle: "通信エラーが発生しました。", style: AlertStyle.Error)
                }
                
            }else{
                
                //ここでsessionを無効にしておかないと、もう1回APIを叩こうとした時にエラーになる時がある
                self.alamoManager?.session.invalidateAndCancel()
                complete(data: data!)
                
                
            }
        }
        
    }
    
    private func getCunnrentTime() -> String {
        //アプリ表示用に現在時刻を取得する
        let now = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        //let calendar = NSCalendar(identifier: NSCalendarIdentifierJapanese)
        let comps:NSDateComponents = calendar!.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: now)
        
        let hour  = comps.hour
        let minute = comps.minute
        let currentTime = String(hour) + ":" + String(minute)
        return currentTime
    }

    
}
