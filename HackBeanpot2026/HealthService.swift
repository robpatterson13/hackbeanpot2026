//
//  HealthService.swift
//  HackBeanpot2026
//
//  Created by Rob Patterson on 2/13/26.
//

import HealthKit
import CoreLocation
import Foundation
import UIKit
import Vision
import CoreML

@Observable
class HealthService {
    private let healthStore = HKHealthStore()
    private let locationManager = CLLocationManager()
    
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitPermission() async throws {
        guard isHealthKitAvailable else {
            throw HealthServiceError.healthKitNotAvailable
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    func getTodaysStepCount() async throws -> Int {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(stepCount))
            }
            
            healthStore.execute(query)
        }
    }
    
    func getLastNightSleepHours() async throws -> Double {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let now = Date()
        
        // Look for sleep data from yesterday evening to this morning
        let startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        let endDate = now
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                // Calculate total sleep time
                let totalSleepTime = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue || 
                             $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }
                    .reduce(0.0) { total, sample in
                        total + sample.endDate.timeIntervalSince(sample.startDate)
                    }
                
                let hoursSlept = totalSleepTime / 3600.0 // Convert seconds to hours
                continuation.resume(returning: hoursSlept)
            }
            
            healthStore.execute(query)
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func verifyOutsideActivity() async -> Bool {
        // This would integrate with Core Location to verify the user went outside
        // For the hackathon, we'll implement a simplified version
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            return false
        }
        
        // In a real implementation, you'd track location changes and determine
        // if the user spent time outdoors (away from their home location)
        // For now, we'll return true as a placeholder
        return true
    }
}

enum HealthServiceError: Error {
    case healthKitNotAvailable
    case permissionDenied
    case noDataAvailable
}

// MARK: - Photo Verification Service

struct VerificationResult {
    let isValid: Bool
    let confidence: Double
    let analysisDetails: String
    let detectedKeywords: [String]
}

@Observable
class PhotoVerificationService {
    
    // Job application keywords to search for
    private let jobKeywords = [
        "application", "applied", "submitted", "confirmation", "thank you",
        "position", "job", "career", "employment", "interview", "resume",
        "cv", "candidate", "hiring", "recruitment", "opportunity",
        "linkedin", "indeed", "glassdoor", "workday", "bamboohr",
        "lever", "greenhouse", "smartrecruiters", "jobvite", "icims",
        "@", ".com", "email", "message", "sent", "received"
    ]
    
    // Email domains commonly used for job applications
    private let jobSiteDomains = [
        "linkedin.com", "indeed.com", "glassdoor.com", "monster.com",
        "ziprecruiter.com", "careerbuilder.com", "workday.com",
        "bamboohr.com", "lever.co", "greenhouse.io", "smartrecruiters.com"
    ]
    
    func verifyJobApplication(photo: UIImage) async -> Bool {
        let result = await getVerificationDetails(photo: photo)
        return result.isValid
    }
    
    func getVerificationDetails(photo: UIImage) async -> VerificationResult {
        // Extract text from the image using Vision framework
        let extractedText = await extractTextFromImage(photo)
        
        // Analyze the extracted text
        let analysis = analyzeTextForJobApplication(extractedText)
        
        return VerificationResult(
            isValid: analysis.isValid,
            confidence: analysis.confidence,
            analysisDetails: analysis.details,
            detectedKeywords: analysis.keywords
        )
    }
    
    private func extractTextFromImage(_ image: UIImage) async -> String {
        guard let cgImage = image.cgImage else {
            return ""
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    return observation.topCandidates(1).first?.string
                }.joined(separator: " ")
                
                continuation.resume(returning: recognizedText)
            }
            
