//
//  PreferencesView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    @Environment(\.dismiss) private var dismiss
    
    @State private var dietaryRestrictions: Set<DietaryTag> = []
    @State private var preferredCuisines: Set<CuisineType> = []
    @State private var maxPrepTime: Int = 30
    @State private var householdSize: Int = 1
    @State private var skillLevel: DifficultyLevel = .easy
    @State private var notificationsEnabled: Bool = true
    @State private var wasteReductionGoal: Int = 20
    
    var preferences: UserPreferences? {
        userPreferences.first
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Dietary Preferences") {
                    Text("Select your dietary restrictions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(DietaryTag.allCases, id: \.self) { tag in
                            DietaryTagToggle(
                                tag: tag,
                                isSelected: dietaryRestrictions.contains(tag)
                            ) {
                                if dietaryRestrictions.contains(tag) {
                                    dietaryRestrictions.remove(tag)
                                } else {
                                    dietaryRestrictions.insert(tag)
                                }
                            }
                        }
                    }
                }
                
                Section("Cuisine Preferences") {
                    Text("Select your favorite cuisines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(CuisineType.allCases, id: \.self) { cuisine in
                            CuisineTagToggle(
                                cuisine: cuisine,
                                isSelected: preferredCuisines.contains(cuisine)
                            ) {
                                if preferredCuisines.contains(cuisine) {
                                    preferredCuisines.remove(cuisine)
                                } else {
                                    preferredCuisines.insert(cuisine)
                                }
                            }
                        }
                    }
                }
                
                Section("Cooking Preferences") {
                    HStack {
                        Text("Max prep time")
                        Spacer()
                        Text("\(maxPrepTime) minutes")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(maxPrepTime) },
                        set: { maxPrepTime = Int($0) }
                    ), in: 5...120, step: 5)
                    
                    HStack {
                        Text("Household size")
                        Spacer()
                        Stepper("\(householdSize)", value: $householdSize, in: 1...10)
                    }
                    
                    Picker("Skill level", selection: $skillLevel) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            HStack {
                                Circle()
                                    .fill(levelColor(for: level))
                                    .frame(width: 12, height: 12)
                                Text(level.rawValue)
                            }
                            .tag(level)
                        }
                    }
                }
                
                Section("Waste Reduction") {
                    HStack {
                        Text("Waste reduction goal")
                        Spacer()
                        Text("\(wasteReductionGoal)%")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(wasteReductionGoal) },
                        set: { wasteReductionGoal = Int($0) }
                    ), in: 10...50, step: 5)
                    
                    Text("Target percentage of ingredients used before expiry")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notifications") {
                    Toggle("Enable notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Text("You'll receive alerts for expiring ingredients and recipe suggestions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreferences()
                    }
                }
            }
            .onAppear {
                loadPreferences()
            }
        }
    }
    
    private func levelColor(for level: DifficultyLevel) -> Color {
        switch level {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    private func loadPreferences() {
        guard let prefs = preferences else { return }
        
        dietaryRestrictions = Set(prefs.dietaryRestrictions)
        preferredCuisines = Set(prefs.preferredCuisines)
        maxPrepTime = prefs.maxPrepTime ?? 30
        householdSize = prefs.householdSize
        skillLevel = prefs.skillLevel
        notificationsEnabled = prefs.notificationsEnabled
        wasteReductionGoal = prefs.wasteReductionGoal
    }
    
    private func savePreferences() {
        if let prefs = preferences {
            prefs.dietaryRestrictions = Array(dietaryRestrictions)
            prefs.preferredCuisines = Array(preferredCuisines)
            prefs.maxPrepTime = maxPrepTime
            prefs.householdSize = householdSize
            prefs.skillLevel = skillLevel
            prefs.notificationsEnabled = notificationsEnabled
            prefs.wasteReductionGoal = wasteReductionGoal
        } else {
            let newPrefs = UserPreferences(
                dietaryRestrictions: Array(dietaryRestrictions),
                preferredCuisines: Array(preferredCuisines),
                maxPrepTime: maxPrepTime,
                householdSize: householdSize,
                skillLevel: skillLevel,
                notificationsEnabled: notificationsEnabled,
                wasteReductionGoal: wasteReductionGoal
            )
            modelContext.insert(newPrefs)
        }
        
        dismiss()
    }
}

struct DietaryTagToggle: View {
    let tag: DietaryTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                
                Text(tag.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CuisineTagToggle: View {
    let cuisine: CuisineType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(cuisine.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PreferencesView()
        .modelContainer(for: UserPreferences.self, inMemory: true)
} 