//
//  GeopositionClass.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 26.12.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GeopositionClass: NSObject {

    var geocoder = CLGeocoder()
    var foundedPlaces = [PlaceMark]()
    

    func findPlacesByString( nameOfPlace : String, completionHandler: @escaping () -> Void) {
        /*self.geocoder.geocodeAddressString(nameOfPlace) { (placeMarks, error) in
            
            if placeMarks != nil && !placeMarks!.isEmpty && error == nil {
                self.foundedPlaces.removeAll()
                
                for item in placeMarks! {
                    let place = PlaceMark()
                    
                    let addressStringLines = item.addressDictionary![ "FormattedAddressLines" ]! as! NSArray
                    
                    for i in addressStringLines {
                        if place.textForTitle.length() > 0 {
                            place.textForTitle += ", "
                        }
                        place.textForTitle += i as! String
                    }
                    
                    if item.country != nil {
                        place.textForSubtitle = item.country!
                        place.latitude = ( item.location?.coordinate.latitude )!
                        place.longitude = ( item.location?.coordinate.longitude )!
                        self.foundedPlaces.append( place )
                    }
                    
                }
                completionHandler()
            }
            else if (placeMarks?.count == 0 || placeMarks == nil) && error == nil {
                print( "Found no placemarks" )
            }
            else if error != nil {
                print("An error occured")// + ( error)! )
            }
            
        }*/
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = nameOfPlace
//        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            let placeMarks = response.mapItems
            self.foundedPlaces = []
            for placeMark in placeMarks {
                let place = PlaceMark()
                let item = placeMark.placemark
                let addressStringLines = item.addressDictionary![ "FormattedAddressLines" ]! as! NSArray
                
                for i in addressStringLines {
                    if place.textForTitle.length() > 0 {
                        place.textForTitle += ", "
                    }
                    place.textForTitle += i as! String
                }
                
                if item.country != nil {
                    place.textForSubtitle = item.country!
                    place.latitude = ( item.location?.coordinate.latitude )!
                    place.longitude = ( item.location?.coordinate.longitude )!
                    self.foundedPlaces.append( place )
                }
                
            }
            search.cancel()
            completionHandler()
        }
    }
}
