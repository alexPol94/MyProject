//
//  LocationManagerSingleton.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 16.03.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UserNotifications

class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    var notification: Notification? = nil
    
    enum direction: Int {
        case Enter = 1
        case Exit = 0
    }
    
    private override init() {
        super.init()
        self.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        checkRegion(region: region,
                    locationManager: manager,
                    direction: .Enter)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        checkRegion(region: region,
                    locationManager: manager,
                    direction: .Exit)
    }
    
    func checkRegion(region: CLRegion, locationManager: CLLocationManager, direction: direction) {
        let context = self.getContext()
        let request : NSFetchRequest<Notification> = Notification.fetchRequest()
        let predicate = NSPredicate(format: "isFinished == %i AND placeLocation.isArrive == %i AND id == %@", argumentArray: [0, direction.rawValue, region.identifier])
        request.predicate = predicate
        var result :[Notification] = []
        do {
            result = try context.fetch(request)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        for notification in result {
            
            if notification.id == region.identifier {
                
                notification.isFinished = true
                do {
                    try context.save()
                } catch {
                    print("Error with save")
                }
                
                locationManager.stopMonitoring(for: region)
                self.triggerNotification(for: notification)
            }
        }
    }
    
    
    func triggerNotification(for notification: Notification) {
        
        self.notification = notification
        
        let content = UNMutableNotificationContent()
        content.title = notification.placeLocation!.title!
        content.subtitle = notification.placeLocation!.subTitle!
        content.body = notification.message!.text!
        content.sound = UNNotificationSound.default()
        
        // Deliver the notification in 1 second.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let requestIdentifier = notification.id!
        let request = UNNotificationRequest(identifier:requestIdentifier,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription)
            }
        }
    }
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
