//
//  AppDelegate.swift
//  auto_timecart
//
//  Created by 小林芳樹 on 2015/12/27.
//  Copyright © 2015年 小林芳樹. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion!

    var attendanceFlg = false
    var clockoutFlg   = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Notificationのおまじない
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound,
                                                  UIUserNotificationType.Badge,
                                                  UIUserNotificationType.Alert], categories: nil)
        )
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //登録済みのスケジュールをリセット
        //application.cancelAllLocalNotifications()
        
        // ビーコン領域をトリガーとした通知を作成(後述)
        //let notification = createRegionNotification(uuid, message: message)
        // 通知を登録する
        //UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        /*
        var notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "通知テスト"
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        */
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
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
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("enter")
        
        let now = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        //let calendar = NSCalendar(identifier: NSCalendarIdentifierJapanese)
        var comps:NSDateComponents = calendar!.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: now)
        
        
        var year  = comps.year
        var month = comps.month
        var day   = comps.day
        var hour  = comps.hour
        var minute = comps.minute
        var second = comps.second
        
        print("\(year)-\(month)-\(day) \(hour):\(minute):\(second)")
        
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        print(dateFormatter.stringFromDate(now))
        
        //出勤時間が既に登録されていれば登録しない
        
        //退勤フラグをOFFにする
        
        //登録に成功・失敗時にローカルプッシュ
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "出勤しました"
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        self.clockoutFlg = false
        self.attendanceFlg = true
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exit")
        
        //出勤チェック
        //出勤してない場合は退勤処理は走らせない
        if(self.attendanceFlg) {
        
            //18時半以降、1時間たっても戻ってこなければタイムカードに退勤時間を登録する
            
            //退勤フラグ設定
            self.clockoutFlg = true
            //ビーコンの領域を抜けた時間を取得
            
            let delay = 10.0 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                print("dispatch after!")
                if(self.clockoutFlg) {
                    
                    print("clockoutFlg")
                    
                    //登録に成功・失敗時にローカルプッシュ
                    let notification = UILocalNotification()
                    notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    notification.timeZone = NSTimeZone.defaultTimeZone()
                    notification.alertBody = "退勤しました"
                    notification.alertAction = "OK"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    
                    self.attendanceFlg = false
                }
            })
            
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
            self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
            
        case CLRegionState.Outside:
            print("outside")
            
        case CLRegionState.Unknown:
            print("unknown")
            self.locationManager.requestStateForRegion(region)
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


}

