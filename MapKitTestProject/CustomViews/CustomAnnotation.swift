//
//  CustomAnnotation.swift
//  MapKitTestProject
//
//  Created by Collin Browse on 8/19/20.
//  Copyright © 2020 Collin Browse. All rights reserved.
//

import Foundation
import MapKit


class CustomAnnotation: NSObject, MKAnnotation {
    
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String? = "", coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
