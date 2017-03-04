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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        handle = self.auth?.addStateDidChangeListener() { (auth, user) in
            // ...
//            print(auth);
//            print(user);
            print("Login as \(user?.displayName)");
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
//        if (self.auth?.currentUser) != nil {
//            if tryLogOut {
//                do {
//                    try self.authUI?.signOut()
//                    self.showLoginView();
//                } catch let error {
//                    // Again, fatalError is not a graceful way to handle errors.
//                    // This error is most likely a network error, so retrying here
//                    // makes sense.
//                    fatalError("Could not sign out: \(error)")
//                }
//            }
//        } else {
//            self.showLoginView();
//        }
        if self.auth?.currentUser == nil {
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
                    if let photoConfirmView = self.storyboard?.instantiateViewController(withIdentifier: "PhotoConfirmViewController") as? PhotoConfirmViewController {
                        photoConfirmView.image = selectedImage;
                        photoConfirmView.userID = currentUser.uid;
                        self.navigationController?.pushViewController(photoConfirmView, animated: false);
                        self.dismiss(animated: true, completion: nil);
                    }

                }
            };
            
            self.present(imagePicker, animated: true, completion: nil);
        }
    }

}

