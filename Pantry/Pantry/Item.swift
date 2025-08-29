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
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var category: IngredientCategory
    var expiryDate: Date?
    var isUsed: Bool
    var dateAdded: Date
    var imageData: Data?
    var notes: String?
    
    init(name: String, quantity: Double = 1.0, unit: String = "piece", category: IngredientCategory = .other, expiryDate: Date? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.expiryDate = expiryDate
        self.isUsed = false
        self.dateAdded = Date()
        self.notes = notes
    }
}

// MARK: - Recipe Model
@Model
final class Recipe {
    var id: UUID
    var name: String
    var ingredients: [RecipeIngredient]
    var instructions: [String]
    var prepTime: Int // in minutes
    var cookTime: Int // in minutes
    var servings: Int
    var cuisine: CuisineType
    var difficulty: DifficultyLevel
    var dietaryTags: [DietaryTag]
    var imageURL: String?
    var isFavorite: Bool
    var dateCreated: Date
    
    init(name: String, ingredients: [RecipeIngredient] = [], instructions: [String] = [], prepTime: Int = 0, cookTime: Int = 0, servings: Int = 1, cuisine: CuisineType = .other, difficulty: DifficultyLevel = .easy, dietaryTags: [DietaryTag] = []) {
        self.id = UUID()
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.dietaryTags = dietaryTags
        self.isFavorite = false
        self.dateCreated = Date()
    }
}

// MARK: - Recipe Ingredient Model
@Model
final class RecipeIngredient {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var isOptional: Bool
    
    init(name: String, quantity: Double, unit: String, isOptional: Bool = false) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isOptional = isOptional
    }
}

// MARK: - User Preferences Model
@Model
final class UserPreferences {
    var id: UUID
    var dietaryRestrictions: [DietaryTag]
    var preferredCuisines: [CuisineType]
    var maxPrepTime: Int? // in minutes
    var householdSize: Int
    var skillLevel: DifficultyLevel
    var notificationsEnabled: Bool
    var wasteReductionGoal: Int // target percentage
    
    init(dietaryRestrictions: [DietaryTag] = [], preferredCuisines: [CuisineType] = [], maxPrepTime: Int? = nil, householdSize: Int = 1, skillLevel: DifficultyLevel = .easy, notificationsEnabled: Bool = true, wasteReductionGoal: Int = 20) {
        self.id = UUID()
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
enum IngredientCategory: String, CaseIterable, Codable {
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
