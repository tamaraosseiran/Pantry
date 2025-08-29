//
//  ImageRecognitionService.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import Foundation
import Vision
import UIKit
import CoreML

class ImageRecognitionService: ObservableObject {
    @Published var isProcessing = false
    @Published var detectedIngredients: [DetectedIngredient] = []
    @Published var errorMessage: String?
    
    // Common food ingredients for text recognition
    private let foodKeywords = [
        "tomato", "tomatoes", "onion", "onions", "garlic", "potato", "potatoes",
        "carrot", "carrots", "lettuce", "spinach", "kale", "broccoli", "cauliflower",
        "pepper", "peppers", "bell pepper", "bell peppers", "cucumber", "cucumbers",
        "mushroom", "mushrooms", "eggplant", "zucchini", "squash", "corn",
        "apple", "apples", "banana", "bananas", "orange", "oranges", "lemon", "lemons",
        "lime", "limes", "grape", "grapes", "strawberry", "strawberries", "blueberry", "blueberries",
        "chicken", "beef", "pork", "fish", "salmon", "tuna", "shrimp", "eggs",
        "milk", "cheese", "yogurt", "butter", "cream", "bread", "pasta", "rice",
        "flour", "sugar", "salt", "pepper", "oil", "olive oil", "vinegar", "sauce",
        "herb", "herbs", "basil", "oregano", "thyme", "rosemary", "parsley", "cilantro"
    ]
    
    func processImage(_ image: UIImage) {
        isProcessing = true
        detectedIngredients = []
        errorMessage = nil
        
        guard let cgImage = image.cgImage else {
            errorMessage = "Failed to process image"
            isProcessing = false
            return
        }
        
        // Perform multiple recognition tasks
        performObjectRecognition(on: cgImage)
        performTextRecognition(on: cgImage)
    }
    
    private func performObjectRecognition(on image: CGImage) {
        let request = VNRecognizeObjectsRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Object recognition failed: \(error.localizedDescription)"
                    return
                }
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
                
                for observation in results {
                    // Get the top classification
                    guard let topClassification = observation.labels.first else { continue }
                    
                    let confidence = topClassification.confidence
                    let label = topClassification.identifier.lowercased()
                    
                    // Filter for food-related objects
                    if self?.isFoodRelated(label) == true && confidence > 0.5 {
                        let detectedIngredient = DetectedIngredient(
                            name: self?.normalizeIngredientName(label) ?? label,
                            confidence: confidence,
                            boundingBox: observation.boundingBox,
                            detectionType: .object
                        )
                        
                        self?.addDetectedIngredient(detectedIngredient)
                    }
                }
            }
        }
        
        // Configure the request
        request.recognitionLevel = .accurate
        request.usesCPUOnly = false
        
        // Create and perform the request
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to perform object recognition: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func performTextRecognition(on image: CGImage) {
        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Text recognition failed: \(error.localizedDescription)"
                    return
                }
                
                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                
                for observation in results {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    
                    let text = topCandidate.string.lowercased()
                    let confidence = topCandidate.confidence
                    
                    // Look for food-related keywords in the text
                    for keyword in self?.foodKeywords ?? [] {
                        if text.contains(keyword) && confidence > 0.3 {
                            let detectedIngredient = DetectedIngredient(
                                name: self?.normalizeIngredientName(keyword) ?? keyword,
                                confidence: confidence,
                                boundingBox: observation.boundingBox,
                                detectionType: .text
                            )
                            
                            self?.addDetectedIngredient(detectedIngredient)
                            break
                        }
                    }
                }
            }
        }
        
        // Configure the request
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Create and perform the request
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to perform text recognition: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func isFoodRelated(_ label: String) -> Bool {
        let foodCategories = [
            "food", "fruit", "vegetable", "meat", "dairy", "grain", "spice",
            "herb", "condiment", "beverage", "snack", "produce"
        ]
        
        return foodCategories.contains { category in
            label.contains(category)
        } || foodKeywords.contains { keyword in
            label.contains(keyword)
        }
    }
    
    private func normalizeIngredientName(_ name: String) -> String {
        // Convert plural to singular and clean up the name
        var normalized = name.lowercased()
        
        // Remove common suffixes
        if normalized.hasSuffix("s") && normalized.count > 3 {
            normalized = String(normalized.dropLast())
        }
        
        // Capitalize first letter
        return normalized.capitalized
    }
    
    private func addDetectedIngredient(_ ingredient: DetectedIngredient) {
        // Check if we already have this ingredient (avoid duplicates)
        if !detectedIngredients.contains(where: { $0.name.lowercased() == ingredient.name.lowercased() }) {
            detectedIngredients.append(ingredient)
        } else {
            // Update confidence if this detection is more confident
            if let index = detectedIngredients.firstIndex(where: { $0.name.lowercased() == ingredient.name.lowercased() }) {
                if ingredient.confidence > detectedIngredients[index].confidence {
                    detectedIngredients[index] = ingredient
                }
            }
        }
        
        // Sort by confidence
        detectedIngredients.sort { $0.confidence > $1.confidence }
    }
    
    func clearResults() {
        detectedIngredients = []
        errorMessage = nil
    }
}

// MARK: - Supporting Models
struct DetectedIngredient: Identifiable {
    let id = UUID()
    let name: String
    let confidence: Float
    let boundingBox: CGRect
    let detectionType: DetectionType
    
    enum DetectionType {
        case object
        case text
        
        var description: String {
            switch self {
            case .object:
                return "Object Detection"
            case .text:
                return "Text Recognition"
            }
        }
    }
}

// MARK: - Vision Framework Extensions
extension VNRecognizedTextObservation {
    func topCandidates(_ count: Int) -> [VNRecognizedText] {
        return self.topCandidates(count)
    }
} 