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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if((self.defaults.objectForKey("email")) == nil) {
            
            //ユーザー登録フォーム
            self.window?.rootViewController = UserRegistViewController()

        }else{
            
            //時刻表示
            let nav = CustomNavigationController(rootViewController: ViewController())
            //nav.navigationItem.title = "ほげ"
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
            
        }
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil))
        
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
    

    
    


}

