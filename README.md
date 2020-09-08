# Strava-Routes

## Summary
Strava-Routes is a personal project designed to teach me the MapKit Framework. The app parses and displays routes from GPX files that are included in the app bundle. To navigate between routes the user can select on one from the bottom sheet. To get directions to the trailhead tap on the detail button and select either Apple Maps or Google Maps. 

## Development

To create Strava Routes I:

* Loaded my personal GPX files from Strava into my app bundle
* Parsed the necessary information from each file (GPS Coordinates and File Name) using XMLParser, part of the Foundation Framework
* Plotted the coordinates from each trail as an MKPolyline on an MKMapView Instance.
* Plotted the name of the route as an MKAnnotation at the center of the MKPolyline
* Added a UITableView so you can move conveniently between routes.
* Coded functionality to a Detail Button for each cell so the user can get directions to the trailhead through either Apple Maps or Google Maps

![alt text](https://raw.githubusercontent.com/collinbrowse/Strava-Routes/master/MapKitTestProject/Support/Assets.xcassets/iPhone_11_Mockup.png)
