//
//  ViewController.swift
//  FoodSwift
//
//  Created by NiM on 3/4/2560 BE.
//  Copyright © 2560 tryswift. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFacebookAuthUI
import GeoFire

let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!

class ViewController: UIViewController {

    var auth: FIRAuth?;// = FIRAuth.auth()
    var authUI: FUIAuth? ;//= FUIAuth.defaultAuthUI()
    var handle: FIRAuthStateDidChangeListenerHandle?
    var tryLogOut = true;    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.auth = FIRAuth.auth();
        self.authUI = FUIAuth.defaultAuthUI();
        
        self.authUI?.tosurl = kFirebaseTermsOfService
        self.authUI?.isSignInWithEmailHidden = true;
        self.authUI?.providers = [FUIFacebookAuth()];
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        
        self.requestLocation();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        handle = self.auth?.addStateDidChangeListener() { (auth, user) in
            print("Login as \(user?.displayName)");
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if self.auth?.currentUser == nil {
            self.showLoginView();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 35.6942891, 139.7649778
    
    // MARK:
    // MARK: New post

    @IBAction func addNewPost(_ sender: Any) {
        if let currentUser = self.auth?.currentUser {
            if let currentLocation = FoodLocation.defaultManager.currentLocation {
                let imagePicker = FoodPhoto.imagePickerViewController { (image, error) in
                    if let selectedImage = image {
                        if let photoConfirmView = self.storyboard?.instantiateViewController(withIdentifier: "PhotoConfirmViewController") as? PhotoConfirmViewController {
                            photoConfirmView.image = selectedImage;
                            photoConfirmView.userID = currentUser.uid;
                            photoConfirmView.location = currentLocation;
                            self.navigationController?.pushViewController(photoConfirmView, animated: false);
                            self.dismiss(animated: true, completion: nil);
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil);
                    }
                };
                
                self.present(imagePicker, animated: true, completion: nil);
            }
        }
    }

    // MARK:
    // MARK: Authentication

    func showLoginView() {
        tryLogOut = false;
        
        let controller = self.authUI!.authViewController()
        //        controller.navigationBar.isHidden = self.customAuthorizationSwitch.isOn
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK:
    // MARK: Location
    
    func requestLocation() {
        FoodLocation.defaultManager.requestLocation { (place) in
            print("You are near \(place)");
            
            let geofireRef = FIRDatabase.database().reference().child("location")
            let geoFire = GeoFire(firebaseRef: geofireRef)!
            
            if let currentLocation = FoodLocation.defaultManager.currentLocation {
                let center = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                let circleQuery = geoFire.query(at: center, withRadius: 1000)
                
                circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
                    print("\(key) ===== \(location?.coordinate.latitude), \(location?.coordinate.longitude)")
                })
            }
        }
    }
}

