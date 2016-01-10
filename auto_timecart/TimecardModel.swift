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
    
    private var alamoManager : Manager?
    var email: String?
    override init() {
        super.init()
    }
    
    func attendance(params: [String: AnyObject]?, callback:()->()) {
        
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
                    
                    callback()
                }
            }
        }
    }
    
    
    func clockout(params: [String: AnyObject]?, callback:()->()) {
        
        //出勤チェック
        self.callApi(self.isAttendUrl, params: params) {(data)->() in
            
            let str: String = String(data:data, encoding:NSUTF8StringEncoding)!
            if(str == "true") {
            
                //18時半以降、1時間たっても戻ってこなければタイムカードに退勤時間を登録する
                self.callApi(self.clockoutUrl, params: ["email": "kobayashi@basicinc.jp"]) { (data)->() in
                    
                    if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
                        UIApplication.sharedApplication().cancelAllLocalNotifications()
                        let notification = UILocalNotification()
                        notification.fireDate = NSDate(timeIntervalSinceNow: 30)
                        notification.timeZone = NSTimeZone.defaultTimeZone()
                        notification.alertBody = "お疲れ様でした"
                        notification.alertAction = "OK"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    }else{
                        
                        SweetAlert().showAlert("退勤", subTitle: "お疲れ様でした", style: AlertStyle.Success)
                    }
                    
                    callback()
                    
                }
            }
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
                    notification.alertBody = "通信エラーが発生しました。手動でタイムカードを更新してください。\n\(url)\n\(error)"
                    notification.alertAction = "OK"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }else{
                    SweetAlert().showAlert("通信エラー", subTitle: "エラーが発生しました。手動でタイムカードを更新してください", style: AlertStyle.Error)
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
