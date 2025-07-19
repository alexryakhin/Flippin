# Preset Localization System

This document explains how the new localized preset phrase system works in Flippin.

## Overview

The preset localization system allows users to import preset card collections that are automatically translated based on their selected language pair. When a user selects their native language and target language, the system pulls the appropriate translations from separate localization files.

## Architecture

### 1. Localization Files

Each supported language has a `PresetPhrases.strings` file in its `.lproj` directory:

```
Flippin/Localization/
├── en.lproj/
│   └── PresetPhrases.strings
├── es.lproj/
│   └── PresetPhrases.strings
├── fr.lproj/
│   └── PresetPhrases.strings
├── de.lproj/
│   └── PresetPhrases.strings
└── ... (other languages)
```

### 2. Key Structure

Each phrase uses a consistent key structure:

- **Collection names**: `collection.{collectionId}.name` and `collection.{collectionId}.description`
- **Phrase text**: `phrase.{phraseKey}.text`
- **Phrase notes**: `phrase.{phraseKey}.notes`

### 3. Services

- **`LocalizedPresetService`**: Core service that manages localized preset collections
- **`PresetCollectionService`**: Updated to use the localized service

## How It Works

### 1. Collection Definition

Collections are defined in `LocalizedPresetService` with their phrase keys:

```swift
LocalizedPresetCollection(
    id: "essentialPhrases",
    category: .basics,
    phraseKeys: ["hello", "thankYou", "please", "yes", "no", ...]
)
```

### 2. Translation Loading

When a user selects languages, the system:

1. Loads collection names and descriptions in the user's language
2. Loads phrase text in the target language for the front of cards (for practice)
3. Loads phrase text in the user's language for the back of cards (for reference)
4. Loads notes in the user's language

### 3. Card Creation

When importing a collection, cards are created with:

- **Front text**: Target language translation (for practice)
- **Back text**: User language translation (for reference)
- **Notes**: User language notes
- **Tags**: Based on collection category

## Usage Example

```swift
// Get collections for English user learning Spanish
let collections = LocalizedPresetService.shared.getLocalizedCollections(
    for: .english, 
    targetLanguage: .spanish
)

// Import a collection
let cardItems = LocalizedPresetService.shared.convertPresetCardsToCardItems(
    collections[0].cards,
    userLanguage: .english,
    targetLanguage: .spanish
)
```

## Adding New Languages

### 1. Create Translation File

Run the generation script:

```bash
cd Flippin/Scripts
python3 generate_preset_translations.py
```

### 2. Translate Content

Edit the generated `PresetPhrases.strings` file in each language directory and translate:

- Collection names and descriptions
- All phrase text
- All phrase notes

### 3. Test

Test the localization by:

1. Setting different language pairs in the app
2. Importing preset collections
3. Verifying correct translations appear

## Supported Languages

Currently supported languages:

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt-BR, pt-PT)
- Dutch (nl)
- Swedish (sv)
- Chinese (zh-Hans, zh-Hant)
- Japanese (ja)
- Korean (ko)
- Vietnamese (vi)
- Russian (ru)
- Arabic (ar)
- Hindi (hi)
- Croatian (hr)
- Ukrainian (uk)

## Adding New Phrases

To add new phrases:

1. **Add to English file**: Add the new phrase key and text to `en.lproj/PresetPhrases.strings`
2. **Add to collection**: Add the phrase key to the appropriate collection in `LocalizedPresetService`
3. **Translate**: Add translations to all other language files
4. **Test**: Verify the new phrase appears correctly in all language combinations

## Benefits

1. **Automatic Translation**: No need to manually create translations for each language pair
2. **Consistent Quality**: All translations are professionally curated
3. **Scalable**: Easy to add new languages and phrases
4. **User-Friendly**: Users see content in their preferred language
5. **Maintainable**: Centralized translation management

## Future Enhancements

- Integration with translation services for automatic translation
- User-contributed translations
- Context-aware translations based on region/culture
- Audio pronunciation files for each phrase 