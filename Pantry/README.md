# Pantry - Food Waste Reduction App

A comprehensive iOS app built with SwiftUI and SwiftData to help users reduce food waste and make delicious meals with ingredients they already have at home.

## 📱 App Overview

Pantry is designed to tackle the global food waste problem by providing users with intelligent tools to:
- Track their pantry and fridge contents
- Get recipe suggestions based on available ingredients
- Monitor ingredient expiry dates
- Reduce food waste through smart meal planning

## 🚀 Key Features

### Core Functionality
- **Ingredient Management**: Add, edit, and track ingredients with expiry dates
- **Recipe Discovery**: Find recipes that use your available ingredients
- **Smart Scanning**: AI-powered ingredient detection from photos (simulated)
- **Voice Input**: Add ingredients using voice commands
- **Shopping Lists**: Generate lists for missing recipe ingredients

### Smart Features
- **Expiry Tracking**: Visual indicators for ingredients nearing expiration
- **Dietary Preferences**: Filter recipes by dietary restrictions
- **Cuisine Preferences**: Personalize recipe suggestions by cuisine type
- **Waste Reduction Goals**: Set and track food waste reduction targets

### User Experience
- **Modern UI**: Clean, intuitive interface with smooth animations
- **Category Filtering**: Organize ingredients by food categories
- **Search Functionality**: Quick ingredient and recipe search
- **Favorites System**: Save and organize favorite recipes

## 🛠️ Technical Stack

- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Architecture**: MVVM with SwiftData
- **Target**: iOS 17.0+
- **Language**: Swift 5.9+

## 📁 Project Structure

```
Pantry/
├── PantryApp.swift              # Main app entry point
├── ContentView.swift            # Main tab view and core views
├── Item.swift                   # Data models (Ingredient, Recipe, etc.)
├── IngredientRowView.swift      # Individual ingredient display
├── AddIngredientView.swift      # Add new ingredients
├── EditIngredientView.swift     # Edit existing ingredients
├── RecipeCardView.swift         # Recipe grid cards
├── RecipeDetailView.swift       # Detailed recipe view
├── PreferencesView.swift        # User preferences and settings
├── ImagePicker.swift            # Camera and photo library access
├── SampleDataService.swift      # Sample data for demonstration
└── Assets.xcassets/             # App icons and images
```

## 🏗️ Data Models

### Ingredient
- Name, quantity, unit, category
- Expiry date tracking
- Usage status (used/available)
- Optional notes and images

### Recipe
- Name, ingredients, instructions
- Prep/cook time, servings
- Cuisine type and difficulty level
- Dietary tags and favorites

### UserPreferences
- Dietary restrictions
- Preferred cuisines
- Cooking skill level
- Waste reduction goals

## 🎨 UI Components

### Custom Views
- `SearchBar`: Reusable search component
- `CategoryFilterButton`: Filter chips for categories
- `ExpiryBadge`: Visual expiry date indicators
- `RecipeCardView`: Grid-style recipe cards
- `DietaryTagToggle`: Preference selection toggles

### Navigation
- Tab-based navigation (Pantry, Recipes, Scan, Profile)
- Modal sheets for adding/editing
- Navigation links for detailed views

## 🔧 Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS 14.0+ for development

### Installation
1. Clone the repository
2. Open `Pantry.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run on simulator or device

### Camera Permissions
The app requires camera access for ingredient scanning. Add these to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Pantry needs camera access to scan ingredients</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Pantry needs photo library access to select ingredient images</string>
```

## 🚀 Future Enhancements

### AI Integration
- **Image Recognition**: Real AI-powered ingredient detection
- **Natural Language Processing**: Enhanced voice input
- **Recipe Recommendation Engine**: ML-based recipe suggestions

### Advanced Features
- **Barcode Scanning**: Scan product barcodes for automatic entry
- **Meal Planning**: Weekly meal planning with shopping lists
- **Social Features**: Share recipes and cooking achievements
- **Nutrition Tracking**: Calorie and nutrition information
- **Expiry Notifications**: Push notifications for expiring ingredients

### Platform Expansion
- **watchOS**: Quick ingredient checking and recipe viewing
- **macOS**: Desktop companion app
- **Web Dashboard**: Recipe management and analytics

## 🎯 MVP Features Implemented

✅ **Core Ingredient Management**
- Add, edit, delete ingredients
- Category organization
- Expiry date tracking
- Usage status tracking

✅ **Recipe System**
- Recipe database with sample data
- Ingredient matching
- Detailed recipe views
- Shopping list generation

✅ **User Interface**
- Modern SwiftUI design
- Tab-based navigation
- Search and filtering
- Responsive layouts

✅ **Data Persistence**
- SwiftData integration
- Automatic data saving
- Sample data population

✅ **Camera Integration**
- Photo capture and selection
- Image picker implementation
- Simulated AI detection

## 🔮 Next Steps

1. **AI Integration**: Implement real image recognition using Vision framework
2. **Recipe API**: Connect to external recipe databases
3. **Notifications**: Add local notifications for expiry alerts
4. **Testing**: Comprehensive unit and UI tests
5. **Performance**: Optimize for large ingredient databases
6. **Accessibility**: VoiceOver and accessibility improvements

## 📄 License

This project is created for educational and demonstration purposes.

## 🤝 Contributing

This is a demonstration project showcasing modern iOS development practices with SwiftUI and SwiftData.

---

**Built with ❤️ using SwiftUI and SwiftData** 