//
//  AppDelegate.swift
//  root-drive-science-ios
//
//  Created by Hammer on 9/9/19.
//  Copyright © 2019 Root. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import RootTripTracker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var tracker: TripTracker!
    
    static func didReceiveToken(token: String) -> Void {
        NotificationCenter.default.post(
            name: .didReceiveToken,
            object: nil,
            userInfo: ["token": token])
    }
    
    static func didNotReceiveToken(token: String) -> Void {
        NotificationCenter.default.post(
            name: .didNotReceiveToken,
            object: nil,
            userInfo: ["token": token]) 
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if CMMotionActivityManager.authorizationStatus() == .notDetermined {
            let activityManager = CMMotionActivityManager()
            let operationQueue = OperationQueue()
            activityManager.queryActivityStarting(from: Date.distantPast, to: Date(), to: operationQueue) {
                (activities, error) in
                if error != nil {
                    //user rejected permission
                }
            }
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            let locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()
        }
        
        tracker = TripTracker(environment: .local)
        tracker.start(
            clientID: "450911b3-5920-471d-bfdb-be509784e29c",
            didSucceedCallback: AppDelegate.didReceiveToken,
            didFailCallback: AppDelegate.didNotReceiveToken)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

