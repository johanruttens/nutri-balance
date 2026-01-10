# NutriBalance

**Balance your nutrition, transform your life.**
*Balanceer je voeding, transformeer je leven.*

NutriBalance is a comprehensive iOS food and beverage tracking app designed to help users maintain healthy eating habits and achieve sustainable weight loss goals.

## Features

### Core Functionality
- **Food Tracking**: Log meals across 7 categories (Breakfast, Morning Snack, Lunch, Afternoon Snack, Dinner, Evening Snack, Other)
- **Hydration Tracking**: Monitor water and beverage intake with smart hydration calculations
- **Weight Tracking**: Track weight progress with trend analysis and goal visualization
- **Smart Autofill**: Quickly log foods with favorites, recent items, and intelligent suggestions
- **PDF Export**: Generate professional reports for dietitian consultations

### Analytics & Insights
- Daily, weekly, and monthly dashboards
- Calorie and macro tracking
- Progress visualization with charts
- Achievement system for motivation

### Design
- Clean, minimalist interface
- Vibrant teal accent (#00BFA5) with colorful meal category indicators
- Full accessibility support (VoiceOver, Dynamic Type)
- Bilingual support: English and Dutch (Nederlands)

## Technical Requirements

- **Platform**: iOS 16.0+
- **Device**: iPhone only (Portrait mode)
- **Framework**: SwiftUI with Swift 5.9+
- **Architecture**: MVVM with Clean Architecture
- **Persistence**: Core Data (local storage)

## Project Structure

```
NutriBalance/
├── App/                    # App entry point and configuration
├── Core/                   # Extensions and utilities
├── Data/                   # Core Data and repositories
│   ├── CoreData/          # Entities and persistence
│   ├── Repositories/      # Data access layer
│   └── Mappers/           # Domain ↔ Entity mapping
├── Domain/                 # Business logic
│   ├── Models/            # Domain models
│   ├── UseCases/          # Business operations
│   └── Interfaces/        # Repository protocols
├── Presentation/           # UI layer
│   ├── Theme/             # Colors, typography, styling
│   ├── Components/        # Reusable UI components
│   ├── Screens/           # Feature screens
│   └── Navigation/        # App navigation
├── Services/              # PDF generation, notifications
└── Resources/             # Assets, localization
```

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ simulator or device
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/johanruttens/nutri-balance.git
cd nutri-balance
```

2. Open the project in Xcode:
```bash
open Package.swift
```

3. Build and run (⌘R)

### Running Tests

```bash
# Unit tests
xcodebuild test -scheme NutriBalance -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme NutriBalanceUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

NutriBalance follows **MVVM + Clean Architecture** principles:

- **Presentation Layer**: SwiftUI Views + ViewModels
- **Domain Layer**: Use Cases + Domain Models + Repository Protocols
- **Data Layer**: Repository Implementations + Core Data + Mappers

### Key Patterns
- **Dependency Injection**: Centralized container for testability
- **Repository Pattern**: Abstract data access
- **Use Cases**: Single-responsibility business operations
- **Async/Await**: Modern Swift concurrency

## Localization

The app supports:
- **English (en)** - Default
- **Dutch (nl)** - Nederlands

All user-facing strings are externalized in `Localizable.strings` files.

## Design System

### Colors
- Primary: Teal (#00BFA5)
- Background: White (#FFFFFF)
- Text: Charcoal (#333333)
- Meal categories: Unique colors for visual distinction

### Typography
- SF Pro system font
- Rounded numbers for stats display
- Full Dynamic Type support

## Privacy

NutriBalance respects user privacy:
- All data stored locally on device
- No third-party analytics without consent
- Optional Face ID/Touch ID protection
- GDPR-compliant data export

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for details.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary software. All rights reserved.

## Acknowledgments

- SF Symbols for iconography
- Swift Charts for data visualization
- PDFKit for report generation

---

**NutriBalance** - Your personal nutrition companion.

*Built with SwiftUI and in the Netherlands.*
