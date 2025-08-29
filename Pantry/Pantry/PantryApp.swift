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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
