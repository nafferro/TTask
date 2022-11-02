//
//  MainViewModel.swift
//  TTask
//
//  Created by Nuno Ferro on 31/10/2022.
//

import CoreLocation
import UserNotifications
import CoreMotion

class MainViewModel: NSObject, ObservableObject {
    
    @Published var showAlert = false
    @Published var notificationTitle = "You are leaving your confort zone"
    @Published var movementLabel = "Stationary"
    @Published var movementIcon = "person.fill"
    
    private let locationManager = CLLocationManager()
    var geofenceRegion = CLCircularRegion()
    var geofenceRegionCenterCoordinate = kCLLocationCoordinate2DInvalid
    let notificationCenter = UNUserNotificationCenter.current()
    
    let activityManager = CMMotionActivityManager()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        setupLocationManager()
        setupPedometer()
    }
    
    func setupLocationManager() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupGeoFence() {
        geofenceRegion = CLCircularRegion (
            center: geofenceRegionCenterCoordinate,
            radius: 50, // 50m
            identifier: UUID().uuidString
        )
        geofenceRegion.notifyOnExit = true
        
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] result, _ in
            if result {
                self?.registerNotification()
            }
        }
    }
    
    private func registerNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = notificationTitle
        notificationContent.body = "Please stay alert"
        notificationContent.sound = .default
        
        let trigger = UNLocationNotificationTrigger(region: geofenceRegion, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: trigger)
        
        notificationCenter.add(request) { error in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    func setupPedometer() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
                guard let activity = activity else { return }
                DispatchQueue.main.async {
                    if activity.walking {
                        self.movementLabel = "Walking"
                        self.movementIcon = "figure.walk"
                    } else if activity.stationary {
                        self.movementLabel = "Stationary"
                        self.movementIcon = "person.fill"
                    } else if activity.running {
                        self.movementLabel = "Running"
                        self.movementIcon = "figure.run"
                        self.notificationTitle = "🏃‍♂️ You are running from your confort zone"
                    }
                }
            }
        }
    }
}

extension MainViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,withError error: Error) {
        guard let region = region else {
            print("Monitoring failed for unknown region")
            return
        }
        print("Monitoring failed for region with identifier: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            // kCLLocationCoordinate2DInvalid have -180.0 latitude and longitude
            guard geofenceRegionCenterCoordinate.latitude == -180.0 else { return }
            guard $0.horizontalAccuracy < 20 else { return }
            geofenceRegionCenterCoordinate.latitude = $0.coordinate.latitude
            geofenceRegionCenterCoordinate.longitude = $0.coordinate.longitude
            setupGeoFence()
        }
    }
}

extension MainViewModel: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        showAlert = true
        completionHandler(.sound)
    }
}
