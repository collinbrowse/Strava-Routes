//
//  ViewController.swift
//  MapKitTestProject
//
//  Created by Collin Browse on 8/18/20.
//  Copyright © 2020 Collin Browse. All rights reserved.
//
//
/*

 
 
 
 
 
 
 */



import UIKit
import MapKit

class ViewController: UIViewController {

    var trails = [Trail]()
    var trail = Trail()
    var foundCharacters : String = ""
    let mapView = TrailsMapView()
    let bottomSheet = UIView()
    var trailsTableView = TrailsTableView()
    var bottomSheetHeightConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseGPX()
        addAnnotations()
        setUpBottomSheet()
        layoutTrailsTableView()
        layoutMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            bottomSheetHeightConstraint?.constant = 125
        } else {
            bottomSheetHeightConstraint?.constant = 250
        }
    }

    // All GPX files have already been parsed and added to trails
    // For each trail plot the polyline on the map view.
    // Then take the GPX file's name and add that as an annotation to the approximate center of the trail
    func addAnnotations() {
        for trail in trails {
            let polyline = MKPolyline(coordinates: trail.coordinates, count: trail.coordinates.count)
            mapView.addOverlay(polyline)
            addCustomAnnotation(name: trail.name, coordinate: polyline.coordinate)
        }
        guard let firstTrail = trails.first else { return }
        let polyline = MKPolyline(coordinates: firstTrail.coordinates, count: firstTrail.coordinates.count)
        zoomToPolyline(polyline: polyline)
    }
    
    
    func zoomToPolyline(polyline: MKPolyline) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: false)
    }

    
    func addCustomAnnotation(name: String, coordinate: CLLocationCoordinate2D) {
        let customAnnotation = CustomAnnotation(title: name, coordinate: coordinate)
        mapView.addAnnotation(customAnnotation)
    }
    
    
    func layoutMapView() {
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomSheet.topAnchor)
        ])
    }
    
    
    func setUpBottomSheet() {
        view.addSubview(bottomSheet)
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        bottomSheetHeightConstraint = bottomSheet.heightAnchor.constraint(equalToConstant: 150)
        bottomSheetHeightConstraint?.isActive = true
    }
    
    
    func layoutTrailsTableView() {
        trailsTableView.trailDelegate = self
        bottomSheet.addSubview(trailsTableView)
        NSLayoutConstraint.activate([
            trailsTableView.topAnchor.constraint(equalTo: bottomSheet.topAnchor),
            trailsTableView.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor),
            trailsTableView.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor),
            trailsTableView.bottomAnchor.constraint(equalTo: bottomSheet.bottomAnchor)
        ])
    }
}


extension ViewController : TrailsTableViewDelegate {
    
    
    func didTapTrail(trail: Trail) {
        let polyline = MKPolyline(coordinates: trail.coordinates, count: trail.coordinates.count)
        zoomToPolyline(polyline: polyline)
    }
    
    
    func didTapGetDirections(trail: Trail) {
        guard let startOfTrail = trail.coordinates.first else { return }
        let mark = MKPlacemark(coordinate: startOfTrail)
        let destination = MKMapItem(placemark: mark)
        destination.name = trail.name
        
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        } else {
            alertStyle = UIAlertController.Style.actionSheet
        }
        let actionSheet = UIAlertController(title: "Select an app for directions", message: nil, preferredStyle: alertStyle)
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
            guard let url = URL(string: self.constructGoogleURL(coordinate: startOfTrail)) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(appleMapsAction)
        actionSheet.addAction(googleMapsAction)
        actionSheet.addAction(dismissAction)
        
        present(actionSheet, animated: true)
    }
    
    
    func constructGoogleURL(coordinate: CLLocationCoordinate2D) -> String {
        var googleURL = "https://www.google.com/maps/dir/?api=1&destination="
        googleURL += "\(coordinate.latitude)"
        googleURL += ","
        googleURL += "\(coordinate.longitude)"
        googleURL += "&travelmode=driving"
        googleURL += "&basemap=terrain"
        return googleURL
    }
}


extension ViewController: XMLParserDelegate {
    
    func parseGPX() {
        
        guard let paths = Bundle.main.urls(forResourcesWithExtension: "gpx", subdirectory: "GPXFiles") else {
            print("Couldn't get paths")
            return
        }
        for path in paths {
            let parser = XMLParser(contentsOf: path)
            parser?.delegate = self
            let didParse = parser?.parse()
            if !(didParse ?? true) {
                print("Failed to parse gpx file")
            }
        }

        trailsTableView.reloadData()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    
        if elementName == "trkpt" || elementName == "wpt" {
            
            if let lat = CLLocationDegrees(attributeDict["lat"]!), let lon = CLLocationDegrees(attributeDict["lon"]!) {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                trail.coordinates.append(coordinate)
            }
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "name" {
            trail.name = foundCharacters.replacingOccurrences(of: "\n ", with: "")
        }
        
        self.foundCharacters = ""
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        trails.append(trail)
        trailsTableView.setTrails(trails: trails)
        trail = Trail()
    }
}
