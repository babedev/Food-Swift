//
//  Food.swift
//  FoodSwift
//
//  Created by Kazuki Yamamoto on 2017/03/04.
//  Copyright © 2017年 tryswift. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

struct Food: Mappable {
    
    var g: String = ""
    var imageURL: String = ""
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var place: String = ""
    var rate: Int = 0
    
    public init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        g <- map["g"]
        imageURL <- map["imageURL"]
        location <- map["l"]
        place <- map["place"]
        rate <- map["rate"]        
    }
    
    
}
