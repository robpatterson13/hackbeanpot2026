//
//  LocationVerificationView.swift
//  HackBeanpot2026
//
//  Created by Assistant on 2/14/26.
//

import SwiftUI
import CoreLocation

struct LocationVerificationView: View {
    let prompt: String
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @StateObject private var locationManager = LocationManager()
    @State private var showPermissionAlert = false
    @State private var showSettingsAlert = false
    
    private var statusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Location permission needed"
        case .denied, .restricted:
            return "Location access denied"
        case .authorizedWhenInUse, .authorizedAlways:
            if locationManager.hasBeenOutside {
                return "Task completed! You've been outside for 5+ minutes."
            } else if locationManager.isOutside {
                let timeRemaining = max(0, 300 - (locationManager.outsideStartTime?.timeIntervalSinceNow ?? 0))
                return "Outside detected! Stay outside for \(Int(timeRemaining)) more seconds."
            } else {
                return "Go outside to complete this task"
            }
        @unknown default:
            return "Unknown location status"
        }
    }
    
    private var statusColor: Color {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return .red
        case .authorizedWhenInUse, .authorizedAlways:
            if locationManager.hasBeenOutside {
                return .green
            } else if locationManager.isOutside {
                return .orange
            } else {
                return .blue
            }
        default:
            return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "location.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Go Outside")
                    .font(.largeTitle)
                    .bold()
                
                Text(prompt)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Divider()
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: locationStatusIcon)
                            .foregroundColor(statusColor)
                        Text(statusText)
                            .font(.headline)
                            .foregroundColor(statusColor)
                    }
                    
                    if locationManager.authorizationStatus == .notDetermined {
                        Button("Allow Location Access") {
                            locationManager.requestLocationPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                        Button("Open Settings") {
                            showSettingsAlert = true
                        }
                        .buttonStyle(.bordered)
                    } else if locationManager.hasBeenOutside {
                        Button("Complete Task") {
                            onComplete()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        VStack(spacing: 12) {
                            Text("Tracking your location...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ProgressView()
                                .scaleEffect(1.2)
                            
                            if let location = locationManager.currentLocation {
                                Text("Accuracy: ±\(Int(location.horizontalAccuracy))m")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Location Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        locationManager.stopLocationTracking()
                        onCancel()
                    }
                }
            }
        }
        .onAppear {
            locationManager.resetOutsideDetection()
            locationManager.requestLocationPermission()
        }
        .onDisappear {
            locationManager.stopLocationTracking()
        }
        .alert("Location Access Required", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to verify outdoor activities.")
        }
    }
    
    private var locationStatusIcon: String {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return "location.slash"
        case .authorizedWhenInUse, .authorizedAlways:
            if locationManager.hasBeenOutside {
                return "checkmark.circle.fill"
            } else if locationManager.isOutside {
                return "location.circle"
            } else {
                return "location"
            }
        default:
            return "location.questionmark"
        }
    }
}

#Preview {
    LocationVerificationView(
        prompt: "Go outside for at least 5 minutes to complete this task.",
        onComplete: { print("Task completed!") },
        onCancel: { print("Task cancelled") }
    )
}