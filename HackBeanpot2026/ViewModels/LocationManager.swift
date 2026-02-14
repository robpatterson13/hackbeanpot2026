//
//  LocationManager.swift
//  HackBeanpot2026
//
//  Created by Assistant on 2/14/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isOutside: Bool = false
    @Published var hasBeenOutside: Bool = false
    
    // Track indoor/outdoor status
    private var initialLocation: CLLocation?
    private var significantMovementDetected = false
    
    // Configuration
    private let minimumDistanceForOutside: CLLocationDistance = 10.0 // 10 meters
    private let minimumTimeOutside: TimeInterval = 300 // 5 minutes
    var outsideStartTime: Date?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 5.0 // Update every 5 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Guide user to settings
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationTracking()
        @unknown default:
            break
        }
    }
    
    func startLocationTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        initialLocation = nil
        significantMovementDetected = false
        hasBeenOutside = false
        outsideStartTime = nil
    }
    
    func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
        initialLocation = nil
        significantMovementDetected = false
        outsideStartTime = nil
    }
    
    private func determineIfOutside(location: CLLocation) {
        // Set initial location if not set
        if initialLocation == nil {
            initialLocation = location
            return
        }
        
        guard let initial = initialLocation else { return }
        
        let distance = location.distance(from: initial)
        
        // Check if user has moved significantly from initial position
        if distance > minimumDistanceForOutside {
            significantMovementDetected = true
        }
        
        // Determine if currently outside based on multiple factors
        let newIsOutside = determineOutdoorStatus(location: location)
        
        if newIsOutside && !isOutside {
            // Just went outside
            outsideStartTime = Date()
        } else if !newIsOutside && isOutside {
            // Just went inside
            outsideStartTime = nil
        }
        
        isOutside = newIsOutside
        
        // Check if user has been outside long enough
        if isOutside && significantMovementDetected {
            if let startTime = outsideStartTime,
               Date().timeIntervalSince(startTime) >= minimumTimeOutside {
                hasBeenOutside = true
            }
        }
    }
    
    private func determineOutdoorStatus(location: CLLocation) -> Bool {
        // Multiple heuristics to determine if user is outside:
        
        // 1. Horizontal accuracy - GPS works better outside
        let goodGPSAccuracy = location.horizontalAccuracy <= 15.0
        
        // 2. Altitude accuracy - available when GPS has good signal
        let hasAltitude = location.verticalAccuracy > 0 && location.verticalAccuracy <= 20.0
        
        // 3. Speed - if moving at walking/running speed, likely outside
        let isMoving = location.speed > 0.5 // 0.5 m/s ≈ 1.1 mph
        
        // 4. Time of day - more likely to be outside during day
        let hour = Calendar.current.component(.hour, from: Date())
        let isDayTime = hour >= 6 && hour <= 22
        
        // Combine heuristics
        var outdoorScore = 0
        if goodGPSAccuracy { outdoorScore += 2 }
        if hasAltitude { outdoorScore += 1 }
        if isMoving { outdoorScore += 1 }
        if isDayTime { outdoorScore += 1 }
        
        return outdoorScore >= 3
    }
    
    // Reset the outside detection for a new day/task
    func resetOutsideDetection() {
        hasBeenOutside = false
        isOutside = false
        significantMovementDetected = false
        outsideStartTime = nil
        initialLocation = currentLocation
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        determineIfOutside(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationTracking()
        case .denied, .restricted:
            stopLocationTracking()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}