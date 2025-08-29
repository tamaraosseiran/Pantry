//
//  IngredientRowView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct IngredientRowView: View {
    @Environment(\.modelContext) private var modelContext
    let ingredient: Ingredient
    @State private var showingEditSheet = false
    
    var body: some View {
        Button(action: { showingEditSheet = true }) {
            HStack(spacing: 16) {
                // Ingredient Image/Icon
                IngredientImageView(ingredient: ingredient)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Ingredient Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(ingredient.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Expiry Status
                        if let expiryDate = ingredient.expiryDate {
                            ExpiryStatusView(date: expiryDate)
                        }
                    }
                    
                    // Category Badge
                    HStack {
                        CategoryBadge(category: ingredient.category)
                        
                        Spacer()
                        
                        // Usage Status
                        UsageStatusView(isUsed: ingredient.isUsed)
                    }
                }
                
                Spacer()
                
                // Edit indicator (subtle)
                Image(systemName: "pencil.circle")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.6))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingEditSheet) {
            EditIngredientView(ingredient: ingredient)
        }
    }
}

// MARK: - Ingredient Image View
struct IngredientImageView: View {
    let ingredient: Ingredient
    
    var body: some View {
        Group {
            if let imageData = ingredient.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback to beautiful category illustrations
                CategoryIllustration(category: ingredient.category)
            }
        }
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Category Illustrations
struct CategoryIllustration: View {
    let category: IngredientCategory
    
    var body: some View {
        ZStack {
            // Background gradient based on category
            LinearGradient(
                gradient: categoryGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Category icon
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    private var categoryGradient: Gradient {
        switch category {
        case .vegetables:
            return Gradient(colors: [Color.green, Color.green.opacity(0.7)])
        case .fruits:
            return Gradient(colors: [Color.red, Color.orange])
        case .meat:
            return Gradient(colors: [Color.brown, Color.red.opacity(0.8)])
        case .dairy:
            return Gradient(colors: [Color.blue, Color.blue.opacity(0.7)])
        case .grains:
            return Gradient(colors: [Color.yellow, Color.orange])
        case .spices:
            return Gradient(colors: [Color.purple, Color.pink])
        case .condiments:
            return Gradient(colors: [Color.orange, Color.red])
        case .beverages:
            return Gradient(colors: [Color.cyan, Color.blue])
        case .frozen:
            return Gradient(colors: [Color.blue, Color.cyan])
        case .canned:
            return Gradient(colors: [Color.gray, Color.gray.opacity(0.7)])
        case .other:
            return Gradient(colors: [Color.gray, Color.gray.opacity(0.7)])
        }
    }
}

// MARK: - Expiry Status View
struct ExpiryStatusView: View {
    let date: Date
    
    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    var statusColor: Color {
        if daysUntilExpiry < 0 {
            return .red
        } else if daysUntilExpiry <= 2 {
            return .red
        } else if daysUntilExpiry <= 5 {
            return .orange
        } else if daysUntilExpiry <= 10 {
            return .yellow
        } else {
            return .green
        }
    }
    
    var statusIcon: String {
        if daysUntilExpiry < 0 {
            return "exclamationmark.triangle.fill"
        } else if daysUntilExpiry <= 2 {
            return "exclamationmark.circle.fill"
        } else if daysUntilExpiry <= 5 {
            return "clock.fill"
        } else if daysUntilExpiry <= 10 {
            return "clock"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    var statusText: String {
        if daysUntilExpiry < 0 {
            return "Expired"
        } else if daysUntilExpiry == 0 {
            return "Expires today"
        } else if daysUntilExpiry == 1 {
            return "Expires tomorrow"
        } else if daysUntilExpiry <= 7 {
            return "\(daysUntilExpiry) days left"
        } else {
            return "Fresh"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption)
                .foregroundColor(statusColor)
            
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: IngredientCategory
    
    var body: some View {
        Text(category.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(categoryColor.opacity(0.1))
            .foregroundColor(categoryColor)
            .cornerRadius(6)
    }
    
    private var categoryColor: Color {
        switch category {
        case .vegetables: return .green
        case .fruits: return .red
        case .meat: return .brown
        case .dairy: return .blue
        case .grains: return .yellow
        case .spices: return .purple
        case .condiments: return .orange
        case .beverages: return .cyan
        case .frozen: return .blue
        case .canned: return .gray
        case .other: return .gray
        }
    }
}

// MARK: - Usage Status View
struct UsageStatusView: View {
    let isUsed: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isUsed ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Text(isUsed ? "Used" : "Available")
                .font(.caption2)
                .foregroundColor(isUsed ? .green : .secondary)
        }
    }
}

#Preview {
    let ingredient = Ingredient(name: "Fresh Tomatoes", quantity: 4, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 2))
    return IngredientRowView(ingredient: ingredient)
        .padding()
} 