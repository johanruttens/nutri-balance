# Claude Code Development Prompt: NutriBalance iOS App

## Project Overview

Build a native iOS application called **"NutriBalance"** — a comprehensive food and beverage tracking app designed to help users maintain healthy eating habits and achieve sustainable weight loss goals. The app combines elegant minimalist design with powerful tracking, analytics, and export capabilities.

---

## Target Platform & Technical Requirements

### Platform Specifications
- **Platform**: iOS only (iPhone)
- **Minimum iOS Version**: iOS 16.0+
- **Device Support**: iPhone only (no iPad or tablet support)
- **Orientation**: Portrait mode only
- **Framework**: SwiftUI with Swift 5.9+
- **Architecture**: MVVM (Model-View-ViewModel) with Clean Architecture principles
- **Data Persistence**: Core Data with CloudKit sync capability
- **Localization**: Dutch (nl) and English (en) — English as default

### Development Standards
- Use Swift Package Manager for dependencies
- Implement comprehensive unit and UI testing
- Follow Apple's Human Interface Guidelines
- Ensure accessibility compliance (VoiceOver, Dynamic Type)
- Implement proper error handling and logging
- Use async/await for asynchronous operations

---

## Core Features

### 1. User Onboarding & Profile Setup

#### Initial Setup Flow
Create a welcoming onboarding experience that collects:

1. **Welcome Screen**
   - App logo animation
   - Brief value proposition (2-3 screens)
   - Language selection (Dutch/English)

2. **Personal Information**
   - First name (required) — used for personalized welcome messages
   - Last name (optional)
   - Profile photo (optional, with camera/library access)

3. **Health Goals Setup**
   - Current weight (kg)
   - Target weight (with pre-filled suggestion of -4kg from current)
   - Target date (with realistic timeline suggestions)
   - Activity level (Sedentary, Lightly Active, Moderately Active, Very Active)

4. **Dietary Preferences**
   - Dietary restrictions (Vegetarian, Vegan, Gluten-free, Lactose-free, etc.)
   - Allergies (free-text with common suggestions)
   - Meal timing preferences

5. **Notification Preferences**
   - Meal reminders (customizable times)
   - Daily summary notification
   - Weekly progress reports
   - Hydration reminders

#### Personalized Welcome Message
Throughout the app, display personalized greetings:
- "Good morning, [Name]! Ready for a healthy day?"
- "Welcome back, [Name]!"
- Time-appropriate greetings in both Dutch and English

---

### 2. Daily Food & Drink Tracking

#### Meal Categories
Implement tracking for the following meal categories:

1. **Breakfast** (Ontbijt)
   - Default time window: 06:00 - 10:00
   - Icon: Sunrise/coffee cup

2. **Morning Snack** (Tussendoortje ochtend)
   - Default time window: 10:00 - 12:00
   - Icon: Apple/fruit

3. **Lunch** (Lunch)
   - Default time window: 12:00 - 14:00
   - Icon: Sandwich/bowl

4. **Afternoon Snack** (Tussendoortje middag)
   - Default time window: 14:00 - 17:00
   - Icon: Cookie/nuts

5. **Dinner** (Avondeten)
   - Default time window: 17:00 - 21:00
   - Icon: Plate with utensils

6. **Evening Snack** (Avondsnack)
   - Default time window: 21:00 - 23:00
   - Icon: Moon with snack

7. **Drinks** (Dranken)
   - Track throughout the day
   - Separate sub-categories:
     - Water
     - Coffee/Tea
     - Soft drinks
     - Alcoholic beverages
     - Juices/Smoothies
   - Icon: Glass/cup

#### Food Entry Interface

**Quick Add Features:**
- Large, accessible "+" button for each meal category
- Voice input capability for hands-free logging
- Barcode scanner integration (using device camera)
- Photo capture for meals (with optional AI description - placeholder for future)

**Entry Fields:**
- Food/drink name (required)
- Quantity/portion size
- Unit selection (grams, ml, pieces, cups, tablespoons, etc.)
- Estimated calories (optional, with auto-calculation where possible)
- Macronutrients (optional): Carbs, Protein, Fat, Fiber
- Notes/description field
- Timestamp (auto-filled, editable)
- Mood/feeling after eating (optional emoji selector)
- Hunger level before eating (1-5 scale)

---

### 3. Smart Autofill & Favorites System (Database Functionality)

