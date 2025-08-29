//
//  ContentView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ingredients: [Ingredient]
    @Query private var recipes: [Recipe]
    @Query private var userPreferences: [UserPreferences]
    
    var body: some View {
        TabView {
            PantryThemedView()
                .tabItem {
                    Label("Pantry", systemImage: "cabinet")
                }
            
            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "book.closed")
                }
            
            EnhancedCameraView()
                .tabItem {
                    Label("AI Scan", systemImage: "camera")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .onAppear {
            setupDefaultPreferences()
        }
    }
    
    private func setupDefaultPreferences() {
        if userPreferences.isEmpty {
            let preferences = UserPreferences()
            modelContext.insert(preferences)
        }
        
        // Add sample data if no ingredients exist
        if ingredients.isEmpty {
            SampleDataService.addSampleData(to: modelContext)
        }
    }
}

// MARK: - Pantry View
struct PantryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ingredients: [Ingredient]
    @State private var showingAddIngredient = false
    @State private var searchText = ""
    @State private var selectedCategory: IngredientCategory?
    
    var filteredIngredients: [Ingredient] {
        var filtered = ingredients.filter { !$0.isUsed }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText, placeholder: "Search ingredients...")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryFilterButton(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(IngredientCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Ingredients List
                if filteredIngredients.isEmpty {
                    EmptyPantryView()
                } else {
                    List {
                        ForEach(filteredIngredients) { ingredient in
                            IngredientRowView(ingredient: ingredient)
                                .onTapGesture {
                                    // Open edit sheet on tap
                                    // We'll handle this in the IngredientRowView
                                }
                        }
                        .onDelete(perform: deleteIngredients)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Pantry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddIngredient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIngredient) {
                AddIngredientView()
            }
        }
    }
    
    private func deleteIngredients(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredIngredients[index])
            }
        }
    }
}

// MARK: - Recipes View
struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ingredients: [Ingredient]
    @Query private var recipes: [Recipe]
    @State private var searchText = ""
    @State private var selectedCuisine: CuisineType?
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var showingRecipeDetail = false
    @State private var selectedRecipe: Recipe?
    
    var availableIngredients: [String] {
        ingredients.filter { !$0.isUsed }.map { $0.name.lowercased() }
    }
    
    var filteredRecipes: [Recipe] {
        var filtered = recipes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let cuisine = selectedCuisine {
            filtered = filtered.filter { $0.cuisine == cuisine }
        }
        
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        return filtered.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText, placeholder: "Search recipes...")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedCuisine == nil && selectedDifficulty == nil) {
                                selectedCuisine = nil
                                selectedDifficulty = nil
                            }
                            
                            ForEach(CuisineType.allCases, id: \.self) { cuisine in
                                FilterChip(
                                    title: cuisine.rawValue,
                                    isSelected: selectedCuisine == cuisine
                                ) {
                                    selectedCuisine = selectedCuisine == cuisine ? nil : cuisine
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Recipes List
                if filteredRecipes.isEmpty {
                    EmptyRecipesView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredRecipes) { recipe in
                                RecipeCardView(recipe: recipe) {
                                    selectedRecipe = recipe
                                    showingRecipeDetail = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Surprise Me") {
                        // TODO: Implement surprise me feature
                    }
                }
            }
            .sheet(isPresented: $showingRecipeDetail) {
                if let recipe = selectedRecipe {
                    RecipeDetailView(recipe: recipe)
                }
            }
        }
    }
}

// MARK: - Camera View
struct CameraView: View {
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var inputImage: UIImage?
    @State private var detectedIngredients: [String] = []
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Camera Icon
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Scan Your Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Take a photo of your fridge or pantry to automatically detect ingredients")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
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
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Detected Ingredients
                if !detectedIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detected Ingredients:")
                            .font(.headline)
                        
                        ForEach(detectedIngredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(ingredient)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                if isProcessing {
                    ProgressView("Processing image...")
                        .padding()
                }
            }
            .navigationTitle("Scan Ingredients")
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $inputImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage, sourceType: .photoLibrary)
            }
            .onChange(of: inputImage) { _, newImage in
                if let image = newImage {
                    processImage(image)
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        isProcessing = true
        // TODO: Implement AI image recognition
        // For now, simulate detection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            detectedIngredients = ["Tomato", "Onion", "Garlic", "Olive Oil"]
            isProcessing = false
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    @State private var showingPreferences = false
    
    var preferences: UserPreferences? {
        userPreferences.first
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Personal Info") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Your Pantry")
                                .font(.headline)
                            Text("Food waste reduction champion")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Statistics") {
                    StatRow(title: "Ingredients Saved", value: "24", icon: "leaf.fill", color: .green)
                    StatRow(title: "Recipes Created", value: "12", icon: "book.fill", color: .blue)
                    StatRow(title: "Waste Reduced", value: "35%", icon: "chart.line.uptrend.xyaxis", color: .orange)
                }
                
                Section("Settings") {
                    NavigationLink(destination: PreferencesView()) {
                        Label("Preferences", systemImage: "gear")
                    }
                    
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("Help & Support")) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Supporting Views
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct EmptyPantryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cabinet")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your pantry is empty")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add some ingredients to get started")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct EmptyRecipesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No recipes yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start adding ingredients to discover recipes")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Ingredient.self, Recipe.self, RecipeIngredient.self, UserPreferences.self], inMemory: true)
}
