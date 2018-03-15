//
//  SendToContactTableViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 01.12.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
import Contacts
import MapKit
import CoreData

class SendToContactTableViewController: UITableViewController {
    
    // MARK: - Properties
    var contactEntry: ContactEntry?
    var placeMark: PlaceMark?
    var notification: SendToContactNote?
    
    // MARK: - Outlets
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var geopositionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageTextView: UITextView!
    
    // MARK: - Navigation Bar Buttons
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        if self.contactEntry == nil {
            self.presentAlert(with: "Alert", message: "There are no selected contact")
            return
        }
        else if self.placeMark == nil {
            self.presentAlert(with: "Alert", message: "There are no selected place")
            return
        }
        else if self.messageTextView.text.isEmpty {
            self.presentAlert(with: "Alert", message: "There are no message")
            return
        }
        
        let context = self.getContext()
        if self.notification == nil {
            self.notification = NSEntityDescription.insertNewObject(forEntityName: "SendToContactNote", into: context) as? SendToContactNote
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
        message.text = self.messageTextView.text
        notification!.message = message
    
        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
        contact.firstName = contactEntry!.name
        contact.lastName = contactEntry!.surName
        contact.phone = contactEntry!.phone
        contact.email = contactEntry!.email
        
        if let image = contactEntry!.image {
            contact.photo = UIImagePNGRepresentation(image) as NSData?
        }
        notification!.contact = contact
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
        let id = dateFormatter.string(from: date as Date)
        notification!.id = id
        
        
        let radius = 20 * 1000
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: placeLocation.latitude,
                                                                     longitude: placeLocation.longitude),
                                      radius: CLLocationDistance(radius),
                                      identifier: id)
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
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - Override View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fillTheFields(with: self.notification)
    }
    
    
    // MARK: - Navigation Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendToContactsSegueID" {
            let nextVC = segue.destination as! ContactsTableViewController
            nextVC.complition = { contact in
                self.contactEntry = contact
                self.fillContactFields(with: contact)
            }
        }
        if segue.identifier == "toGeoControllerID" {
            let nextVC = segue.destination as! GeoPositionViewController
            nextVC.getPlaceMark = {
                return self.placeMark
            }
            nextVC.complition = { (placeMark) in
                self.placeMark = placeMark
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
    
    
    //MARK: - Setup the view methods
    func fillTheFields(with note: SendToContactNote?) {
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
        
        let contactData = note!.contact!
        
        self.contactEntry = ContactEntry(name: contactData.firstName!,
                                         email: contactData.email,
                                         phone: contactData.phone,
                                         image: nil)
        if let imageData = contactData.photo {
            self.contactEntry!.image = UIImage(data: imageData as Data)
        }
        self.contactEntry!.surName = contactData.lastName
        self.fillContactFields(with: self.contactEntry!)
        
        let message = note!.message!.text
        self.messageTextView.text = message
    }
    
    private func fillContactFields(with contactEntry: ContactEntry) {
        let name = (contactEntry.name != nil) ? contactEntry.name : ""
        let surName = (contactEntry.surName != nil) ? contactEntry.surName : ""
        self.contactNameLabel.text = "\(name!) \(surName!)"
        self.emailTextField.text = (contactEntry.email != nil) ? contactEntry.email : ""
    }
    
    private func setMap(with placeMark: PlaceMark) {
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
    
    
    //MARK: - Other methods
    func presentAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Ok",
                                   style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
