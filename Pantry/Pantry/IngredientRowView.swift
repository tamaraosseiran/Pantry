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
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: ingredient.category.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // Ingredient Info
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let expiryDate = ingredient.expiryDate {
                        Spacer()
                        ExpiryBadge(date: expiryDate)
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                
                Button(action: markAsUsed) {
                    Image(systemName: ingredient.isUsed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(ingredient.isUsed ? .green : .gray)
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditSheet) {
            EditIngredientView(ingredient: ingredient)
        }
    }
    
    private func markAsUsed() {
        withAnimation {
            ingredient.isUsed.toggle()
        }
    }
}

struct ExpiryBadge: View {
    let date: Date
    
    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    var badgeColor: Color {
        if daysUntilExpiry < 0 {
            return .red
        } else if daysUntilExpiry <= 3 {
            return .orange
        } else if daysUntilExpiry <= 7 {
            return .yellow
        } else {
            return .green
        }
    }
    
    var badgeText: String {
        if daysUntilExpiry < 0 {
            return "Expired"
        } else if daysUntilExpiry == 0 {
            return "Today"
        } else if daysUntilExpiry == 1 {
            return "1 day"
        } else {
            return "\(daysUntilExpiry) days"
        }
    }
    
    var body: some View {
        Text(badgeText)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(8)
    }
}

#Preview {
    let ingredient = Ingredient(name: "Tomato", quantity: 3, unit: "pieces", category: .vegetables, expiryDate: Date().addingTimeInterval(86400 * 2))
    return IngredientRowView(ingredient: ingredient)
        .padding()
} 