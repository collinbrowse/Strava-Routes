//
//  MapView.swift
//  MapKitTestProject
//
//  Created by Collin Browse on 9/7/20.
//  Copyright © 2020 Collin Browse. All rights reserved.
//

import UIKit
import MapKit

class TrailsMapView: MKMapView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpMapView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpMapView() {
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        showsScale = true
        showsCompass = true
    }
        
}


extension TrailsMapView: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
        annotationView?.setSelected(true, animated: false)
        
        let labelText = annotation.title!
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        let labelSize = labelText!.size(withAttributes: fontAttributes)
        
        let view = UIView(frame: CGRect(x: -50, y: 0, width: labelSize.width, height: labelSize.height))
        view.backgroundColor = .clear
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height))
        label.text = labelText
        label.backgroundColor = .clear
        
        view.addSubview(label)
        annotationView?.addSubview(view)
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .orange
            renderer.lineWidth = 2
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let annotations = mapView.annotations
        for annotation in annotations {
            if (region.span.latitudeDelta > 0.3) {
                view(for: annotation)?.isHidden = true
            } else {
                view(for: annotation)?.isHidden = false
            }
        }

    }
    
}
