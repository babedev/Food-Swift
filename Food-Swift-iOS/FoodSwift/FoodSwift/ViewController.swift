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
