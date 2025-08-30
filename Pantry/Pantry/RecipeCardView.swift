//
//  RecipeCardView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct RecipeCardView: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Recipe Image Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(12)
                
                // Recipe Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    HStack {
                        // Cuisine Badge
                        Text(recipe.cuisine.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        // Difficulty Badge
                        Text(recipe.difficulty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(difficultyColor.opacity(0.1))
                            .foregroundColor(difficultyColor)
                            .cornerRadius(8)
                    }
                    
                    // Time and Servings
                    HStack {
                        Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label("\(recipe.servings) servings", systemImage: "person.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Dietary Tags
                    if let dietaryTags = recipe.dietaryTags, !dietaryTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(dietaryTags.prefix(2), id: \.self) { tag in
                                    Text(tag.rawValue)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .cornerRadius(6)
                                }
                                
                                if dietaryTags.count > 2 {
                                    Text("+\(dietaryTags.count - 2)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
}

#Preview {
    let recipe = Recipe(
        name: "Pasta Carbonara",
        ingredients: [
            RecipeIngredient(name: "Pasta", quantity: 200, unit: "g"),
            RecipeIngredient(name: "Eggs", quantity: 2, unit: "pieces"),
            RecipeIngredient(name: "Parmesan", quantity: 50, unit: "g")
        ],
        instructions: ["Boil pasta", "Mix eggs and cheese", "Combine"],
        prepTime: 10,
        cookTime: 15,
        servings: 2,
        cuisine: .italian,
        difficulty: .medium,
        dietaryTags: [.vegetarian]
    )
    
    return RecipeCardView(recipe: recipe) {
        print("Recipe tapped")
    }
    .padding()
} 