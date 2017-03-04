//
//  ViewController.swift
//  FoodSwift
//
//  Created by NiM on 3/4/2560 BE.
//  Copyright © 2560 tryswift. All rights reserved.
//

import UIKit
import Koloda
import Alamofire
import AlamofireImage
import Firebase

let dirRef = FIRDatabase.database().reference(withPath: "food")

class ViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: CustomKolodaView!

    var foods: [Food] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dirRef.queryOrdered(byChild: "rate").observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            guard let dir = snapshot.value as? [String: Any] else {
                return
            }
            
            for key in dir.keys {
                guard let json = dir[key] as? [String:Any] else { return }
                let food = Food(JSON: json)
                self.foods.append(food!)
            }
            self.kolodaView.reloadData()
        })
        
/*        let food = Food()
        food.g = "w4rqpsh8de"
        food.imageURL = "https://firebasestorage.googleapis.com/v0/b/foodswift-fa506.appspot.com/o/food2.jpg?alt=media&token=2568a669-05b8-4d99-9423-b569497c87f0"
        
        let food2 = Food()
        food2.g = "w4rqpsh8de"
        food2.imageURL = "https://firebasestorage.googleapis.com/v0/b/foodswift-fa506.appspot.com/o/food2.jpg?alt=media&token=2568a669-05b8-4d99-9423-b569497c87f0"        
        foods += [food, food2]*/
        
//        imageView.af_setImage(withURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/foodswift-fa506.appspot.com/o/food2.jpg?alt=media&token=2568a669-05b8-4d99-9423-b569497c87f0")!)
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapLeftButton() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func tapRightButton() {
        kolodaView?.swipe(.right)
    }

}


extension ViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
//        foods.reset()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {
//        UIApplication.shared.openURL(NSURL(string: "https://yalantis.com/")! as URL)
    }
}

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