#### Personal Food Database
Create a local SQLite/Core Data database storing:

**Food Items Table:**
```
- id: UUID
- name: String
- defaultQuantity: Double
- defaultUnit: String
- calories: Int (optional)
- carbs: Double (optional)
- protein: Double (optional)
- fat: Double (optional)
- fiber: Double (optional)
- category: MealCategory
- frequency: Int (usage count)
- lastUsed: Date
- isFavorite: Boolean
- createdAt: Date
- updatedAt: Date
```

**Meal Templates Table:**
```
- id: UUID
- name: String (e.g., "My Weekday Breakfast")
- mealCategory: MealCategory
- items: [FoodItem]
- frequency: Int
- lastUsed: Date
- isFavorite: Boolean
- dayOfWeek: [Int] (optional, for day-specific templates)
```

#### Autofill Functionality

1. **Smart Suggestions**
   - As user types, show matching items from personal database
   - Sort by: frequency of use, recency, favorites
   - Display portion size and calories inline

2. **"Repeat Yesterday" Feature**
   - One-tap option to copy entire meal from yesterday
   - Available per meal category or for entire day

3. **Template Meals**
   - Save frequently eaten meal combinations
   - "My usual breakfast" feature
   - Day-specific templates (e.g., different weekend breakfast)

4. **Learning Algorithm**
   - Track eating patterns
   - Suggest items based on:
     - Time of day
     - Day of week
     - Recent choices
     - Seasonal patterns

5. **Quick Favorites Bar**
   - Horizontal scrollable list of starred items
   - One-tap add with default portion
   - Long-press to edit quantity before adding

---

### 4. Dashboard & Analytics

#### Home Dashboard
Display a clean, informative overview:

**Today's Summary Card:**
- Circular progress indicator for daily calorie goal
- Meal completion status (checkmarks for logged meals)
- Water intake tracker
- Current streak counter

**Quick Stats Row:**
- Calories consumed / remaining
- Macros breakdown (if tracked)
- Meals logged today

#### Weekly Dashboard

**Weekly Overview Screen:**
- 7-day calendar strip with visual indicators:
  - Green dot: All meals logged
  - Yellow dot: Partial logging
  - Gray dot: No logging
  - Star: Within calorie goal

**Weekly Statistics:**
- Average daily calories
- Calorie trend graph (line chart)
- Most eaten foods (top 5)
- Meal timing patterns
- Hydration average
- Weight change (if tracked)

**Weekly Insights:**
- "You ate 15% fewer calories than last week"
- "Your most consistent meal is breakfast"
- "You tend to snack more on weekends"

#### Monthly Dashboard

**Monthly Calendar View:**
- Full month grid with color-coded days
- Tap any day to see that day's details

**Monthly Statistics:**
- Total calories consumed
- Average daily intake
- Best/worst days
- Weight progress graph
- Goal adherence percentage

**Monthly Trends:**
- Comparison to previous month
- Category breakdown (what % breakfast vs dinner, etc.)
- Nutritional balance overview
- Pattern analysis

**Charts & Visualizations:**
- Line graph: Calorie intake over time
- Bar chart: Macronutrient distribution
- Pie chart: Meal category distribution
- Heat map: Eating time patterns

---

### 5. PDF Export Functionality

#### Daily Report Export
Generate professional PDF reports for dietitian consultations:

**PDF Content - Daily Report:**
```
Header:
- NutriBalance logo
- User name
- Report date
- Generated timestamp

Personal Info Section:
- Current weight
- Target weight
- Goal progress

Daily Breakdown:
For each meal category:
- Meal name & time
- List of all items with:
  - Food name
  - Quantity & unit
  - Calories
  - Macros (if available)
- Meal subtotal

Drinks Section:
- Complete beverage list
- Total fluid intake

Daily Summary:
- Total calories
- Macro breakdown
- Goal comparison
- Notes (if any)

Footer:
- App branding
- Page number
```

