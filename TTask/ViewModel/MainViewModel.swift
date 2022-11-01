//
//  MainViewModel.swift
//  TTask
//
//  Created by Nuno Ferro on 31/10/2022.
//

import Foundation
import CoreLocation

class MainViewModel: NSObject,CLLocationManagerDelegate, ObservableObject {
    
    @Published var fence = "IN"
    
    private let locationManager = CLLocationManager()
    var geofenceRegion = CLCircularRegion()
    var geofenceRegionCenterCoordinate = kCLLocationCoordinate2DInvalid
    
    func setupGeoFence() {
        geofenceRegion = CLCircularRegion (
            center: geofenceRegionCenterCoordinate,
            radius: 50,
            identifier: UUID().uuidString
        )
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        fence = "OUT"
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        fence = "IN"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            // kCLLocationCoordinate2DInvalid have -180.0 latitude and longitude
            guard geofenceRegionCenterCoordinate.latitude == -180.0 else { return }
            guard $0.horizontalAccuracy < 20 else { return }
            
            geofenceRegionCenterCoordinate.latitude = $0.coordinate.latitude
            geofenceRegionCenterCoordinate.longitude = $0.coordinate.longitude
        }
    }
}
