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
import Koloda
import Alamofire
import AlamofireImage
import CoreLocation
import GeoFire

let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!

enum UpdateRateType {
    case increment
    case decrement
}

class ViewController: UIViewController {

    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var shopNameLabel: UILabel!
    var foods: [Food] = []
    
    var auth: FIRAuth?;// = FIRAuth.auth()
    var authUI: FUIAuth? ;//= FUIAuth.defaultAuthUI()
    var handle: FIRAuthStateDidChangeListenerHandle?
    var tryLogOut = true;
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.auth = FIRAuth.auth();
        self.authUI = FUIAuth.defaultAuthUI();
        
        self.authUI?.tosurl = kFirebaseTermsOfService
        self.authUI?.isSignInWithEmailHidden = true;
        self.authUI?.providers = [FUIFacebookAuth()];
        
        ref = FIRDatabase.database().reference(withPath: "food")
        
        kolodaView.dataSource = self
        kolodaView.delegate = self        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: "addNewPost:");
        self.title = "food! Swift";
        
        self.requestLocation();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        handle = self.auth?.addStateDidChangeListener() { [unowned self] (auth, user) in
            self.fetchFood()
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

    @IBAction func tapLeftButton() {
        updateRate(uid: foods[kolodaView.currentCardIndex].uid, type: .decrement)
        kolodaView?.swipe(.left)
    }
    
    @IBAction func tapRightButton() {
        updateRate(uid: foods[kolodaView.currentCardIndex].uid, type: .increment)
        kolodaView?.swipe(.right)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSegue" {
            
        }
    }
    
    // MARK: - private
    
    private func fetchFood() {
        ref.queryOrdered(byChild: "rate").observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            guard let dir = snapshot.value as? [String: Any] else {
                return
            }
            
            for key in dir.keys {
                guard let json = dir[key] as? [String:Any] else { return }
                if var food = Food(JSON: json) {
                    food.uid = key
                    self.foods.append(food)
                }
            }
            self.kolodaView.reloadData()
        })
    }
    
    private func updateRate(uid: String, type: UpdateRateType) {
        ref.runTransactionBlock { (currentData) -> FIRTransactionResult in
            guard var foods = currentData.value as? [String: Any],
                var food = foods[uid] as? [String: Any]
                else { return FIRTransactionResult.success(withValue: currentData) }
            
            var rate = food["rate"] as? Int ?? 0
            switch type {
            case .increment: rate += 1
            case .decrement: rate -= 1
            }
            food["rate"] = rate
            foods[uid] = food
            currentData.value = foods
            
            return FIRTransactionResult.success(withValue: currentData)
        }
    }
}

// MARK: - KolodaViewDelegate

extension ViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        performSegue(withIdentifier: "ShowMap", sender: nil)
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        let food = foods[index]
        shopNameLabel.text = food.place
        print("uid:\(food.uid) \(food.place)")
        
/*        let location = CLLocation(latitude: food.location![0], longitude: food.location![1])
        CLGeocoder().reverseGeocodeLocation(location) { [unowned self] (placemark, error) in
            var location = ""
            defer {
                self.locationLabel.text = location
            }
            if error != nil { return }
            
            if let placemark = placemark, placemark.count > 0 {
                location = placemark[0].locality ?? ""
            }
        }*/
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

// MARK: - KolodaViewDataSource

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return foods.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIImageView()
        let urlString = foods[index].imageURL
        view.af_setImage(withURL: URL(string: urlString)!)
        return view
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
}
