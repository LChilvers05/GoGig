//
//  AppDelegate.swift
//  GoGig
//
//  Created by Lee Chilvers on 09/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GooglePlaces
import FirebaseMessaging
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyDtabGvbeAPg-FjUWaRQFEg2B86a3dr_gg")
        
        //If we are logged out, then present the LoginVC
        if Auth.auth().currentUser == nil {
            print("No current user")
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
            //Show fix for iOS 13!
            loginVC.modalPresentationStyle = .overFullScreen
            window?.makeKeyAndVisible()
            window?.rootViewController?.present(loginVC, animated: true)
        }
        
        //Push Notifications
        //Get a new FCM Token everytime the user signs out
        registerForPushNotifications()
        Messaging.messaging().delegate = self
        
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
    
    //MARK: PUSH NOTIFICATIONS
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in

                print("Permission granted: \(granted)")

                //guard is for when permission was not granted
                //it returns so user does not get notifications
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")

            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                //Triggers the registration to get device token
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    //Sets the new device FCM token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    //Team ID: SCZ5X2T8PZ
    
    //Recieves the new device FCM token, whenever it is refreshed
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        deviceFCMToken = fcmToken
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

