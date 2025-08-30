//
//  Item.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import Foundation
import SwiftData

// MARK: - Ingredient Model
@Model
final class Ingredient {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double = 1.0
    var unit: String = "piece"
    var category: IngredientCategory = IngredientCategory.other
    var expiryDate: Date?
    var isUsed: Bool = false
    var dateAdded: Date = Date()
    var imageData: Data?
    var notes: String?
    
    // Inverse relationship for recipes that use this ingredient
    @Relationship(inverse: \RecipeIngredient.ingredient)
    var recipeIngredients: [RecipeIngredient]?
    
    init(name: String, quantity: Double = 1.0, unit: String = "piece", category: IngredientCategory = .other, expiryDate: Date? = nil, notes: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.expiryDate = expiryDate
        self.notes = notes
    }
}

// MARK: - Recipe Model
@Model
final class Recipe {
    var id: UUID = UUID()
    var name: String = ""
    var instructions: [String]?
    var prepTime: Int = 0 // in minutes
    var cookTime: Int = 0 // in minutes
    var servings: Int = 1
    var cuisine: CuisineType = CuisineType.other
    var difficulty: DifficultyLevel = DifficultyLevel.easy
    var dietaryTags: [DietaryTag]?
    var imageURL: String?
    var isFavorite: Bool = false
    var dateCreated: Date = Date()
    
    // Inverse relationship for recipe ingredients
    @Relationship(inverse: \RecipeIngredient.recipe)
    var ingredients: [RecipeIngredient]?
    
    init(name: String, ingredients: [RecipeIngredient] = [], instructions: [String] = [], prepTime: Int = 0, cookTime: Int = 0, servings: Int = 1, cuisine: CuisineType = .other, difficulty: DifficultyLevel = .easy, dietaryTags: [DietaryTag] = []) {
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.dietaryTags = dietaryTags
    }
}

// MARK: - Recipe Ingredient Model
@Model
final class RecipeIngredient {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double = 0.0
    var unit: String = ""
    var isOptional: Bool = false
    
    // Relationship to the actual ingredient
    var ingredient: Ingredient?
    
    // Relationship to the recipe
    var recipe: Recipe?
    
    init(name: String, quantity: Double, unit: String, isOptional: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isOptional = isOptional
    }
}

// MARK: - User Preferences Model
@Model
final class UserPreferences {
    var id: UUID = UUID()
    var dietaryRestrictions: [DietaryTag]?
    var preferredCuisines: [CuisineType]?
    var maxPrepTime: Int? // in minutes
    var householdSize: Int = 1
    var skillLevel: DifficultyLevel = DifficultyLevel.easy
    var notificationsEnabled: Bool = true
    var wasteReductionGoal: Int = 20 // target percentage
    
    init(dietaryRestrictions: [DietaryTag] = [], preferredCuisines: [CuisineType] = [], maxPrepTime: Int? = nil, householdSize: Int = 1, skillLevel: DifficultyLevel = .easy, notificationsEnabled: Bool = true, wasteReductionGoal: Int = 20) {
        self.dietaryRestrictions = dietaryRestrictions
        self.preferredCuisines = preferredCuisines
        self.maxPrepTime = maxPrepTime
        self.householdSize = householdSize
        self.skillLevel = skillLevel
        self.notificationsEnabled = notificationsEnabled
        self.wasteReductionGoal = wasteReductionGoal
    }
}

// MARK: - Enums
enum IngredientCategory: String, CaseIterable, Codable, Comparable {
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case meat = "Meat"
    case dairy = "Dairy"
    case grains = "Grains"
    case spices = "Spices"
    case condiments = "Condiments"
    case beverages = "Beverages"
    case frozen = "Frozen"
    case canned = "Canned"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .vegetables: return "leaf.fill"
        case .fruits: return "applelogo"
        case .meat: return "fish.fill"
        case .dairy: return "drop.fill"
        case .grains: return "circle.fill"
        case .spices: return "sparkles"
        case .condiments: return "bottle.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .frozen: return "snowflake"
        case .canned: return "cylinder.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    // MARK: - Comparable
    static func < (lhs: IngredientCategory, rhs: IngredientCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum CuisineType: String, CaseIterable, Codable {
    case italian = "Italian"
    case mexican = "Mexican"
    case chinese = "Chinese"
    case indian = "Indian"
    case japanese = "Japanese"
    case mediterranean = "Mediterranean"
    case american = "American"
    case french = "French"
    case thai = "Thai"
    case other = "Other"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}

enum DietaryTag: String, CaseIterable, Codable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    case lowCarb = "Low-Carb"
    case keto = "Keto"
    case paleo = "Paleo"
    case halal = "Halal"
    case kosher = "Kosher"
}
