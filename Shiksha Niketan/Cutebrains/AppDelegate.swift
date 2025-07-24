//
//  AppDelegate.swift
//  Cutebrains
//
//  Created by QTS Coder on 20/05/2024.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var tokenUser = ""
    var webViewVC: WebViewController?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
      
        onHandleSetupNotification(application)
        Messaging.messaging().delegate = self
        return true
    }

    func onHandleSetupNotification(_ app: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        app.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("\n\n\n\n\n ==== FCM Token:  ",fcmToken ?? "")
        self.tokenUser = fcmToken ?? ""
    }
 
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let timeCheck = UserDefaults.standard.value(forKey: KEY_CHECK_UPDATE_VERSION) as? TimeInterval{
            if Date().timeIntervalSince1970 > (timeCheck + Double(SECOND_CHECK_UPDATE_VERSION)){
                if let webViewVC = webViewVC{
                    print("checkVersionUpdate")
                    webViewVC.checkVersionUpdate()
                }
               
            } else{
                print("NO checkVersionUpdate")
            }
        }
        else{
            if let webViewVC = webViewVC{
                print("applicationDidBecomeActive")
                webViewVC.checkVersionUpdate()
            }
        }
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("response--->",response.notification)
        let userInfo = response.notification.request.content.userInfo
            
            if let aps = userInfo["aps"] as? [String: Any],
               let soundName = aps["sound"] as? String {
                print("File sound is: \(soundName)")
            }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("response--->",notification)
        if #available(iOS 14.0, *) {
            completionHandler(.banner)
        } else {
            completionHandler(.alert)
        }
    }
}
