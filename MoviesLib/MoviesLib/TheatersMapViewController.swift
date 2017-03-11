//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit // It already has CoreLocation framework/lib

class TheatersMapViewController: UIViewController {
    
    // MARK: - Properties
    var elementName: String! // Sabemos qual elemento está na linha que está sendo lida
    var theater: Theater!
    var theaters: [Theater] = []
    
    // Beacons are not fixed meanwhile the other one is
    lazy var locationManager = CLLocationManager() // lazy cause until it's intanciated it's not initialized
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.showsUserLocation = true

        // Do any additional setup after loading the view.
        requestLocation()
        loadXML()
    }
    
    // MARK: - Methods
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                // Already authorized
                monitorUserLocation()
                
            case .notDetermined:
                print("Still not authorized")
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                // Not authorized
                print("Denied")
            case .restricted:
                // I.e. doctors usage; when something on the device blocks this location use
                print("Restricted")
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadXML() {
        // Vamos garantir que não será nulo. ex: nome errado de arquivo
        // e criar parser
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser = XMLParser(contentsOf: xmlURL) {
            
            // XML content already gotten
            // In here we already have the XML File content
            
            // Let's parse it
            // Define who is its delegate
            // And implement XML deletage protocol
            xmlParser.delegate = self
            xmlParser.parse()
            
        }
    }
    
    func addViewersToMap() {
        for theater in theaters {
            // Define where pin is gonna appear on the map: by coordinate
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            // Pins == Annotations
            // let annotation = MKPointAnnotation()
            let annotation = TheaterAnnotation(coordinate: coordinate)
            annotation.coordinate = coordinate
            annotation.title = theater.name
            annotation.subtitle = theater.address
            mapView.addAnnotation(annotation)
        }
        
        // Set map's zoom - -23.562993, -46.652734
        
        // Define region to be shown
        
        // EITHER this way
        
        /*
        let region = MKCoordinateRegionMakeWithDistance(
            CLLocationCoordinate2D(latitude: -23.562993,
                                   longitude: -46.652734), 1000, 1000)
        
        mapView.setRegion(region, animated: true)
        */
        
        // OR this way
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func monitorUserLocation() {
        locationManager.startUpdatingLocation()
        // locationManager.stopUpdatingLocation()
    }

}

// MARK: - XMLParserDelegate

extension TheatersMapViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("Start", elementName)
        self.elementName = elementName
        
        if elementName == "Theater" {
            theater = Theater()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // print("Content", string)
        
        // Remove blank spaces
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty {
            print("Content", content)
            
            switch elementName {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)
            case "longitude":
                theater.longitude = Double(content)
            case "url":
                theater.url = content
            default:
                break // We do not want to do anything in this moment right now
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("End", elementName)
        
        if elementName == "Theater" {
            theaters.append(theater)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        addViewersToMap()
    }
}

// MARK: - MKMapViewDelegate
extension TheatersMapViewController: MKMapViewDelegate {
    
    // Update Icon's attributes
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView!
        
        if annotation is MKPinAnnotationView {
            // Lets reuse like swift usually does
            
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "TheaterPin") as! MKPinAnnotationView
            
            // It's is possible not exists
            // EITHER update an existing one:
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TheaterPin")
                (annotationView as! MKPinAnnotationView).pinTintColor = .blue
                (annotationView as! MKPinAnnotationView).animatesDrop = true
                (annotationView as! MKPinAnnotationView).canShowCallout = true // Show box when pin is clicked
            } else {
                annotationView?.annotation = annotation
            }
        } else if annotation is TheaterAnnotation {
            annotationView = (annotation as! TheaterAnnotation).getAnnotationView()
        }
        
        
        // OR creating a custom one
        
        
        return annotationView
        
    }
}

// MARK: - CLLocationManager
extension TheatersMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorized")
            monitorUserLocation()
        default:
            break
        }
    }
    
    // Every single moment that user location has changed
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("User Location", userLocation.location!.speed)
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        
        // Update user's pin location
        mapView.setRegion(region, animated: true)
    }
}













