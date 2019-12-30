//
//  ViewController.swift
//  myMaps
//
//  Created by Bharat shankar on 16/09/19.
//  Copyright © 2019 Bharat. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate, GMSMapViewDelegate{

    @IBOutlet var confirmLocationBtn: UIButton!
    @IBOutlet var setServiceLocationStaticLabel: UILabel!
    @IBOutlet var locationView: UIView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var addressTV: UITextView!
    
    var checkStr : String?
    
    //for map
    var streetAddress : String! = ""
    var addressStr : String! = ""
    var latitudeString : String! = ""
    var longitudeString : String! = ""
    
    var currentLocation:CLLocationCoordinate2D!
    
    lazy var locationManager: CLLocationManager = {
        
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.mapView.isMyLocationEnabled = true
        self.mapView.delegate = self
        
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showUpdatedValueOnMap(_:)), name: NSNotification.Name(rawValue:"showUpdatedValueOnMap"), object: nil)
        
        isAuthorizedtoGetUserLocation()
        // Do any additional setup after loading the view.
    }
    
    @objc func showUpdatedValueOnMap(_ notification: NSNotification){
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            latitudeString = dict["lat"] as? String
            longitudeString = dict["lang"] as? String
            addressStr = dict["address"] as? String
            print("latitudeString",latitudeString)
            print("longitudeString",longitudeString)
            print("addressStr",addressStr)
        }
        
        self.addressTV.text = addressStr
    }
    
    func isAuthorizedtoGetUserLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.locationManager.requestWhenInUseAuthorization()
            self.isAuthorizedtoGetUserLocation()
        
    }
    
    
    @IBAction func btn_ConfirmLocation(_ sender: UIButton) {
        
        ////  commented on march 20  NotificationCenter.default.post(name: Notification.Name("pushView5"), object: nil)
        
        let imageDataDict:[String: String] = ["key": latitudeString,"key1":longitudeString,"key2":self.addressTV.text!]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getLocation"), object: nil, userInfo: imageDataDict)
        
        self.dismiss(animated: true) {
            print("dismmissed")
        }
     
    }
    
    @IBAction func showCurrentLocationAction(_ sender: Any) {
        latitudeString = ""
        
            self.isAuthorizedtoGetUserLocation()
        
    }
    
    //for map
    
    func wrapperFunctionToShowPosition(mapView:GMSMapView){
        
       
        
        let geocoder = GMSGeocoder()
        
        let latitud = mapView.camera.target.latitude
        let longitud = mapView.camera.target.longitude
        
        self.latitudeString = String(format: "%.8f", mapView.camera.target.latitude)
        self.longitudeString = String(format: "%.8f", mapView.camera.target.longitude)
        let position = CLLocationCoordinate2DMake( latitud, longitud)
        
       
        
        geocoder.reverseGeocodeCoordinate(position) { response , error in
            if error != nil {
                // print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
            }else {
                guard let result = response?.results()?.first else {
                    return
                }
                print("adress of that location is \(result)")
                self.addressStr = result.lines?.reduce("") { $0 == "" ? $1 : $0 + ", " + $1 }
               
                print("Address Str Is :\(self.addressStr ?? "")")
               
                DispatchQueue.main.async {
                    self.addressTV.text = self.addressStr
                    
                }
            }
        }
        
    }
    
    //MARK:mapview delegate methods
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("didchange")
        //called everytime
        wrapperFunctionToShowPosition(mapView: mapView)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idleAt")
        wrapperFunctionToShowPosition(mapView: mapView)
    }
    
    //MARK:DID UPDATE LOCATIONS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didupdate location")
       
        
        if latitudeString == ""{
            print("latitudeString is empty")
            let userLocation:CLLocation = locations[0] as CLLocation
            self.currentLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
            let camera = GMSCameraPosition.camera(withLatitude: self.currentLocation.latitude, longitude:currentLocation.longitude, zoom: 15)
            let position = CLLocationCoordinate2D(latitude:  currentLocation.latitude, longitude: currentLocation.longitude)
            print(position)
            DispatchQueue.main.async {
                
                self.mapView.camera = camera
            }
            self.mapView?.animate(to: camera)
            // manager.stopUpdatingLocation()
        }
        else{
            print("latitudeString is not empty")
            let latitud = Double(self.latitudeString ?? "") ?? 0.0
            let longitud = Double(self.longitudeString ?? "") ?? 0.0
            let camera = GMSCameraPosition.camera(withLatitude: latitud, longitude:longitud, zoom: 15)
            let position = CLLocationCoordinate2D(latitude:  latitud, longitude: longitud)
            print(position)
            DispatchQueue.main.async {
                
                self.mapView.camera = camera
            }
            self.mapView?.animate(to: camera)
            // manager.stopUpdatingLocation()
        }
        manager.stopUpdatingLocation()
    }


}
