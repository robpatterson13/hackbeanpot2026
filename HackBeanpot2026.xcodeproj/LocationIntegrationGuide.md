# Location Services Integration Guide

## Overview
This implementation adds location-based verification for the "Go Outside" task in your habit tracking app. Users must actually go outside for at least 5 minutes to complete the task.

## Files Created/Modified

### New Files:
1. **LocationManager.swift** - Core location tracking and outdoor detection logic
2. **LocationVerificationView.swift** - SwiftUI view for location-based task verification
3. **Info.plist.template** - Required privacy permissions

### Modified Files:
1. **Habit.swift** - Added `.location` verification case
2. **TaskView.swift** - Updated VerificationSheet to handle location verification

## How It Works

### Detection Algorithm
The system uses multiple heuristics to determine if a user is outside:

1. **Movement Detection**: Tracks if user moves at least 10 meters from starting position
2. **GPS Accuracy**: Better GPS accuracy typically indicates outdoor location
3. **Altitude Data**: Available altitude readings suggest clear sky view
4. **Movement Speed**: Walking/running speeds indicate outdoor activity
5. **Time Requirements**: User must stay outside for 5+ minutes

### Scoring System
- Good GPS accuracy (±15m): +2 points
- Altitude data available: +1 point  
- User is moving (>0.5 m/s): +1 point
- Daytime hours (6 AM - 10 PM): +1 point
- **Total 3+ points = "Outside" detected**

## Setup Instructions

### 1. Add Privacy Permissions
Add these keys to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location services to verify that you go outside to complete your daily outdoor activity goal.</string>
```

### 2. Import CoreLocation
Make sure your project includes the CoreLocation framework.

### 3. Test the Implementation
- Run the app on a physical device (location won't work in simulator)
- Tap on "Go Outside" task
- Grant location permission when prompted
- Walk outside for 5+ minutes to complete the task

## Configuration Options

You can adjust these values in `LocationManager.swift`:

```swift
// Minimum distance to travel from starting point
private let minimumDistanceForOutside: CLLocationDistance = 10.0 // meters

// Time required outside to complete task  
private let minimumTimeOutside: TimeInterval = 300 // seconds (5 minutes)

// GPS accuracy for outdoor detection
let goodGPSAccuracy = location.horizontalAccuracy <= 15.0 // meters

// Walking speed threshold
let isMoving = location.speed > 0.5 // m/s (≈ 1.1 mph)
```

## Security & Privacy

### Privacy-First Approach
- Only requests "When In Use" location permission
- No location data is stored or transmitted
- All processing happens on-device
- Location tracking stops when verification completes

### Fallback Options
- Manual override button for edge cases
- Graceful handling of permission denials
- Works without background location access

## Troubleshooting

### Common Issues:

1. **Permission Denied**
   - User is guided to Settings to enable location
   - Fallback manual verification available

2. **Poor GPS Signal**
   - Algorithm accounts for indoor GPS accuracy
   - Manual override available after timeout

3. **False Positives**
   - Movement requirement prevents gaming the system
   - Time requirement ensures genuine outdoor activity

### Testing Tips:
- Test on physical device only
- Try different environments (urban, suburban, rural)
- Verify accuracy in various weather conditions
- Test edge cases like garages, covered areas

## Future Enhancements

Potential improvements you could add:

1. **Weather Integration**: Adjust requirements based on weather conditions
2. **Activity Detection**: Use Core Motion to detect walking/running
3. **Geofencing**: Define specific outdoor areas like parks
4. **Social Features**: Share outdoor achievements with friends
5. **Analytics**: Track outdoor activity patterns over time

## Performance Considerations

- Location updates limited to 5-meter intervals
- Automatic cleanup when verification completes
- Minimal battery impact with optimized settings
- No continuous background location tracking