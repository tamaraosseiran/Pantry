//
//  PantryThemedView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

struct PantryThemedView: View {
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
            ZStack {
                // Pantry background
                pantryBackground
                
                VStack(spacing: 0) {
                    // Search and Filter Bar - only show when there are available ingredients
                    if !ingredients.filter({ !$0.isUsed }).isEmpty {
                        searchAndFilterSection
                    }
                    
                    // Pantry shelves
                    pantryContent
                }
            }
            .navigationTitle("My Pantry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Temporary button to clear all ingredients for testing
                        if !ingredients.isEmpty {
                            Button(action: {
                                for ingredient in ingredients {
                                    modelContext.delete(ingredient)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Button(action: { showingAddIngredient = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddIngredient) {
                AddIngredientView()
            }
        }
    }
    
    // MARK: - Computed Views
    private var pantryBackground: some View {
        Color(red: 0.95, green: 0.93, blue: 0.88)
            .ignoresSafeArea()
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            SearchBar(text: $searchText, placeholder: "Search ingredients...")
            
            categoryFilterScrollView
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var categoryFilterScrollView: some View {
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
    
    private var pantryContent: some View {
        Group {
            if filteredIngredients.isEmpty {
                EmptyPantryView()
            } else {
                pantryShelvesView
            }
        }
    }
    
    private var pantryShelvesView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(groupedIngredients.keys.sorted(), id: \.self) { category in
                    if let categoryIngredients = groupedIngredients[category] {
                        PantryShelfView(
                            category: category,
                            ingredients: categoryIngredients
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var groupedIngredients: [IngredientCategory: [Ingredient]] {
        Dictionary(grouping: filteredIngredients) { $0.category }
    }
}

struct PantryShelfView: View {
    let category: IngredientCategory
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(spacing: 0) {
            shelfLabel
            shelfSurface
            ingredientsGrid
        }
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var shelfLabel: some View {
        HStack {
            Text(category.rawValue)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.brown)
            
            Spacer()
            
            Text("\(ingredients.count) items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.8))
        .cornerRadius(8, corners: [.topLeft, .topRight])
    }
    
    private var shelfSurface: some View {
        Rectangle()
            .fill(Color(red: 0.8, green: 0.7, blue: 0.5))
            .frame(height: 4)
    }
    
    private var ingredientsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(ingredients) { ingredient in
                PantryItemView(ingredient: ingredient)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.6))
        .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
    }
    
    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)]
    }
}

struct PantryItemView: View {
    @Environment(\.modelContext) private var modelContext
    let ingredient: Ingredient
    @State private var showingEditSheet = false
    
    var body: some View {
        Button(action: { showingEditSheet = true }) {
            VStack(spacing: 8) {
                emojiContainer
                ingredientName
                quantityText
                expiryIndicator
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingEditSheet) {
            EditIngredientView(ingredient: ingredient)
        }
    }
    
    private var emojiContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(containerColor)
                .frame(width: 80, height: 80)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Text(ingredientEmoji)
                .font(.system(size: 32))
        }
    }
    
    private var ingredientName: some View {
        Text(ingredient.name)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
    
    private var quantityText: some View {
        Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var expiryIndicator: some View {
        if let expiryDate = ingredient.expiryDate {
            ExpiryIndicator(date: expiryDate)
        }
    }
    
    private var ingredientEmoji: String {
        // Map ingredient names to emojis
        let name = ingredient.name.lowercased()
        
        if name.contains("tomato") { return "🍅" }
        if name.contains("onion") { return "🧅" }
        if name.contains("garlic") { return "🧄" }
        if name.contains("potato") { return "🥔" }
        if name.contains("carrot") { return "🥕" }
        if name.contains("lettuce") { return "🥬" }
        if name.contains("spinach") { return "🥬" }
        if name.contains("broccoli") { return "🥦" }
        if name.contains("pepper") { return "🫑" }
        if name.contains("cucumber") { return "🥒" }
        if name.contains("mushroom") { return "🍄" }
        if name.contains("eggplant") { return "🍆" }
        if name.contains("apple") { return "🍎" }
        if name.contains("banana") { return "🍌" }
        if name.contains("orange") { return "🍊" }
        if name.contains("lemon") { return "🍋" }
        if name.contains("grape") { return "🍇" }
        if name.contains("strawberry") { return "🍓" }
        if name.contains("chicken") { return "🍗" }
        if name.contains("beef") { return "🥩" }
        if name.contains("fish") { return "🐟" }
        if name.contains("egg") { return "🥚" }
        if name.contains("milk") { return "🥛" }
        if name.contains("cheese") { return "🧀" }
        if name.contains("bread") { return "🍞" }
        if name.contains("pasta") { return "🍝" }
        if name.contains("rice") { return "🍚" }
        if name.contains("flour") { return "🌾" }
        if name.contains("sugar") { return "🍯" }
        if name.contains("salt") { return "🧂" }
        if name.contains("oil") { return "🫒" }
        if name.contains("basil") { return "🌿" }
        if name.contains("oregano") { return "🌿" }
        if name.contains("parsley") { return "🌿" }
        
        // Default emojis by category
        switch ingredient.category {
        case .vegetables: return "🥬"
        case .fruits: return "🍎"
        case .meat: return "🥩"
        case .dairy: return "🥛"
        case .grains: return "🌾"
        case .spices: return "🧂"
        case .condiments: return "🫒"
        case .beverages: return "🥤"
        case .frozen: return "🧊"
        case .canned: return "🥫"
        case .other: return "📦"
        }
    }
    
    private var containerColor: Color {
        switch ingredient.category {
        case .vegetables: return Color.green.opacity(0.2)
        case .fruits: return Color.red.opacity(0.2)
        case .meat: return Color.brown.opacity(0.2)
        case .dairy: return Color.blue.opacity(0.2)
        case .grains: return Color.yellow.opacity(0.2)
        case .spices: return Color.purple.opacity(0.2)
        case .condiments: return Color.orange.opacity(0.2)
        case .beverages: return Color.cyan.opacity(0.2)
        case .frozen: return Color.blue.opacity(0.2)
        case .canned: return Color.gray.opacity(0.2)
        case .other: return Color.gray.opacity(0.2)
        }
    }
}

struct ExpiryIndicator: View {
    let date: Date
    
    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    var indicatorColor: Color {
        if daysUntilExpiry < 0 {
            return .red
        } else if daysUntilExpiry <= 2 {
            return .red
        } else if daysUntilExpiry <= 5 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        Circle()
            .fill(indicatorColor)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PantryThemedView()
        .modelContainer(for: Ingredient.self, inMemory: true)
} 