//
//  PantryApp.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI
import SwiftData

@main
struct PantryApp: App {
    @State private var showingLaunchScreen = true
    @State private var showingOnboarding = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Ingredient.self,
            Recipe.self,
            RecipeIngredient.self,
            UserPreferences.self,
        ])
        
        // Use different configuration for preview vs production
        #if DEBUG
        // For previews, use a completely separate in-memory configuration
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        #else
        // For production, use CloudKit
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
        #endif

        do {
            return try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showingLaunchScreen {
                    LaunchScreen()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showingLaunchScreen = false
                                    if !hasSeenOnboarding {
                                        showingOnboarding = true
                                    }
                                }
                            }
                        }
                } else if showingOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                        .onDisappear {
                            hasSeenOnboarding = true
                        }
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
