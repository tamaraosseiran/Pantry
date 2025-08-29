//
//  RecipeDetailView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var ingredients: [Ingredient]
    
    let recipe: Recipe
    @State private var showingShoppingList = false
    
    var availableIngredients: [String] {
        ingredients.filter { !$0.isUsed }.map { $0.name.lowercased() }
    }
    
    var missingIngredients: [RecipeIngredient] {
        recipe.ingredients.filter { ingredient in
            !availableIngredients.contains(ingredient.name.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recipe Header
                    VStack(alignment: .leading, spacing: 12) {
                        // Recipe Image Placeholder
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(2, contentMode: .fit)
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(16)
                        
                        // Recipe Title and Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 16) {
                                RecipeInfoBadge(icon: "clock", text: "\(recipe.prepTime + recipe.cookTime) min")
                                RecipeInfoBadge(icon: "person.2", text: "\(recipe.servings) servings")
                                RecipeInfoBadge(icon: "flag", text: recipe.cuisine.rawValue)
                            }
                            
                            // Difficulty and Dietary Tags
                            HStack {
                                Text(recipe.difficulty.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(difficultyColor.opacity(0.1))
                                    .foregroundColor(difficultyColor)
                                    .cornerRadius(12)
                                
                                Spacer()
                                
                                if !recipe.dietaryTags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(recipe.dietaryTags, id: \.self) { tag in
                                                Text(tag.rawValue)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.green.opacity(0.1))
                                                    .foregroundColor(.green)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            if !missingIngredients.isEmpty {
                                Button("Shopping List") {
                                    showingShoppingList = true
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(recipe.ingredients) { ingredient in
                                IngredientRow(
                                    ingredient: ingredient,
                                    isAvailable: availableIngredients.contains(ingredient.name.lowercased())
                                )
                            }
                        }
                    }
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                    
                                    Text(instruction)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: startCooking) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Cooking")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: toggleFavorite) {
                            HStack {
                                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                Text(recipe.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                            }
                            .font(.headline)
                            .foregroundColor(recipe.isFavorite ? .red : .blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((recipe.isFavorite ? Color.red : Color.blue).opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShoppingList) {
                ShoppingListView(missingIngredients: missingIngredients)
            }
        }
    }
    
    private var difficultyColor: Color {
        switch recipe.difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    private func startCooking() {
        // TODO: Implement cooking mode
        print("Starting cooking mode for \(recipe.name)")
    }
    
    private func toggleFavorite() {
        recipe.isFavorite.toggle()
    }
}

struct RecipeInfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

struct IngredientRow: View {
    let ingredient: RecipeIngredient
    let isAvailable: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isAvailable ? .green : .gray)
            
            Text(ingredient.name)
                .strikethrough(!isAvailable)
                .foregroundColor(isAvailable ? .primary : .secondary)
            
            Spacer()
            
            Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if ingredient.isOptional {
                Text("(optional)")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ShoppingListView: View {
    @Environment(\.dismiss) private var dismiss
    let missingIngredients: [RecipeIngredient]
    
    var body: some View {
        NavigationView {
            VStack {
                if missingIngredients.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("You have all ingredients!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("You're ready to start cooking")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        Section("Missing Ingredients") {
                            ForEach(missingIngredients) { ingredient in
                                HStack {
                                    Image(systemName: "circle")
                                        .foregroundColor(.orange)
                                    
                                    Text(ingredient.name)
                                    
                                    Spacer()
                                    
                                    Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shopping List")
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
}

#Preview {
    let recipe = Recipe(
        name: "Pasta Carbonara",
        ingredients: [
            RecipeIngredient(name: "Pasta", quantity: 200, unit: "g"),
            RecipeIngredient(name: "Eggs", quantity: 2, unit: "pieces"),
            RecipeIngredient(name: "Parmesan", quantity: 50, unit: "g"),
            RecipeIngredient(name: "Bacon", quantity: 100, unit: "g", isOptional: true)
        ],
        instructions: [
            "Bring a large pot of salted water to boil",
            "Cook pasta according to package directions",
            "In a bowl, whisk together eggs and grated parmesan",
            "Cook bacon until crispy, then drain on paper towels",
            "Drain pasta, reserving 1 cup of pasta water",
            "Add hot pasta to egg mixture, stirring quickly to create a creamy sauce",
            "Add bacon and serve immediately"
        ],
        prepTime: 10,
        cookTime: 15,
        servings: 2,
        cuisine: .italian,
        difficulty: .medium,
        dietaryTags: [.vegetarian]
    )
    
    return RecipeDetailView(recipe: recipe)
} 