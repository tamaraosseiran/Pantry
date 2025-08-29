//
//  EnhancedCameraView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import UIKit
import Vision

struct EnhancedCameraView: View {
    @StateObject private var imageRecognitionService = ImageRecognitionService()
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var inputImage: UIImage?
    @State private var showingResults = false
    @State private var selectedIngredients: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .scaleEffect(imageRecognitionService.isProcessing ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: imageRecognitionService.isProcessing)
                    
                    Text("AI-Powered Ingredient Scanner")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Take a photo of your ingredients and let AI detect them automatically")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: { showingCamera = true }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(imageRecognitionService.isProcessing)
                    
                    Button(action: { showingImagePicker = true }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose from Library")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(imageRecognitionService.isProcessing)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Processing Status
                if imageRecognitionService.isProcessing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Analyzing image with AI...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Error Message
                if let errorMessage = imageRecognitionService.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Results Preview
                if !imageRecognitionService.detectedIngredients.isEmpty && !imageRecognitionService.isProcessing {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Detected Ingredients")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("View All") {
                                showingResults = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(imageRecognitionService.detectedIngredients.prefix(3)) { ingredient in
                                    DetectedIngredientChip(ingredient: ingredient)
                                }
                                
                                if imageRecognitionService.detectedIngredients.count > 3 {
                                    Text("+\(imageRecognitionService.detectedIngredients.count - 3) more")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("AI Scanner")
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $inputImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingResults) {
                DetectionResultsView(
                    detectedIngredients: imageRecognitionService.detectedIngredients,
                    onAddIngredients: addSelectedIngredients
                )
            }
            .onChange(of: inputImage) { _, newImage in
                if let image = newImage {
                    imageRecognitionService.processImage(image)
                }
            }
        }
    }
    
    private func addSelectedIngredients(_ ingredients: [String]) {
        for ingredientName in ingredients {
            let ingredient = Ingredient(name: ingredientName)
            modelContext.insert(ingredient)
        }
        
        // Clear the results after adding
        imageRecognitionService.clearResults()
        inputImage = nil
    }
}

struct DetectedIngredientChip: View {
    let ingredient: DetectedIngredient
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: confidenceIcon)
                .font(.caption)
                .foregroundColor(confidenceColor)
            
            Text(ingredient.name)
                .font(.caption)
                .fontWeight(.medium)
            
            Text("\(Int(ingredient.confidence * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var confidenceIcon: String {
        if ingredient.confidence > 0.8 {
            return "checkmark.circle.fill"
        } else if ingredient.confidence > 0.6 {
            return "checkmark.circle"
        } else {
            return "questionmark.circle"
        }
    }
    
    private var confidenceColor: Color {
        if ingredient.confidence > 0.8 {
            return .green
        } else if ingredient.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct DetectionResultsView: View {
    @Environment(\.dismiss) private var dismiss
    let detectedIngredients: [DetectedIngredient]
    let onAddIngredients: ([String]) -> Void
    
    @State private var selectedIngredients: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack {
                if detectedIngredients.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No ingredients detected")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Try taking a clearer photo or adjusting the lighting")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        Section("Detected Ingredients") {
                            ForEach(detectedIngredients) { ingredient in
                                DetectedIngredientRow(
                                    ingredient: ingredient,
                                    isSelected: selectedIngredients.contains(ingredient.name)
                                ) {
                                    if selectedIngredients.contains(ingredient.name) {
                                        selectedIngredients.remove(ingredient.name)
                                    } else {
                                        selectedIngredients.insert(ingredient.name)
                                    }
                                }
                            }
                        }
                        
                        Section {
                            HStack {
                                Button("Select All") {
                                    selectedIngredients = Set(detectedIngredients.map { $0.name })
                                }
                                .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button("Clear Selection") {
                                    selectedIngredients.removeAll()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Detection Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Selected") {
                        onAddIngredients(Array(selectedIngredients))
                        dismiss()
                    }
                    .disabled(selectedIngredients.isEmpty)
                }
            }
        }
    }
}

struct DetectedIngredientRow: View {
    let ingredient: DetectedIngredient
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(ingredient.detectionType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(ingredient.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundColor(confidenceColor)
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var confidenceColor: Color {
        if ingredient.confidence > 0.8 {
            return .green
        } else if ingredient.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    EnhancedCameraView()
        .modelContainer(for: Ingredient.self, inMemory: true)
} 