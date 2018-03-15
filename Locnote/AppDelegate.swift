//
//  AppDelegate.swift
//  Locnote
//
//  Created by Ruzhin Alexey on 19.10.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import FacebookCore
import Fabric
import TwitterKit
import Crashlytics
import InstagramSDK_iOS
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let clientId = "1a06164fcf894e32b9b7f5adf4b2368c"
    let clientSecret = "ff8a0ee9f6f94b1baf1594a44ce3ec87"
    let redirectURL = "ig1a06164fcf894e32b9b7f5adf4b2368c://authorize/instagram"
//    let redirectURL = "http://vk.com"

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        LocationManager.shared.requestAlwaysAuthorization()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        let userAuthorizedBy = UserDefaults.standard.string(forKey: "userAuthorizedBy")
        if userAuthorizedBy != nil {
            self.makeInitialViewControllerWithID(id: "MainNavigationControllerID")
        }
        
        Fabric.with([Twitter.self, Crashlytics.self])
        
        InstagramAppCenter.default().setUpWithClientId(clientId, clientSecret: clientSecret, redirectURL: redirectURL)
        
        
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
//        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let stringURL: String = "\(url)"

        if stringURL.hasPrefix("fb253119741760193") {
            return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
        else if stringURL.hasPrefix("com.googleusercontent"){
            return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        else if InstagramAppCenter.default().matchedURL(url) {
            return InstagramAppCenter.default().application(app, open: url,
                                                            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                            annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        return true
    }
    
//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        
//    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    // MARK: - Manual Methods
    func makeInitialViewControllerWithID(id:String) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: id)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Locnote")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}



