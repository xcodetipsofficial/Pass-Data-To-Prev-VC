//
//  SecondViewController.swift
//  PassDataToNextVC
//
//  Created by Kyle Wilson on 2020-03-22.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit

protocol SecondViewControllerDelegate {
    func sendTicketAmount(tickets: Int, location: String)
}

class SecondViewController: UIViewController {
    
    @IBOutlet weak var numOfTickets: UILabel!
    var delegate: SecondViewControllerDelegate?
    @IBOutlet weak var ticketStepper: UIStepper!
    
    var retrievedPin = MKPointAnnotation()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        pin()
        geolocateLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let delegate = delegate {
            delegate.sendTicketAmount(tickets: Int(ticketStepper!.value), location: destinationLabel.text!)
        }
    }
    
    @IBAction func ticketStepperAction(_ sender: Any) {
        numOfTickets.text = String(Int(ticketStepper.value))
    }
    
    func pin() {
        let coordinate = CLLocationCoordinate2D(latitude: retrievedPin.coordinate.latitude, longitude: retrievedPin.coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        }
    }
    
    func geolocateLocation() {
        let coordinates = CLLocation(latitude: retrievedPin.coordinate.latitude, longitude: retrievedPin.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(coordinates) { (placemark, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "Location doesn't exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            var placeMark: CLPlacemark!
            placeMark = placemark?[0]
            
            self.destinationLabel.text = "\(placeMark.locality ?? "No City")\n\(placeMark.administrativeArea ?? "No State"), \(placeMark.country ?? "No Country")"
        }
    }
}

extension SecondViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
