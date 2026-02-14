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
        // This property is informational; pass/fail semantics are encoded by the confidence value returned.
        confidence >= 0.75
    }
}

private extension String {
    func normalizedForMatching() -> String {
        // Lowercase, normalize quotes/apostrophes, remove most punctuation, collapse whitespace.
        var s = self.lowercased()

        // Replace curly quotes/apostrophes with straight ones
        let replacements: [String: String] = [
            "’": "'",
            "‘": "'",
            "“": "\"",
            "”": "\""
        ]
        for (k, v) in replacements {
            s = s.replacingOccurrences(of: k, with: v)
        }

        // Remove punctuation except apostrophes and spaces, convert others to spaces
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "' "))
        s = s.unicodeScalars.map { allowed.contains($0) ? Character($0) : " " }.reduce(into: "") { $0.append($1) }

        // Collapse multiple spaces
        while s.contains("  ") {
            s = s.replacingOccurrences(of: "  ", with: " ")
        }

        return s.trimmingCharacters(in: .whitespacesAndNewlines)
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

    // MARK: - Jobs (relaxed)

    private static func verifyJobs(in allText: String) -> VerificationResult {
        let keywords = [
            "thank you for applying",
            "thank you for your application",
            "thanks for applying",
            "application submitted",
            "application successfully submitted",
            "we have received your application",
            "we've received your application",
            "your application has been received",
            "we received your application",
            "application received",
            "submission received",
            "submission complete",
            "applied successfully",
            "application complete",
            "your application was submitted"
        ]

        let strongKeywords = [
            "thank you for applying",
            "thank you for your application",
            "application submitted",
            "we have received your application",
            "we've received your application",
            "your application has been received"
        ]

        let matched = keywords.filter { allText.contains($0) }
        let strongMatches = strongKeywords.filter { allText.contains($0) }.count

        // Relaxed: any strong keyword is enough
        if strongMatches >= 1 {
            return VerificationResult(matchedKeywords: matched, confidence: 1.0)
        }

        // Otherwise compute confidence and relax pass condition
        let baseScore = Float(matched.count) / Float(max(3, keywords.count / 3))
        let confidence = min(1.0, baseScore + Float(strongMatches) * 0.2)

        // Relaxed pass: at least 1 keyword OR confidence >= 0.75
        let isPass = matched.count >= 1 || confidence >= 0.75
        let finalConfidence: Float = isPass ? max(confidence, 0.75) : confidence

        return VerificationResult(matchedKeywords: matched, confidence: finalConfidence)
    }

    // MARK: - LeetCode (original strictness)

    private static func verifyLeetCode(in allText: String) -> VerificationResult {
        let keywords = [
            "accepted",
            "success",
            "submission",
            "runtime",
            "memory",
            "beats",
            "passed",
            "leetcode"
        ]

        let strongKeywords = [
            "accepted",
            "success"
        ]

        let matched = keywords.filter { allText.contains($0) }
        let strongMatches = strongKeywords.filter { allText.contains($0) }.count

        // Original scoring
        let baseScore = Float(matched.count) / Float(max(3, keywords.count / 3))
        let confidence = min(1.0, baseScore + Float(strongMatches) * 0.2)

        // Original pass rule: 2 keywords OR confidence >= 0.85
        let isPass = matched.count >= 2 || confidence >= 0.85
        let finalConfidence: Float = isPass ? max(confidence, 0.85) : confidence

        return VerificationResult(matchedKeywords: matched, confidence: finalConfidence)
    }
}
