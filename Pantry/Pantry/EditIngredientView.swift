//
//  EditIngredientView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct EditIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    let ingredient: Ingredient
    
    @State private var name: String
    @State private var quantity: Double
    @State private var unit: String
    @State private var category: IngredientCategory
    @State private var expiryDate: Date
    @State private var hasExpiryDate: Bool
    @State private var notes: String
    @State private var showingImagePicker = false
    @State private var ingredientImage: UIImage?
    
    private let units = ["piece", "pieces", "gram", "grams", "kg", "ounce", "ounces", "cup", "cups", "tablespoon", "tablespoons", "teaspoon", "teaspoons", "ml", "liter", "liters"]
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        self._name = State(initialValue: ingredient.name)
        self._quantity = State(initialValue: ingredient.quantity)
        self._unit = State(initialValue: ingredient.unit)
        self._category = State(initialValue: ingredient.category)
        self._expiryDate = State(initialValue: ingredient.expiryDate ?? Date().addingTimeInterval(86400 * 7))
        self._hasExpiryDate = State(initialValue: ingredient.expiryDate != nil)
        self._notes = State(initialValue: ingredient.notes ?? "")
        
        // Load existing image if available
        if let imageData = ingredient.imageData {
            self._ingredientImage = State(initialValue: UIImage(data: imageData))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ingredient Details") {
                    TextField("Ingredient name", text: $name)
                    
                    // Ingredient Image
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredient Photo")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: { showingImagePicker = true }) {
                            if let image = ingredientImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Add Photo")
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("Quantity", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Expiry Date") {
                    Toggle("Set expiry date", isOn: $hasExpiryDate)
                    
                    if hasExpiryDate {
                        DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Status") {
                    HStack {
                        Text("Added on")
                        Spacer()
                        Text(ingredient.dateAdded, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(ingredient.isUsed ? "Used" : "Available")
                            .foregroundColor(ingredient.isUsed ? .green : .blue)
                            .fontWeight(.medium)
                    }
                }
            }
            .navigationTitle("Edit Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $ingredientImage, sourceType: .photoLibrary)
            }
        }
    }
    
    private func saveChanges() {
        ingredient.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredient.quantity = quantity
        ingredient.unit = unit
        ingredient.category = category
        ingredient.expiryDate = hasExpiryDate ? expiryDate : nil
        ingredient.notes = notes.isEmpty ? nil : notes
        
        // Save image data if available
        if let image = ingredientImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            ingredient.imageData = imageData
        }
        
        dismiss()
    }
}

#Preview {
    let ingredient = Ingredient(name: "Tomato", quantity: 3, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 2))
    return EditIngredientView(ingredient: ingredient)
} 