**PDF Design:**
- Clean, professional layout
- Minimalist styling matching app theme
- Charcoal text (#333333)
- Accent color highlights for totals
- Easy to read for healthcare professionals

#### Export Options

**Date Range Selection:**
- Single day
- Custom date range
- Last 7 days
- Last 30 days
- Current week (Mon-Sun)
- Current month

**Export Formats:**
- PDF (primary)
- CSV (for data analysis)
- JSON (for backup/transfer)

**Sharing Options:**
- Share sheet (email, messaging, etc.)
- Save to Files app
- Print directly
- Save to iCloud Drive

**Batch Export:**
- Generate individual PDFs for date range
- Or consolidated multi-day report

---

### 6. Weight Loss Support Features

#### Weight Tracking
- Daily weigh-in reminder (optional)
- Weight log with graph visualization
- Trend line showing progress
- BMI calculator and display
- Body measurements tracking (optional):
  - Waist circumference
  - Hip circumference
  - Other custom measurements

#### Goal Progress
- Visual progress bar toward 4kg goal (or custom goal)
- Milestone celebrations (every 0.5kg)
- Estimated goal date based on current progress
- Streak tracking for consistent logging

#### Calorie Budget System
- Calculate TDEE based on user data
- Suggest daily calorie target for weight loss
- Configurable deficit (conservative to aggressive)
- Remaining calories display

#### Healthy Eating Insights
- Traffic light system for foods (green/yellow/red based on nutritional value)
- Portion size guidance
- Healthier alternative suggestions
- Nutrient balance feedback

#### Motivational Features
- Daily motivational quotes
- Achievement badges system:
  - "7-Day Streak"
  - "First Kilogram Lost"
  - "Hydration Hero"
  - "Veggie Champion"
  - etc.
- Celebration animations for milestones

---

### 7. Hydration Tracking

#### Water Intake Feature
- Daily water goal (customizable, default 2L)
- Quick-add buttons (200ml, 250ml, 500ml)
- Visual water bottle filling animation
- Hourly hydration reminders (optional)

#### Beverage Categories
- Track all beverages separately
- Caffeine tracking (coffee, tea, energy drinks)
- Sugar content awareness for soft drinks
- Alcohol unit tracking with health information

---

## Non-Functional Requirements

### Performance
- App launch time: < 2 seconds
- Database queries: < 100ms
- Smooth 60fps animations
- Efficient battery usage
- Minimal memory footprint

### Security & Privacy
- All data stored locally by default
- Optional iCloud sync (encrypted)
- No third-party analytics without consent
- Face ID/Touch ID protection (optional)
- Data export for GDPR compliance

### Reliability
- Offline-first functionality
- Automatic data backup
- Crash recovery with data preservation
- Background sync when connectivity returns

### Accessibility
- Full VoiceOver support
- Dynamic Type support (all text sizes)
- Sufficient color contrast
- Reduce Motion support
- Haptic feedback for interactions

### Maintainability
- Comprehensive documentation
- Modular code architecture
- Unit test coverage > 80%
- UI test coverage for critical paths
- Clear separation of concerns

---

## Design Specifications

### Visual Design Language

#### Color Palette

**Primary Colors:**
- Background: Pure White (#FFFFFF)
- Secondary Background: Light Gray (#F8F9FA)
- Card Background: White (#FFFFFF)

**Text Colors:**
- Primary Text: Charcoal (#333333)
- Secondary Text: Medium Gray (#666666)
- Tertiary Text: Light Gray (#999999)

**Accent Colors (for CTAs and highlights):**
- Primary Accent: Vibrant Teal (#00BFA5)
- Secondary Accent: Coral (#FF6B6B)
- Success: Soft Green (#4CAF50)
- Warning: Warm Orange (#FF9800)
- Error: Soft Red (#F44336)
- Water/Hydration: Sky Blue (#29B6F6)

**Category Colors:**
- Breakfast: Warm Yellow (#FFD54F)
- Morning Snack: Light Orange (#FFAB40)
- Lunch: Fresh Green (#66BB6A)
- Afternoon Snack: Soft Purple (#AB47BC)
- Dinner: Deep Blue (#42A5F5)
- Evening Snack: Lavender (#7E57C2)
- Drinks: Cyan (#26C6DA)

#### Typography

**Font Family:** SF Pro (system default)

**Font Sizes:**
- Large Title: 34pt, Bold
- Title 1: 28pt, Bold
- Title 2: 22pt, Bold
- Title 3: 20pt, Semibold
- Headline: 17pt, Semibold
- Body: 17pt, Regular
- Callout: 16pt, Regular
- Subheadline: 15pt, Regular
- Footnote: 13pt, Regular
- Caption: 12pt, Regular

#### UI Components

**Buttons:**
- Primary CTA: Rounded rectangle, teal fill, white text
- Secondary CTA: Rounded rectangle, teal outline, teal text
- Destructive: Rounded rectangle, coral fill, white text
- Corner radius: 12pt
- Minimum touch target: 44x44pt

**Cards:**
- White background
- Subtle shadow (0, 2, 8, rgba(0,0,0,0.08))
- Corner radius: 16pt
- Padding: 16pt

**Input Fields:**
- Light gray background (#F5F5F5)
- Charcoal text
- Teal accent on focus
- Corner radius: 8pt
- Height: 48pt

**Navigation:**
- Bottom tab bar (5 tabs max)
- SF Symbols for icons
- Teal for selected state
- Gray for unselected

#### Iconography
- Use SF Symbols throughout
- Weight: Regular for UI, Semibold for emphasis
- Size: 24pt for navigation, 20pt for in-content

#### Animations
- Subtle, purposeful micro-interactions
- Spring animations for buttons
- Smooth transitions between screens
- Progress animations for achievements
- Respect "Reduce Motion" accessibility setting

---

## Localization

### Supported Languages

#### English (en) — Default
```
// Example strings
"welcome_message" = "Good morning, %@!";
"breakfast" = "Breakfast";
"add_food" = "Add Food";
"calories_remaining" = "%d calories remaining";
"weekly_overview" = "Weekly Overview";
"export_to_pdf" = "Export to PDF";
"save_as_favorite" = "Save as Favorite";
```

#### Dutch (nl)
```
// Example strings
"welcome_message" = "Goedemorgen, %@!";
"breakfast" = "Ontbijt";
"add_food" = "Voedsel toevoegen";
"calories_remaining" = "%d calorieën resterend";
"weekly_overview" = "Weekoverzicht";
"export_to_pdf" = "Exporteren naar PDF";
"save_as_favorite" = "Opslaan als favoriet";
```

### Localization Requirements
- All user-facing strings externalized
- Date/time formatting localized
- Number formatting localized (comma vs period)
- Measurement units (support metric primarily)
- Currency formatting (if any paid features)
- RTL support not required (English/Dutch only)

---

## App Structure

### Navigation Architecture

```
Tab Bar Navigation:
├── Today (Home)
│   ├── Daily Overview
│   ├── Meal Categories (expandable)
│   ├── Add Food/Drink
│   └── Today's Summary
│
├── History
│   ├── Calendar View
│   ├── Day Detail View
│   └── Search Past Entries
│
├── Dashboard
│   ├── Weekly Stats
│   ├── Monthly Stats
│   ├── Charts & Graphs
│   └── Insights
│
├── Progress
│   ├── Weight Graph
│   ├── Goal Progress
│   ├── Achievements
│   └── Milestones
│
└── Settings
    ├── Profile
    ├── Goals
    ├── Notifications
    ├── Data Export
    ├── Language
    ├── About
    └── Privacy
```

### Screen Flow

```
Launch
  │
  ├─(First Launch)─> Onboarding Flow ─> Home
  │
  └─(Returning User)─> Home (with personalized greeting)
                          │
                          ├── Tap Meal ─> Add Food Flow
                          │                  │
                          │                  ├── Search
                          │                  ├── Favorites
                          │                  ├── Scan Barcode
                          │                  └── Manual Entry
                          │
                          ├── View History ─> Calendar ─> Day Detail
                          │
                          ├── Dashboard ─> Charts ─> Export
                          │
                          └── Settings ─> Various Options
```

---

## Database Schema

### Core Data Entities

```swift
// User Profile
Entity: UserProfile
- id: UUID
- firstName: String
- lastName: String?
- profileImageData: Data?
- currentWeight: Double
- targetWeight: Double
- targetDate: Date?
- height: Double?
- birthDate: Date?
- activityLevel: Int16
- dailyCalorieGoal: Int32
- dailyWaterGoal: Double
- preferredLanguage: String
- createdAt: Date
- updatedAt: Date

// Food Item (Template/Favorite)
Entity: FoodItem
- id: UUID
- name: String
- defaultQuantity: Double
- defaultUnit: String
- caloriesPer100g: Int32?
- carbsPer100g: Double?
- proteinPer100g: Double?
- fatPer100g: Double?
- fiberPer100g: Double?
- usageCount: Int32
- lastUsedAt: Date?
- isFavorite: Bool
- createdAt: Date

// Daily Log Entry
Entity: FoodLogEntry
- id: UUID
- date: Date
- mealCategory: Int16
- foodName: String
- quantity: Double
- unit: String
- calories: Int32?
- carbs: Double?
- protein: Double?
- fat: Double?
- fiber: Double?
- notes: String?
- hungerLevel: Int16?
- moodEmoji: String?
- timestamp: Date
- linkedFoodItem: FoodItem? (relationship)

// Drink Log Entry
Entity: DrinkLogEntry
- id: UUID
- date: Date
- drinkCategory: Int16
- drinkName: String
- quantity: Double
- unit: String
- calories: Int32?
- caffeineContent: Double?
- sugarContent: Double?
- isAlcoholic: Bool
- timestamp: Date

// Weight Entry
Entity: WeightEntry
- id: UUID
- date: Date
- weight: Double
- notes: String?

// Meal Template
Entity: MealTemplate
- id: UUID
- name: String
- mealCategory: Int16
- items: [FoodItem] (relationship)
- usageCount: Int32
- isFavorite: Bool
- applicableDays: [Int16]?
- createdAt: Date
```

---

## API Integrations (Optional/Future)

### Barcode Database
- Open Food Facts API (free, community-driven)
- Fallback to manual entry if not found

### Nutritional Data
- USDA FoodData Central API (optional)
- Local database of common foods

### Health App Integration
- HealthKit integration for:
  - Weight sync (read/write)
  - Active calories
  - Water intake
  - Nutritional data

---

## Testing Requirements

### Unit Tests
- All ViewModel logic
- Core Data operations
- Date/time calculations
- Calorie/macro calculations
- Localization string loading
- PDF generation

### UI Tests
- Onboarding flow completion
- Add food entry flow
- Dashboard navigation
- Export functionality
- Settings changes

### Performance Tests
- Database query performance
- List scrolling performance
- PDF generation time
- Memory usage during export

---

## Deliverables

1. **Complete Xcode Project**
   - Clean, organized project structure
   - All source code with comments
   - Asset catalogs (icons, colors, images)

2. **Documentation**
   - README with setup instructions
   - Architecture documentation
   - API documentation (if any)

3. **Localization Files**
   - en.lproj/Localizable.strings
   - nl.lproj/Localizable.strings
   - Localized asset catalogs

4. **Test Suite**
   - Unit tests
   - UI tests
   - Test coverage report

5. **App Store Assets**
   - App icon (all sizes)
   - Launch screen
   - Preview screenshots

---

## Implementation Priorities

### Phase 1: Foundation
1. Project setup and architecture
2. Core Data model
3. Basic UI shell with navigation
4. User onboarding flow

### Phase 2: Core Tracking
1. Food entry interface
2. Meal category views
3. Daily overview
4. Local database and autofill

### Phase 3: Analytics
1. Weekly dashboard
2. Monthly dashboard
3. Charts and visualizations
4. Weight tracking

### Phase 4: Export & Polish
1. PDF generation
2. Export functionality
3. Achievements system
4. Localization completion

### Phase 5: Enhancement
1. Barcode scanning
2. HealthKit integration
3. Widget support
4. Performance optimization

---

## Success Criteria

The app is considered complete when:

- [ ] User can complete onboarding and set up profile
- [ ] All meal categories are fully functional
- [ ] Autofill suggestions work correctly
- [ ] Favorites can be saved and retrieved
- [ ] Weekly and monthly dashboards display accurate data
- [ ] PDF export generates professional, readable reports
- [ ] Weight tracking shows progress toward 4kg goal
- [ ] App works fully offline
- [ ] Both English and Dutch are fully supported
- [ ] Design matches minimalist specification with colorful accents
- [ ] All accessibility requirements are met
- [ ] Performance meets specified benchmarks
- [ ] Test coverage exceeds 80%

---

## Notes for Development

- Prioritize user experience over feature count
- Keep the interface clean and uncluttered
- Make food logging as quick as possible (minimal taps)
- Ensure PDF exports are genuinely useful for dietitian appointments
- The autofill/favorites system is critical — make it smart and fast
- Test with real-world scenarios (logging a full day of eating)
- Consider edge cases (missed meals, partial days, timezone changes)

---

*App Name: NutriBalance*
*Tagline: "Balance your nutrition, transform your life"*
*Dutch tagline: "Balanceer je voeding, transformeer je leven"*
Don't forget to create a readme file
Provide a privacy statement, requirement by the Apple app store (and other legal requirements)
