//
//  AddIngredientView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct AddIngredientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var quantity = 1.0
    @State private var unit = "piece"
    @State private var category = IngredientCategory.other
    @State private var expiryDate: Date = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @State private var hasExpiryDate = false
    @State private var notes = ""
    @State private var showingVoiceInput = false
    
    private let units = ["piece", "pieces", "gram", "grams", "kg", "ounce", "ounces", "cup", "cups", "tablespoon", "tablespoons", "teaspoon", "teaspoons", "ml", "liter", "liters"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ingredient Details") {
                    HStack {
                        TextField("Ingredient name", text: $name)
                        
                        Button(action: { showingVoiceInput = true }) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.blue)
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
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIngredient()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingVoiceInput) {
                VoiceInputView(text: $name)
            }
        }
    }
    
    private func saveIngredient() {
        let ingredient = Ingredient(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            unit: unit,
            category: category,
            expiryDate: hasExpiryDate ? expiryDate : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(ingredient)
        dismiss()
    }
}

struct VoiceInputView: View {
    @Binding var text: String
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording = false
    @State private var transcribedText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 80))
                        .foregroundColor(isRecording ? .red : .blue)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                    
                    Text(isRecording ? "Listening..." : "Tap to start recording")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if !transcribedText.isEmpty {
                        Text(transcribedText)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: toggleRecording) {
                        HStack {
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            Text(isRecording ? "Stop Recording" : "Start Recording")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRecording ? Color.red : Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    if !transcribedText.isEmpty {
                        Button("Use This Text") {
                            text = transcribedText
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Voice Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            // TODO: Implement actual speech recognition
            // For now, simulate transcription
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                transcribedText = "Fresh tomatoes"
                isRecording = false
            }
        }
    }
}

#Preview {
    AddIngredientView()
        .modelContainer(for: Ingredient.self, inMemory: true)
} 