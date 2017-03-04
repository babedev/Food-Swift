//
//  PhotoConfirmViewController.swift
//  FoodSwift
//
//  Created by NiM on 3/4/2560 BE.
//  Copyright © 2560 tryswift. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD

class PhotoConfirmViewController: UIViewController {
    var image:UIImage?
    var userID = "";
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = self.image;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendPhoto() {
        if let selectedImage = self.image {
            print("Start upload");
            SVProgressHUD.show();
            FoodPhoto.uploadImage(image: selectedImage, completion: { (url, error) in
                SVProgressHUD.dismiss();
                print("Finish upload");
                if let photoURL = url {
                    print("Got url \(photoURL)");
                    FoodPhoto.addNewPost(
                        imageURL: photoURL,
                        location: "" as AnyObject,
                        placeName: "五ノ神水産",
                        userID: self.userID,
                        completion: { Void in
                            self.dismiss(animated: true, completion: nil);
                    }
                    );
                } else {
                    print("Finish upload with error - \(error)");
                }
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