            // Configure for better text recognition
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: "")
            }
        }
    }
    
    private func analyzeTextForJobApplication(_ text: String) -> (isValid: Bool, confidence: Double, details: String, keywords: [String]) {
        let lowercaseText = text.lowercased()
        var detectedKeywords: [String] = []
        var confidenceScore: Double = 0.0
        var analysisDetails: [String] = []
        
        // Check for job-related keywords
        for keyword in jobKeywords {
            if lowercaseText.contains(keyword) {
                detectedKeywords.append(keyword.uppercased())
                confidenceScore += 1.0
            }
        }
        
        // Check for email domains
        for domain in jobSiteDomains {
            if lowercaseText.contains(domain) {
                detectedKeywords.append(domain.uppercased())
                confidenceScore += 2.0 // Higher weight for job site domains
                analysisDetails.append("DETECTED JOB SITE: \(domain.uppercased())")
            }
        }
        
        // Check for email patterns
        let emailRegex = try? NSRegularExpression(pattern: "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}", options: .caseInsensitive)
        let emailMatches = emailRegex?.matches(in: text, range: NSRange(location: 0, length: text.count)) ?? []
        
        if !emailMatches.isEmpty {
            confidenceScore += 1.5
            analysisDetails.append("EMAIL ADDRESSES DETECTED: \(emailMatches.count)")
        }
        
        // Check for specific job application phrases
        let jobPhrases = [
            "thank you for your application",
            "application received",
            "we have received your application",
            "your application has been submitted",
            "application confirmation",
            "next steps in the hiring process"
        ]
        
        for phrase in jobPhrases {
            if lowercaseText.contains(phrase) {
                confidenceScore += 3.0 // High confidence for these phrases
                analysisDetails.append("FOUND: \(phrase.uppercased())")
            }
        }
        
        // Check for date patterns (applications often have timestamps)
        let dateRegex = try? NSRegularExpression(pattern: "\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4}", options: [])
        let dateMatches = dateRegex?.matches(in: text, range: NSRange(location: 0, length: text.count)) ?? []
        
        if !dateMatches.isEmpty {
            confidenceScore += 0.5
            analysisDetails.append("DATE STAMPS DETECTED")
        }
        
        // Normalize confidence score (max possible score is around 20+)
        let normalizedConfidence = min(confidenceScore / 20.0, 1.0)
        
        // Build detailed analysis
        var details = "ANALYSIS COMPLETE\n"
        details += "KEYWORDS FOUND: \(detectedKeywords.count)\n"
        details += "CONFIDENCE: \(Int(normalizedConfidence * 100))%\n\n"
        
        if !analysisDetails.isEmpty {
            details += "DETAILS:\n"
            details += analysisDetails.joined(separator: "\n")
            details += "\n\n"
        }
        
        if !detectedKeywords.isEmpty {
            details += "DETECTED TERMS:\n"
            details += detectedKeywords.prefix(10).joined(separator: ", ")
        }
        
        // Determine if verification passes
        let isValid = normalizedConfidence > 0.3 || detectedKeywords.count >= 3
        
        if !isValid {
            details += "\n\nVERIFICATION FAILED\nREQUIREMENTS NOT MET"
        } else {
            details += "\n\nVERIFICATION PASSED\nJOB APPLICATION DETECTED"
        }
        
        return (
            isValid: isValid,
            confidence: normalizedConfidence,
            details: details,
            keywords: detectedKeywords
        )
    }
    
    // Additional helper method for analyzing image metadata
    private func analyzeImageMetadata(_ image: UIImage) -> [String: Any] {
        var metadata: [String: Any] = [:]
        
        // Basic image properties
        metadata["width"] = image.size.width
        metadata["height"] = image.size.height
        metadata["scale"] = image.scale
        
        // Try to extract EXIF data if available
        if let cgImage = image.cgImage,
           let dataProvider = cgImage.dataProvider,
           let data = dataProvider.data,
           let source = CGImageSourceCreateWithData(data, nil) {
            
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] {
                metadata["exif"] = properties
            }
        }
        
        return metadata
    }
}

// MARK: - Task Verification Service

@Observable
class TaskVerificationService {
    let healthService = HealthService()
    let photoService = PhotoVerificationService()
    
    func verifyTask(_ task: HabitTask, photo: UIImage? = nil) async throws -> Bool {
        switch task.verificationType {
        case .manual:
            return true // User manually confirms
            
        case .healthKit:
            switch task.type {
            case .steps:
                let steps = try await healthService.getTodaysStepCount()
                return steps >= 5000 // 5k steps requirement
                
            case .sleep:
                let sleepHours = try await healthService.getLastNightSleepHours()
                return sleepHours >= 7.0 // 7+ hours requirement
                
            default:
                return false
            }
            
        case .photo:
            guard let photo = photo else { return false }
            return await photoService.verifyJobApplication(photo: photo)
            
        case .location:
            return await healthService.verifyOutsideActivity()
        }
    }
}
