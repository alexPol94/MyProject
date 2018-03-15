//
//  SendToMeTableViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 01.12.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Crashlytics

class SendToMeTableViewController: UITableViewController {
    
    
    // MARK: - Outlets
    @IBOutlet weak var geopositionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var soundMessagesTableView: UITableView!
    
    // MARK: - Properties
//    var contact:ContactEntry?
    var notification: SendToMeNote? = nil
    
    var placeMark: PlaceMark?
    var attributedTextMessage: NSAttributedString?
    var plainTextMessage: String?
    var photos = [UIImage]()
    var contacts = [ContactEntry]()
    var audioMessages = [Data]()
    
    var isEditable: Bool = true
    
    var contactsTableViewModel = ContactsTableViewModel()
    var photosCollectionViewModel = PhotosCollectionViewModel()
    var audioMessageTableViewModel = AudioMessageTableViewModel()
    


    // MARK: - Navigation Controller Buttons
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        if self.isEditable {
            if self.placeMark == nil {
                self.presentAlert(with: "Alert",
                                  message: "There are no selected place")
                return
            }
            else if self.messageTextView.text.isEmpty {
                self.presentAlert(with: "Alert",
                                  message: "There are no message")
                return
            }
            
            self.contacts = self.contactsTableViewModel.contacts
            self.photos = self.photosCollectionViewModel.photos
            self.audioMessages = self.audioMessageTableViewModel.soundMessages
            
            
            let context = self.getContext()
            if self.notification == nil {
                self.notification = NSEntityDescription.insertNewObject(forEntityName: "SendToMeNote", into: context) as? SendToMeNote
            }
            notification!.isFinished = false
            let date = NSDate()
            notification!.creationDate = date
            
            let placeLocation = NSEntityDescription.insertNewObject(forEntityName: "PlaceCoordinate", into: context) as! PlaceCoordinate
            placeLocation.latitude = self.placeMark!.latitude
            placeLocation.longitude = self.placeMark!.longitude
            placeLocation.title = self.placeMark!.textForTitle
            placeLocation.subTitle = self.placeMark!.textForSubtitle
            placeLocation.isArrive = self.placeMark!.isArrive
            notification!.placeLocation = placeLocation
            
            
            
            let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message.text = self.plainTextMessage
            let messageData = NSKeyedArchiver.archivedData(withRootObject: self.attributedTextMessage)
            message.attributedText = messageData as NSData?
            notification!.message = message
            
            notification!.audioMessages = nil
            for audioMessageData in self.audioMessages {
                let audioObject = NSEntityDescription.insertNewObject(forEntityName: "AudioMessage", into: context) as! AudioMessage
                audioObject.audio = audioMessageData as NSData?
                notification!.addToAudioMessages(audioObject)
            }
            
            notification!.photos = nil
            for image in self.photos {
                let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
                let imageData = UIImagePNGRepresentation(image)
                photo.imageData = imageData as NSData?
                notification!.addToPhotos(photo)
            }
            
            notification!.contacts = nil
            for contactEntry in self.contacts {
                let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
                contact.firstName = contactEntry.name
                contact.lastName = contactEntry.surName
                contact.phone = contactEntry.phone
                contact.email = contactEntry.email
                if let image = contactEntry.image {
                    contact.photo = UIImagePNGRepresentation(image)! as NSData?
                }
                notification!.addToContacts(contact)
                
            }
            
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
            let id = dateFormatter.string(from: date as Date)
            notification!.id = id
            
            
            let radius = 20 * 1000
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: placeLocation.latitude, longitude: placeLocation.longitude), radius: CLLocationDistance(radius), identifier: id)
            if placeLocation.isArrive {
                region.notifyOnEntry = true
                region.notifyOnExit = false
            }
            else {
                region.notifyOnEntry = false
                region.notifyOnExit = true
            }
            
            
            LocationManager.shared.startMonitoring(for: region)
            try! context.save()
        }
        
        self.navigationController!.popViewController(animated: true)
    }
    
    
    func presentAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Ok",
                                   style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - View Methods Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTextView.isEditable = self.isEditable
        self.setDelegates()
        self.setImagePicker()
        self.fillTheFields(with: self.notification)
        self.setGestureRecognizers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let selectedIndexPath = self.contactsTableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            self.contactsTableView.deselectRow(at: selectedIndexPath!, animated: false)
        }
    }
    
    
    // MARK: - Start Settings
    
    func fillTheFields(with note: SendToMeNote?) {
        if note == nil {
            return
        }
        self.placeMark = PlaceMark()
        self.placeMark!.latitude = note!.placeLocation!.latitude
        self.placeMark!.longitude = note!.placeLocation!.longitude
        self.placeMark!.isArrive = note!.placeLocation!.isArrive
        self.placeMark!.textForTitle = note!.placeLocation!.title!
        self.placeMark!.textForSubtitle = note!.placeLocation!.subTitle!
        self.setMap(with: self.placeMark!)
        
        self.photos = []
        for photo in note!.photos! {
            if let image = UIImage(data: (photo as! Photo).imageData as! Data) {
                self.photos.append(image)
            }
        }
        self.photosCollectionViewModel.photos = self.photos
        self.photosCollectionView.reloadData()
        
        self.contacts = []
        for contact in note!.contacts! {
//            @NSManaged public var email: String?
//            @NSManaged public var firstName: String?
//            @NSManaged public var lastName: String?
//            @NSManaged public var phone: String?
//            @NSManaged public var photo: Photo?
            let contactData = contact as! Contact
            let contactEntry = ContactEntry(name: contactData.firstName!,
                                            email: contactData.email,
                                            phone: contactData.phone,
                                            image: nil)
            if let imageData = contactData.photo {
                contactEntry.image = UIImage(data: imageData as Data)
            }
            contactEntry.surName = contactData.lastName
            self.contacts.append(contactEntry)
            
        }
        self.contactsTableViewModel.contacts = self.contacts
        self.contactsTableView.reloadData()
        
        self.audioMessages = []
        for audio in note!.audioMessages! {
            let audioData = (audio as! AudioMessage).audio as! Data
            self.audioMessages.append(audioData)
        }
        self.audioMessageTableViewModel.soundMessages = self.audioMessages
        self.soundMessagesTableView.reloadData()
        
        
    }
    
    func setImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = photosCollectionViewModel
        
        self.photosCollectionViewModel.openImagePickerComplition = {
            imagePicker.allowsEditing = false
            
            let alert = UIAlertController(title: "Add Image",
                                          message: "",
                                          preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Photo Library",
                                          style: UIAlertActionStyle.default,
                                          handler: { (UIAlertAction) in
                                            imagePicker.sourceType = .savedPhotosAlbum
                                            self.present(imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Camera",
                                          style: UIAlertActionStyle.default,
                                          handler: { (UIAlertAction) in
                                            imagePicker.sourceType = .camera
                                            self.present(imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: UIAlertActionStyle.cancel,
                                          handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        self.photosCollectionViewModel.selectedImageComplition = {
            self.photosCollectionView.reloadData()
        }
    }
    
    func setDelegates() {
        self.contactsTableView.dataSource = contactsTableViewModel
        self.contactsTableView.delegate = contactsTableViewModel
        self.contactsTableViewModel.isEditable = {return self.isEditable}
        
        self.photosCollectionView.dataSource = photosCollectionViewModel
        self.photosCollectionView.delegate = photosCollectionViewModel
        self.photosCollectionViewModel.isEditable = {return self.isEditable}
        
        self.soundMessagesTableView.dataSource = audioMessageTableViewModel
        self.soundMessagesTableView.delegate = audioMessageTableViewModel
        self.audioMessageTableViewModel.isEditable = {return self.isEditable}
    }
    
    func setMap(with placeMark: PlaceMark) {
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake( 0.1 , 0.1 )
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: placeMark.latitude, longitude: placeMark.longitude )
        let theRegion = MKCoordinateRegionMake( location, theSpan )
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = placeMark.textForTitle//"The Location"
        anotation.subtitle = placeMark.textForSubtitle//"This is the location !!!"
        self.mapView.addAnnotation( anotation )
        
        
        self.mapView.setRegion( theRegion, animated: false )
        self.mapView.addAnnotation( anotation )
        self.geopositionLabel.text = placeMark.textForTitle
    }
    
    
    // MARK: - Gesture Recognizers
    func setGestureRecognizers() {
        if self.isEditable {
            let messageTextVewTap = UITapGestureRecognizer(target: self, action: #selector(self.messageTextViewClicked))
            messageTextView.addGestureRecognizer(messageTextVewTap)
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressForCurrentCollectionCell(gesture:)))
            self.photosCollectionView.addGestureRecognizer(longPressGesture)
        }
    }
    
    
    func longPressForCurrentCollectionCell(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: self.photosCollectionView)
            
            if let indexPath = self.photosCollectionView.indexPathForItem(at: point) {
                if indexPath.item == self.photosCollectionView.numberOfItems(inSection: indexPath.section) - 1 {
                    return
                }
                
                let alert = UIAlertController(title: "Delete Cell",
                                              message: "Are You Shure?",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes",
                                              style: .default,
                                              handler: { (UIAlertAction) in
//                                                self.photosCollectionViewModel.deleteCell(at: indexPath)
                                                self.photosCollectionView.performBatchUpdates({ 
                                                    self.photosCollectionViewModel.photos.remove(at: indexPath.item)
                                                    self.photosCollectionView.deleteItems(at: [indexPath])
                                                }, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                print("couldn't find index path")
            }
        }
    }
    
        
    func messageTextViewClicked() {
        self.performSegue(withIdentifier: "messageSegueID", sender: self)
    }
    
    
    // MARK: - Navigation with Segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.isEditable {
            return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "geopositionSegueID" {
            let nextVC = segue.destination as! GeoPositionViewController
            nextVC.getPlaceMark = {
                return self.placeMark
            }
            nextVC.complition = { (placeMark) in
                self.placeMark = placeMark
                self.setMap(with: placeMark)
            }
        }
        else if segue.identifier == "messageSegueID" {
            let nextVC = segue.destination as! MessageTextViewController
            if !self.messageTextView.text.isEmpty {
                nextVC.textForInit = self.messageTextView.attributedText
            }
            nextVC.exitComplition = { attributedText, plainText in
                self.messageTextView.attributedText = attributedText
                self.attributedTextMessage = attributedText
                self.plainTextMessage = plainText
            }
        }
        else if segue.identifier == "contactsSegueID" {
            let nextVC = segue.destination as! ContactsTableViewController
            nextVC.complition = { contactEntry in
                let indexPath = self.contactsTableView.indexPathForSelectedRow
                if indexPath != nil {
                    self.contactsTableViewModel.contacts[indexPath!.row] = contactEntry
                } else if self.contactsTableViewModel.contacts.count < 3 {
                    self.contactsTableViewModel.contacts.append(contactEntry)
                }
                self.contactsTableView.reloadData()
            }
        }
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - CoreData Context
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
