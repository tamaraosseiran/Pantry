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
    @State private var selectedEmoji = "🥬"
    
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
        
        // Load existing emoji if available (we'll extract it from the image data later)
        // For now, set a default based on category
        switch ingredient.category {
        case .vegetables: self._selectedEmoji = State(initialValue: "🥬")
        case .fruits: self._selectedEmoji = State(initialValue: "🍎")
        case .meat: self._selectedEmoji = State(initialValue: "🥩")
        case .dairy: self._selectedEmoji = State(initialValue: "🥛")
        case .grains: self._selectedEmoji = State(initialValue: "🌾")
        case .spices: self._selectedEmoji = State(initialValue: "🧂")
        case .condiments: self._selectedEmoji = State(initialValue: "🫒")
        case .beverages: self._selectedEmoji = State(initialValue: "🥤")
        case .frozen: self._selectedEmoji = State(initialValue: "🧊")
        case .canned: self._selectedEmoji = State(initialValue: "🥫")
        case .other: self._selectedEmoji = State(initialValue: "📦")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ingredient Details") {
                    TextField("Ingredient name", text: $name)
                    
                    // Ingredient Emoji
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Emoji")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        EmojiPickerView(selectedEmoji: $selectedEmoji)
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

        }
    }
    
    private func saveChanges() {
        ingredient.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredient.quantity = quantity
        ingredient.unit = unit
        ingredient.category = category
        ingredient.expiryDate = hasExpiryDate ? expiryDate : nil
        ingredient.notes = notes.isEmpty ? nil : notes
        
        // Save emoji as image data
        if let emojiImage = selectedEmoji.image(size: CGSize(width: 100, height: 100)),
           let imageData = emojiImage.pngData() {
            ingredient.imageData = imageData
        }
        
        dismiss()
    }
}

#Preview {
    let ingredient = Ingredient(name: "Tomato", quantity: 3, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 2))
    return EditIngredientView(ingredient: ingredient)
} 