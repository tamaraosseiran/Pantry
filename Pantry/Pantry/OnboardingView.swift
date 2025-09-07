//
//  OnboardingView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Pantry",
            subtitle: "Your smart kitchen companion",
            description: "Reduce food waste and discover delicious recipes using ingredients you already have.",
            icon: "cabinet.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Scan & Add",
            subtitle: "Smart ingredient detection",
            description: "Take photos of your fridge or pantry to automatically detect and add ingredients.",
            icon: "camera.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Recipe Discovery",
            subtitle: "Cook with what you have",
            description: "Find recipes that match your available ingredients and dietary preferences.",
            icon: "book.closed.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Reduce Waste",
            subtitle: "Track expiry dates",
            description: "Never let ingredients go to waste with smart expiry tracking and recipe suggestions.",
            icon: "leaf.fill",
            color: .purple
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? pages[index].color : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                            if currentPage == pages.count - 1 {
                                onComplete()
                            } else {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(pages[currentPage].color)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView(onComplete: {})
} 