//
//  GeoPositionViewController.swift
//  Reminder
//
//  Created by Ruzhin Alexey on 17.07.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit

class GeoPositionViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate
{
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var isArriveSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var radiusStepper: UIStepper!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var slider: UISlider!
    
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        let radius = Float(self.radiusStepper.value)
        self.radiusTextField.text = "\(radius)"
        self.slider.value = radius
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        let radius = self.slider.value
        self.radiusTextField.text = "\(radius)"
        self.radiusStepper.value = Double(radius)
    }
    @IBAction func radiusTextFieldValueChanged(_ sender: Any) {
        let radius = Float(self.radiusTextField.text!)!
        self.slider.value = radius
        self.radiusStepper.value = Double(radius)
    }
    
    func changeOverlayRadius(radius: Float) {
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.addOverlay(with: radius)
    }
    
    func addOverlay(with radius: Float) {
        
    }
    
    // MARK: - Properties
    let cellIdentifier = "placemarksCell"
    let geoposition = GeopositionClass()

    var placeMark: PlaceMark? = nil
    
    var tableMustBeEmpty = true
    var countForTableView: Int {
        get {
            if tableMustBeEmpty {
                return 0
            }
            else {
                return self.geoposition.foundedPlaces.count + 1
            }
        }
    }
    
    var complition: ((PlaceMark) -> Void)?
    var getPlaceMark: (() -> PlaceMark?)?
    
    // MARK: - Override View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeMark = self.getPlaceMark!()
        if self.placeMark != nil {
            let location = CLLocationCoordinate2D(latitude: self.placeMark!.latitude, longitude: self.placeMark!.longitude)
            self.addAnnotation(with: location, animated: false)
            self.searchBar.text = self.placeMark!.textForTitle
            self.isArriveSegmentedControl.selectedSegmentIndex = (!placeMark!.isArrive).hashValue
        }
        
        let radius = Float(self.radiusTextField.text!)!
        self.slider.value = radius
        self.radiusStepper.value = Double(radius)
        
    }
    
    
    // MARK: - UINavigationItem
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIBarButtonItem) {
        if self.placeMark != nil {
            let bool = Bool.init(NSNumber.init(value: self.isArriveSegmentedControl.selectedSegmentIndex))
            self.placeMark!.isArrive = !bool
            complition!(self.placeMark!)
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    
    // MARK: - UITableViewDataSourse
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        return self.countForTableView
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell( withIdentifier: cellIdentifier, for: indexPath as IndexPath )
        let image: UIImage!
        if indexPath.row == 0 {
            image = UIImage(named: "location")
            cell.textLabel?.text = "Current Location"
        }
        else {
            image = UIImage(named: "markLocation")
            let indexForArray = indexPath.row - 1
            cell.textLabel?.text = (geoposition.foundedPlaces[indexForArray]).textForTitle
            cell.detailTextLabel?.text = (geoposition.foundedPlaces[indexForArray]).textForSubtitle
        }
        cell.imageView?.image = image
        return cell
    }
   
    
    // MARK: - UITableViewDelegate
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        searchBar.showsCancelButton = false
        self.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        var location: CLLocationCoordinate2D!
        if indexPath.row == 0 {
            if self.mapView.userLocation.location == nil {
                return
            }
            
            location = self.mapView.userLocation.location?.coordinate
            self.placeMark = PlaceMark()
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(self.mapView.userLocation.location!, completionHandler: { (placeMarks, nil) in
                if placeMarks == nil || placeMarks?.count == 0 {
                    return
                }
                let item = placeMarks![0]
                self.placeMark!.latitude = location.latitude
                self.placeMark!.longitude = location.longitude
                
                let addressStringLines = item.addressDictionary![ "FormattedAddressLines" ]! as! NSArray
                
                for i in 0 ..< addressStringLines.count {
                    if i < addressStringLines.count - 2 {
                        continue
                    }
                    let string = addressStringLines[i] as! String
                    if self.placeMark!.textForTitle.length() > 0 {
                        self.placeMark!.textForTitle += ", "
                    }
                    self.placeMark!.textForTitle += string
                }
                self.searchBar.text = self.placeMark!.textForTitle
                if item.country != nil {
                    self.placeMark!.textForSubtitle = item.country!
                }
                let animated = !self.mapView.dataLoading
                self.addAnnotation(with: location, animated: animated)
            })
        }
        else {
            self.searchBar.text = tableView.cellForRow( at: indexPath as IndexPath )?.textLabel?.text
            let indexForArray = indexPath.row - 1
            self.placeMark = geoposition.foundedPlaces[indexForArray]
            location = CLLocationCoordinate2D( latitude: self.placeMark!.latitude, longitude: self.placeMark!.longitude )
            self.addAnnotation(with: location, animated: true)
        }
        
        self.tableView.beginUpdates()
        self.tableMustBeEmpty = true
        let indexPathes = self.getIndexPathesForAllRows(in: indexPath.section)
        self.tableView.deleteRows(at: indexPathes, with: .top)
        self.tableView.endUpdates()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        self.tableView.beginUpdates()
        self.tableMustBeEmpty = true
        let indexPathes = self.getIndexPathesForAllRows(in: 0)
        self.tableView.deleteRows(at: indexPathes, with: .top)
        self.geoposition.foundedPlaces = []
        self.tableView.endUpdates()
    }
    
    func addAnnotation(with location: CLLocationCoordinate2D, animated: Bool) {
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake( 0.1 , 0.1 )
        let theRegion = MKCoordinateRegionMake( location, theSpan )
        self.mapView.setRegion( theRegion, animated: animated )
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = self.placeMark!.textForTitle//"The Location"
        anotation.subtitle = self.placeMark!.textForSubtitle//"This is the location !!!"
        self.mapView.addAnnotation(anotation)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Begin")
        searchBar.showsCancelButton = true
        if self.tableMustBeEmpty {
            self.tableView.beginUpdates()
            self.tableMustBeEmpty = false
            self.geoposition.foundedPlaces = []
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
            self.tableView.endUpdates()
            geoposition.findPlacesByString(nameOfPlace: searchBar.text!) {
                self.tableView.beginUpdates()
                var indexPathes = [IndexPath]()
                for i in 0 ..< self.geoposition.foundedPlaces.count {
                    let indexPath = IndexPath(row: i+1, section: indexPath.section)
                    indexPathes.append(indexPath)
                }
                self.tableView.insertRows(at: indexPathes, with: .top)
                self.tableView.endUpdates()
            }
            
            
        }
    }
    
    func searchBar( _ searchBar: UISearchBar, textDidChange searchText: String ) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        if searchText.isEmpty {
            return
        }
        geoposition.findPlacesByString(nameOfPlace: searchText) {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Generic Methods
    func getIndexPathesForAllRows(in section: Int) -> [IndexPath] {
        var indexPathes = [IndexPath]()
        let numberOfRows = self.tableView.numberOfRows(inSection: section)
        for i in 0 ..< numberOfRows {
            let indexPath = IndexPath(row: i, section: section)
            indexPathes.append(indexPath)
        }
        return indexPathes
    }
    
}
