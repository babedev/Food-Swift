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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        handle = self.auth?.addStateDidChangeListener() { (auth, user) in
            // ...
//            print(auth);
//            print(user);
            print("Login as \(user?.displayName)");
        }
        
//        let geofireRef = FIRDatabase.database().reference()
//        let geoFire = GeoFire(firebaseRef: geofireRef)!
//        
//        let center = CLLocation(latitude: 35.6930883, longitude: 139.7659818)
//        let circleQuery = geoFire.query(at: center, withRadius: 100)
//        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
//            print("\(location?.coordinate.latitude), \(location?.coordinate.longitude)")
//        })
//        
        //        geoFire.getLocationForKey("food", withCallback: { (location, error) in
        //            if (error != nil) {
        //                print("An error occurred getting the location for \"firebase-hq\": \(error?.localizedDescription)")
        //            } else if (location != nil) {
        //                print("Location for \"firebase-hq\" is [\(location?.coordinate.latitude), \(location?.coordinate.longitude)]")
        //            } else {
        //                print("GeoFire does not contain a location for \"firebase-hq\"")
        //            }
        //        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if (self.auth?.currentUser) != nil {
            if tryLogOut {
                do {
                    try self.authUI?.signOut()
                    self.showLoginView();
                } catch let error {
                    // Again, fatalError is not a graceful way to handle errors.
                    // This error is most likely a network error, so retrying here
                    // makes sense.
                    fatalError("Could not sign out: \(error)")
                }
            }
        } else {
            self.showLoginView();
        }
    }
    
    func showLoginView() {
        tryLogOut = false;
        
        let controller = self.authUI!.authViewController()
        //        controller.navigationBar.isHidden = self.customAuthorizationSwitch.isOn
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addNewPost(_ sender: Any) {
        if let currentUser = self.auth?.currentUser {
            let imagePicker = FoodPhoto.imagePickerViewController { (image, error) in
                if let selectedImage = image {
                    print("Start upload");
                    FoodPhoto.uploadImage(image: selectedImage, completion: { (url, error) in
                        print("Finish upload");
                        if let photoURL = url {
                            print("Got url \(photoURL)");
                            FoodPhoto.addNewPost(
                                imageURL: photoURL,
                                location: "" as AnyObject,
                                placeName: "五ノ神水産",
                                userID: currentUser.uid,
                                completion: { Void in
                                    self.dismiss(animated: true, completion: nil);
                                }
                            );
                        } else {
                            print("Finish upload with error - \(error)");
                        }
                    })
                }
            };
            
            self.present(imagePicker, animated: true, completion: nil);
        }
    }

}

