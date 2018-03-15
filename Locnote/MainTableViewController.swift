//
//  MainTableViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 29.11.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
import TwitterKit
import FacebookLogin
import UserNotifications

class MainTableViewController: UITableViewController
{
    var window: UIWindow?
    
    @IBOutlet weak var currentCollectionView: UICollectionView!
    @IBOutlet weak var complitedCollectionView: UICollectionView!
    
    var complitedCollectionModel = ComplitedNotificationCollectionViewModel()
    var currentCollectionModel = CurrentNotificationCollectionViewModel()

    var str = "\n\n\nSTR\n\n\n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setUpCurrentCollectionView()
        self.setUpCompletedCollectionView()
    }
    
    func setUpCurrentCollectionView() {
        self.currentCollectionView.dataSource = self.currentCollectionModel
        self.currentCollectionView.delegate = self.currentCollectionModel
        
        self.currentCollectionModel.collectionView = {
            return self.currentCollectionView
        }
        
        self.currentCollectionModel.goToSendToMeNote = { sendToMeNote in
//            self.performSegue(withIdentifier: "sendToMe", sender: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "sendToMeController") as! SendToMeTableViewController
            nextVC.notification = sendToMeNote
            self.navigationController!.pushViewController(nextVC, animated: true)
        }
        
        self.currentCollectionModel.goToSendToContactNote = { sendToContactNote in
//            self.performSegue(withIdentifier: "sendToContact", sender: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "sendToContactController") as! SendToContactTableViewController
            nextVC.notification = sendToContactNote
            self.navigationController!.pushViewController(nextVC, animated: true)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressForCurrentCollectionCell(gesture:)))
        self.currentCollectionView.addGestureRecognizer(longPressGesture)
        
        self.currentCollectionModel.addNewNotification = {
            let alert = UIAlertController(title: "Add Notification",
                                          message: "What kind of notification to add?",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Send To Me Notification",
                                          style: .default,
                                          handler: { (UIAlertAction) in
                                            self.performSegue(withIdentifier: "sendToMe", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Send To Contact Notification",
                                          style: .default,
                                          handler: { (UIAlertAction) in
                                            self.performSegue(withIdentifier: "sendToContact", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func longPressForCurrentCollectionCell(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: self.currentCollectionView)
            
            if let indexPath = self.currentCollectionView.indexPathForItem(at: point) {
                if indexPath.item == self.currentCollectionView.numberOfItems(inSection: indexPath.section) - 1 {
                    return
                }
                
                let alert = UIAlertController(title: "Delete Cell",
                                              message: "Are You Shure?",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes",
                                              style: .default,
                                              handler: { (UIAlertAction) in
                    self.currentCollectionModel.deleteCell(at: indexPath)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                print("couldn't find index path")
            }
        }
    }
    
    
    func setUpCompletedCollectionView() {
        self.complitedCollectionView.dataSource = self.complitedCollectionModel
        self.complitedCollectionView.delegate = self.complitedCollectionModel
        
        self.complitedCollectionModel.collectionView = {
            return self.complitedCollectionView
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressForCompletedCollectionCell(gesture:)))
        self.complitedCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    func longPressForCompletedCollectionCell(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: self.complitedCollectionView)
            
            if let indexPath = self.complitedCollectionView.indexPathForItem(at: point) {
                
                let alert = UIAlertController(title: "Delete Cell",
                                              message: "Are You Shure?",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes",
                                              style: .default,
                                              handler: { (UIAlertAction) in
                                                self.complitedCollectionModel.deleteCell(at: indexPath)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                print("couldn't find index path")
            }
        }
    }
    
    
    
    
    
    
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Attantion!",
                                      message: "Are you shure?",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "YES",
                                      style: UIAlertActionStyle.default,
                                      handler: { (UIAlertAction) in
                                        
                                        let social = UserDefaults.standard.string(forKey: "userAuthorizedBy")
                                        if social == nil {
                                            return
                                        }
                                        switch social! {
                                            case "Facebook":
                                                print("Facebook")
                                                LoginManager().logOut()
                                            case "Twitter":
                                                print("Twitter")
                                                let store = Twitter.sharedInstance().sessionStore
                                                let userID = store.session()?.userID
                                                if  userID != nil {
                                                    store.logOutUserID(userID!)
                                                }
                                            case "Instagram":
                                                print("Instagram")
                                            
                                            case "Google":
                                                print("Google")
                                                GIDSignIn.sharedInstance().signOut()
                                        default:
                                            print("No Social is found")
                                        }
                                        
                                        UserDefaults.standard.set(nil, forKey: "userAuthorizedBy")
                                        
                                        
                                        self.window = UIWindow(frame: UIScreen.main.bounds)
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInToContinueID")
                                        self.window?.rootViewController = initialViewController
                                        self.window?.makeKeyAndVisible()
                                        

        }))
        alert.addAction(UIAlertAction(title: "NO",
                                      style: UIAlertActionStyle.cancel,
                                      handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
}


extension MainTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath.init(row: 0, section: 0) {
            let width = UIScreen.main.bounds.width
            return width/2/0.5667
        }
        return 150
    }
}

extension MainTableViewController: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let id = response.notification.request.identifier
        let request : NSFetchRequest<Notification> = Notification.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        request.predicate = predicate
        var resultNotifications :[Notification] = []
        do {
            resultNotifications = try context.fetch(request)
            
            if !resultNotifications.isEmpty {
                let object = resultNotifications.first
                if let sendToMeNote = object as? SendToMeNote {
                    let nextVC = storyboard.instantiateViewController(withIdentifier: "sendToMeController") as! SendToMeTableViewController
                    nextVC.notification = sendToMeNote
                    nextVC.isEditable = false
                    self.navigationController!.pushViewController(nextVC, animated: true)
                }
                else if let sendToContactNote = object as? SendToContactNote {
                    let nextVC = storyboard.instantiateViewController(withIdentifier: "sendToContactController") as! SendToContactTableViewController
                    self.navigationController!.pushViewController(nextVC, animated: true)
                }
                
            }

            
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        
        
        
        
        
        completionHandler()
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("\n\n\n\nNotification being triggered")
        completionHandler( [.alert,.sound,.badge])
    }
}

