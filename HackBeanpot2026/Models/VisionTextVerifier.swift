//
//  VisionTextVerifier.swift
//  HackBeanpot2026
//

import Foundation
import Vision
import UIKit

enum ScreenshotType {
    case jobs
    case leetcode
}

struct VerificationResult {
    let matchedKeywords: [String]
    let confidence: Float
    var isConfident: Bool {
        matchedKeywords.count >= 2 || confidence >= 0.85
    }
}

enum VisionTextVerifier {
    static func verify(image: UIImage, type: ScreenshotType) async throws -> VerificationResult {
        guard let cgImage = image.cgImage else {
            return VerificationResult(matchedKeywords: [], confidence: 0)
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US", "en-GB"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        let observations = request.results ?? []
        let allText = observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: " ")
            .lowercased()

        let keywords: [String]
        let strongKeywords: [String]

        switch type {
        case .jobs:
            keywords = [
                "thank you for applying",
                "application submitted",
                "we've received your application",
                "we have received your application",
                "your application has been received",
                "thanks for applying",
                "submission received",
                "applied successfully",
                "application complete"
            ]
            strongKeywords = [
                "thank you for applying",
                "application submitted",
                "we've received your application",
                "your application has been received"
            ]
        case .leetcode:
            keywords = [
                "accepted",
                "success",
                "submission",
                "runtime",
                "memory",
                "beats",
                "passed",
                "leetcode"
            ]
            strongKeywords = [
                "accepted",
                "success"
            ]
        }

        let matched = keywords.filter { allText.contains($0) }

        let strongMatches = strongKeywords.filter { allText.contains($0) }.count
        let baseScore = Float(matched.count) / Float(max(3, keywords.count / 3))
        let confidence = min(1.0, baseScore + Float(strongMatches) * 0.2)

        return VerificationResult(matchedKeywords: matched, confidence: confidence)
    }
}

