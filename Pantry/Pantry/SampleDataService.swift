//
//  SampleDataService.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

class SampleDataService {
    static func addSampleData(to modelContext: ModelContext) {
        // Add sample ingredients
        let sampleIngredients = [
            Ingredient(name: "Tomato", quantity: 4, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 3)),
            Ingredient(name: "Onion", quantity: 2, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 7)),
            Ingredient(name: "Garlic", quantity: 1, unit: "head", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 14)),
            Ingredient(name: "Olive Oil", quantity: 500, unit: "ml", category: .condiments),
            Ingredient(name: "Pasta", quantity: 500, unit: "g", category: .grains),
            Ingredient(name: "Eggs", quantity: 6, unit: "pieces", category: .dairy, expiryDate: Date().addingTimeInterval(86400 * 5)),
            Ingredient(name: "Parmesan", quantity: 200, unit: "g", category: .dairy, expiryDate: Date().addingTimeInterval(86400 * 10)),
            Ingredient(name: "Basil", quantity: 1, unit: "bunch", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 2)),
            Ingredient(name: "Chicken Breast", quantity: 400, unit: "g", category: .meat, expiryDate: Date().addingTimeInterval(86400 * 1)),
            Ingredient(name: "Rice", quantity: 1, unit: "kg", category: .grains),
            Ingredient(name: "Bell Pepper", quantity: 3, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 4)),
            Ingredient(name: "Mushrooms", quantity: 250, unit: "g", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 2))
        ]
        
        for ingredient in sampleIngredients {
            modelContext.insert(ingredient)
        }
        
        // Add sample recipes
        let sampleRecipes = [
            Recipe(
                name: "Pasta Carbonara",
                ingredients: [
                    RecipeIngredient(name: "Pasta", quantity: 200, unit: "g"),
                    RecipeIngredient(name: "Eggs", quantity: 2, unit: "pieces"),
                    RecipeIngredient(name: "Parmesan", quantity: 50, unit: "g"),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: "cloves"),
                    RecipeIngredient(name: "Olive Oil", quantity: 30, unit: "ml"),
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
            ),
            
            Recipe(
                name: "Simple Tomato Sauce",
                ingredients: [
                    RecipeIngredient(name: "Tomato", quantity: 4, unit: "pieces"),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: "piece"),
                    RecipeIngredient(name: "Garlic", quantity: 3, unit: "cloves"),
                    RecipeIngredient(name: "Olive Oil", quantity: 30, unit: "ml"),
                    RecipeIngredient(name: "Basil", quantity: 1, unit: "bunch")
                ],
                instructions: [
                    "Dice tomatoes, onion, and garlic",
                    "Heat olive oil in a large pan over medium heat",
                    "Sauté onion until translucent, about 5 minutes",
                    "Add garlic and cook for 1 minute until fragrant",
                    "Add tomatoes and cook for 15-20 minutes until thickened",
                    "Stir in chopped basil and season with salt and pepper"
                ],
                prepTime: 15,
                cookTime: 20,
                servings: 4,
                cuisine: .italian,
                difficulty: .easy,
                dietaryTags: [.vegetarian, .vegan, .glutenFree]
            ),
            
            Recipe(
                name: "Stir-Fried Chicken with Vegetables",
                ingredients: [
                    RecipeIngredient(name: "Chicken Breast", quantity: 400, unit: "g"),
                    RecipeIngredient(name: "Bell Pepper", quantity: 2, unit: "pieces"),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: "piece"),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: "cloves"),
                    RecipeIngredient(name: "Mushrooms", quantity: 200, unit: "g"),
                    RecipeIngredient(name: "Olive Oil", quantity: 30, unit: "ml"),
                    RecipeIngredient(name: "Soy Sauce", quantity: 60, unit: "ml", isOptional: true)
                ],
                instructions: [
                    "Cut chicken into bite-sized pieces",
                    "Slice bell peppers, onion, and mushrooms",
                    "Heat oil in a wok or large pan over high heat",
                    "Stir-fry chicken until golden brown, about 5 minutes",
                    "Add vegetables and stir-fry for 3-4 minutes",
                    "Add soy sauce and cook for 1 minute more",
                    "Serve hot with rice"
                ],
                prepTime: 15,
                cookTime: 10,
                servings: 4,
                cuisine: .chinese,
                difficulty: .easy,
                dietaryTags: [.glutenFree]
            ),
            
            Recipe(
                name: "Mushroom Risotto",
                ingredients: [
                    RecipeIngredient(name: "Rice", quantity: 300, unit: "g"),
                    RecipeIngredient(name: "Mushrooms", quantity: 300, unit: "g"),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: "piece"),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: "cloves"),
                    RecipeIngredient(name: "Olive Oil", quantity: 30, unit: "ml"),
                    RecipeIngredient(name: "Parmesan", quantity: 100, unit: "g"),
                    RecipeIngredient(name: "Vegetable Stock", quantity: 1, unit: "liter", isOptional: true)
                ],
                instructions: [
                    "Sauté chopped onion and garlic in olive oil",
                    "Add mushrooms and cook until golden",
                    "Add rice and stir for 1 minute",
                    "Gradually add hot stock, stirring constantly",
                    "Cook for 18-20 minutes until rice is creamy",
                    "Stir in parmesan and serve immediately"
                ],
                prepTime: 10,
                cookTime: 25,
                servings: 4,
                cuisine: .italian,
                difficulty: .medium,
                dietaryTags: [.vegetarian]
            ),
            
            Recipe(
                name: "Quick Vegetable Soup",
                ingredients: [
                    RecipeIngredient(name: "Tomato", quantity: 2, unit: "pieces"),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: "piece"),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: "cloves"),
                    RecipeIngredient(name: "Bell Pepper", quantity: 1, unit: "piece"),
                    RecipeIngredient(name: "Olive Oil", quantity: 15, unit: "ml"),
                    RecipeIngredient(name: "Vegetable Stock", quantity: 1, unit: "liter", isOptional: true)
                ],
                instructions: [
                    "Dice all vegetables",
                    "Heat oil in a large pot",
                    "Sauté onion and garlic for 3 minutes",
                    "Add remaining vegetables and cook for 5 minutes",
                    "Add stock and bring to boil",
                    "Simmer for 15 minutes until vegetables are tender",
                    "Season with salt and pepper"
                ],
                prepTime: 10,
                cookTime: 20,
                servings: 4,
                cuisine: .mediterranean,
                difficulty: .easy,
                dietaryTags: [.vegetarian, .vegan, .glutenFree]
            )
        ]
        
        for recipe in sampleRecipes {
            modelContext.insert(recipe)
        }
    }
} 