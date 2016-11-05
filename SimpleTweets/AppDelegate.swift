//
//  AppDelegate.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/2/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let hamburgerViewControllerString = "HamburgerViewController"
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Configurate Realm
        setDefaultRealmForUser(username: "defaultRealm")
        
        // Verify login
        if User.currentUserId != nil {
            print("Found current user")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: self.hamburgerViewControllerString)
            
            window?.rootViewController = viewController
        } else {
            print("No current user")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(User.USER_DID_LOG_OUT), object: nil, queue: OperationQueue.main) { (Notification) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = viewController
        }
        
        return true
    }
    
    func setDefaultRealmForUser(username: String) {
        var config = Realm.Configuration (
            // Set the new Schema version. This must be greater than the previously used version.
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in
                migration.deleteData(forType: User.className())
            }
        )

        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(username).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.description)
        
        let twitterClient = TwitterClient.sharedInstance
        
        twitterClient?.handleOpenUrl(url: url)
        
        return true
    }

}

