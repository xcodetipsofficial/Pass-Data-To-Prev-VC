//
//  ViewController.swift
//  PassDataToNextVC
//
//  Created by Kyle Wilson on 2020-03-22.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, SecondViewControllerDelegate {
    
    func sendTicketAmount(tickets: Int, location: String) {
        print(tickets)
        if tickets > 0 {
            let bookedAlert = UIAlertController(title: "Booked!", message: "You have booked \(tickets) tickets to \(location)", preferredStyle: .alert)
            bookedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(bookedAlert, animated: true)
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    let newPin = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        view.addGestureRecognizer(longTapGesture)
    }
    
    @objc func longTap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            self.mapView.removeAnnotation(newPin)
            let location = sender.location(in: self.mapView)
            let locationOnMap = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            let coordinate = CLLocationCoordinate2D(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            
            newPin.coordinate = coordinate
            mapView.addAnnotation(newPin)
            
            self.mapView.addAnnotation(newPin)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SecondViewController {
            let vc = segue.destination as? SecondViewController
            vc?.retrievedPin = newPin
            vc?.delegate = self
        }
    }
    
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .black
            pinView?.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "segue", sender: newPin)
    }
}

