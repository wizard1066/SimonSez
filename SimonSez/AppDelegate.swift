//
//  AppDelegate.swift
//  SimonSez
//
//  Created by localadmin on 24.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import UserNotifications
import Combine

let challengePublisher = PassthroughSubject<String, Never>()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    registerForNotifications()
    return true
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    //
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

extension AppDelegate: UNUserNotificationCenterDelegate {

// code 1
func registerForNotifications() {
  let center  = UNUserNotificationCenter.current()
  center.delegate = self
  center.requestAuthorization(options: [.provisional]) { (granted, error) in
    if error == nil{
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    } else {
      print("error ",error)
    }
  }
}

  func application( _ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    token = tokenParts.joined()
    print("Device Token: \n\(token)\n")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("failed error ",error)
  }
  
  func application( _ application: UIApplication,
               didReceiveRemoteNotification userInfo: [AnyHashable : Any],
               fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    debugPrint("didReceiveRemoteNotification: \(userInfo)")
    let simonSez = userInfo["SimonSez"] as? String?
    var delay = 1.0
    if simonSez != nil {
      let buttonsToFire = simonSez!!.map( { String($0) })
      print("b2F ",buttonsToFire)
      execAfterDelay(value: buttonsToFire)
//      for b2F in buttonsToFire {
//        switch b2F {
//        case "1":
//          DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { rPublisher.send();print("1",delay);delay += 4.0 })
//        case "2":
//          DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { gPublisher.send();print("2",delay);delay += 4.0 })
//        case "3":
//          DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { yPublisher.send();print("3",delay);delay += 4.0 })
//        default:
//          // case 4
//          DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { bPublisher.send();print("4",delay);delay += 4.0 })
//        }
//
//      }
      
    }
    completionHandler(.newData)
  }
  
  func execAfterDelay(value:[String]) {
    var copyC = value
    var nextC = copyC.popLast()
    if nextC != nil {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.execAfterDelay(value: copyC)
        print("nextC ",nextC)
        switch nextC {
          case "1": DispatchQueue.main.async { rPublisher.send() }
          case "2": DispatchQueue.main.async { gPublisher.send() }
          case "3": DispatchQueue.main.async { yPublisher.send() }
          default: DispatchQueue.main.async { bPublisher.send() }
        }
      }
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
  
    let userInfo = notification.request.content.userInfo["aps"]! as! Dictionary<String, Any>
    debugPrint("willPresent: \(userInfo)")
    completionHandler([.alert, .badge, .sound])
  }
  
  
}

