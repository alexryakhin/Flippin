# Preset Collections System

This document explains how the preset collections system works in Flippin, providing curated vocabulary sets for language learners.

## Overview

The preset collections system provides ready-to-use vocabulary sets organized by categories. Each collection contains phrases with translations, notes, and tags, making it easy for users to quickly add relevant vocabulary to their learning deck.

## Architecture

### 1. JSON Data Files

Each supported language has a `presets_{languageCode}.json` file in the `Resources/Presets/` directory:

```
Flippin/Resources/Presets/
├── presets_en.json
├── presets_es.json
├── presets_fr.json
├── presets_de.json
├── presets_it.json
├── presets_pt.json
├── presets_nl.json
├── presets_sv.json
├── presets_zh.json
├── presets_ja.json
├── presets_ko.json
├── presets_vi.json
├── presets_ru.json
├── presets_ar.json
├── presets_hi.json
├── presets_hr.json
└── presets_uk.json
```

### 2. Data Structure

Each JSON file follows this structure:

```json
{
  "languageName": "English",
  "languageCode": "en",
  "presets": [
    {
      "id": 1,
      "name": "Essential Phrases",
      "description": "Basic words and phrases everyone needs to know",
      "category": "basics",
      "systemImageName": "characters.uppercase",
      "phrases": [
        {
          "id": 1,
          "text": "Hello",
          "notes": "Basic greeting",
          "tags": ["basics", "communication"]
        }
      ]
    }
  ]
}
```

### 3. Core Services

- **`PresetCollectionService`**: Main service that loads and manages preset collections
- **`PresetModel`**: Data models for parsing JSON files
- **`CardsProvider`**: Handles importing preset cards into user's collection

## How It Works

### 1. Collection Loading

When the app starts or language settings change, the system:

1. Loads the JSON file for the user's native language
2. Loads the JSON file for the target language
3. Matches collections by ID and creates `PresetCollection` objects
4. Combines phrases from both languages to create bilingual cards

### 2. Card Creation

For each collection, cards are created with:

- **Front text**: Target language phrase (for practice)
- **Back text**: User's native language phrase (for reference)
- **Notes**: Notes in the user's native language
- **Tags**: Tags from the source collection

### 3. Language Pair Support

The system automatically handles any language pair combination:

```swift
// For English user learning Spanish
let userLanguageData = try loadPresetCollection(for: .english)
let targetLanguageData = try loadPresetCollection(for: .spanish)

// Cards are created with Spanish front, English back
```

## Usage Examples

### Get Featured Collections
```swift
let featuredCollections = PresetCollectionService.shared.getFeaturedCollections()
```

### Import a Collection
```swift
let collection = presetService.collections[0]
try cardsProvider.addPresetCards(collection.cards)
```

### Filter by Category
```swift
let travelCollections = collections.filter { $0.category == .travel }
```

## Collection Categories

The system supports 11 categories:

- **Basics** (`basics`): Essential phrases and greetings
- **Travel** (`travel`): Travel-related vocabulary
- **Social** (`social`): Social interactions and conversations
- **Lifestyle** (`lifestyle`): Daily life and personal topics
- **Professional** (`professional`): Work and business vocabulary
- **Emergency** (`emergency`): Emergency and urgent situations
- **Food** (`food`): Food, dining, and culinary terms
- **Shopping** (`shopping`): Shopping and commerce vocabulary
- **Technology** (`technology`): Tech and digital terms
- **Weather** (`weather`): Weather and climate vocabulary
- **Entertainment** (`entertainment`): Entertainment and leisure

## Adding New Languages

### 1. Create JSON File

Create a new `presets_{languageCode}.json` file in `Resources/Presets/`:

```json
{
  "languageName": "Language Name",
  "languageCode": "xx",
  "presets": [
    {
      "id": 1,
      "name": "Collection Name",
      "description": "Collection description",
      "category": "basics",
      "systemImageName": "icon.name",
      "phrases": [
        {
          "id": 1,
          "text": "Phrase text",
          "notes": "Phrase notes",
          "tags": ["tag1", "tag2"]
        }
      ]
    }
  ]
}
```

### 2. Add Language Support

Add the language to the `Language` enum in `Models/Language.swift`:

```swift
case newLanguage = "xx"
```

### 3. Test

Test the new language by:

1. Setting the new language as target language
2. Checking preset collections load correctly
3. Verifying translations appear properly

## Adding New Collections

### 1. Add to All Language Files

Add the new collection to all `presets_*.json` files with the same ID:

```json
{
  "id": 12,
  "name": "New Collection",
  "description": "New collection description",
  "category": "lifestyle",
  "systemImageName": "star",
  "phrases": [...]
}
```

### 2. Add Category (if needed)

If adding a new category, update `PresetModel.Category`:

```swift
enum Category: String, Codable, CaseIterable {
    // ... existing categories
    case newCategory = "newCategory"
}
```

### 3. Add Localization

Add category name to localization files:

```swift
// In LocalizationKeys.swift
static let categoryNewCategory = "categoryNewCategory"

// In Localizable.strings files
"categoryNewCategory" = "New Category";
```

## Adding New Phrases

### 1. Add to All Collections

Add the new phrase to the appropriate collection in all language files:

```json
{
  "id": 25,
  "text": "New phrase",
  "notes": "Phrase explanation",
  "tags": ["relevant", "tags"]
}
```

### 2. Maintain Consistency

Ensure:
- Same ID across all language files
- Consistent tags and categories
- Appropriate notes for each language

## UI Integration

### Featured Collections

The `FeaturedPresetCollections` view displays the first 2 collections:

```swift
var featuredCollections: [PresetCollection] {
    presetService.getFeaturedCollections()
}
```

### Full Collections View

The `PresetCollectionsView` shows all collections with:

- Search functionality
- Category filtering
- Import confirmation
- Premium access control

### Collection Cards

Each collection is displayed as a `PresetCollectionCard` with:

- Collection name and description
- Card count
- Category icon
- Preview of first 3 phrases

## Benefits

1. **Ready-to-Use Content**: Pre-curated vocabulary sets
2. **Consistent Quality**: Professionally translated content
3. **Easy Import**: One-tap collection import
4. **Organized Learning**: Categorized by topics and situations
5. **Scalable**: Easy to add new languages and collections
6. **Offline Support**: All content bundled with the app

## Premium Features

- **Free Users**: Limited to featured collections
- **Premium Users**: Access to all collections
- **Import Limits**: Free users have card creation limits

## Analytics

The system tracks:

- Collection views
- Collection imports
- Search usage
- Category preferences

## Future Enhancements

- **Dynamic Content**: Server-side collection updates
- **User Contributions**: Community-created collections
- **Audio Integration**: Pronunciation files for phrases
- **Progress Tracking**: Track learning progress per collection
- **Spaced Repetition**: Intelligent review scheduling 