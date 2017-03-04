//
//  FoodLocation.swift
//  FoodSwift
//
//  Created by NiM on 3/4/2560 BE.
//  Copyright © 2560 tryswift. All rights reserved.
//

import UIKit
import CoreLocation

class FoodLocation: NSObject, CLLocationManagerDelegate {
    
    static let defaultManager = FoodLocation();
    
    typealias LocationDidGetPlaceBlock = (CLPlacemark) -> Void
    
    //Location
    let locationManager = CLLocationManager();
    let geoCoder = CLGeocoder();
    var currentLocation:CLLocationCoordinate2D?;
    var currentPlace:CLPlacemark?
    
    private var locationBlock:LocationDidGetPlaceBlock?;
    
    override init() {
        super.init();
        self.locationManager.delegate = self;
    }

    func requestLocation(completion:LocationDidGetPlaceBlock?) {
        self.locationBlock = completion;
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation();
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.requestLocation(completion: self.locationBlock);
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            if let location = locations.last {
                self.currentLocation = location.coordinate;
                self.geoCoder.cancelGeocode();
                self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    if let completion = self.locationBlock {
                        if let place = placemarks?.last {
                            self.currentPlace = place;
                            completion(place);
                        }
                    }
                })
                self.locationManager.stopUpdatingLocation();
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Cannot get location");
    }
}
