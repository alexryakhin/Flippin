# Flippin - Smart Language Learning Flashcards

A beautiful, intelligent flashcard app for learning languages with automatic translation, text-to-speech, and personalized learning features.

## 🌟 Features

### 🎯 **Smart Learning**
- **Automatic Translation**: Real-time translation as you type
- **18 Languages Supported**: English, Spanish, French, German, Italian, Portuguese, Dutch, Swedish, Chinese, Japanese, Korean, Vietnamese, Russian, Arabic, Hindi, Croatian, Ukrainian
- **Text-to-Speech**: Hear pronunciation with TTS technology
- **Travel Mode**: Reverse language display for practice

### 🎨 **Beautiful UI**
- **Animated Backgrounds**: 12 stunning animated backgrounds (Gradient, Lava Lamp, Snow, Rain, Stars, Bubbles, Waves, Particles, Aurora, Fireflies, Ocean, Galaxy)
- **3D Card Animations**: Smooth flip animations with physics
- **Dark/Light Mode**: Automatic theme switching
- **RTL Support**: Full right-to-left language support
- **Customizable Colors**: Personalize your learning experience

### 📚 **Learning Tools**
- **Infinite Card Stack**: Smooth scrolling through large collections
- **Smart Filtering**: Filter by tags, favorites, and language pairs
- **Preset Collections**: Ready-to-use phrase collections
- **Tag System**: Organize cards with custom tags
- **Progress Tracking**: Visual progress indicators

### 🔧 **Advanced Features**
- **Core Data Integration**: Persistent storage with offline support
- **Purchase System**: Premium features with StoreKit 2
- **Analytics**: Comprehensive learning analytics
- **Haptic Feedback**: Immersive tactile responses
- **Accessibility**: Full VoiceOver support

## 📱 Screenshots

*[Screenshots would be added here]*

## 🚀 Quick Start

### 1. Setup Project
```bash
# Clone the repository
git clone https://github.com/yourusername/SpeakCards.git
cd SpeakCards

# Open in Xcode
open Flippin.xcodeproj
```

### 2. Configure Languages
1. Launch the app
2. Select your native language
3. Choose the language you want to learn
4. Start creating your first cards!

### 3. Create Your First Card
1. Tap the **+** button
2. Type text in your language
3. Get automatic translation
4. Add optional notes and tags
5. Save and start learning!

## 🏗️ Architecture

### Core Services

#### CardsProvider
Manages card data and operations:
```swift
class CardsProvider: ObservableObject {
    @Published var cards: [CardItem] = []
    
    func addCard(_ card: CardItem)
    func deleteCard(_ card: CardItem)
    func toggleFavorite(_ card: CardItem)
    func shuffleCards()
}
```

#### LanguageManager
Handles language selection and filtering:
```swift
class LanguageManager: ObservableObject {
    @Published var userLanguage: Language
    @Published var targetLanguage: Language
    @Published var filterByLanguage: Bool
    
    func filterCards(_ cards: [CardItem]) -> [CardItem]
}
```

#### TTSPlayer
Text-to-speech functionality:
```swift
class TTSPlayer {
    func play(_ text: String, language: Language) async throws
}
```

### UI Components

#### CardStack & InfiniteCardStack
Interactive card displays with RTL support:
```swift
// For small collections
CardStack(cards) { card in
    CardView(card: card)
}

// For large collections
InfiniteCardStack(cards) { card in
    CardView(card: card)
}
```

#### AnimatedBackground
Beautiful animated backgrounds:
```swift
AnimatedBackground(style: .gradient)
AnimatedBackground(style: .lavaLamp)
AnimatedBackground(style: .stars)
```

## 💻 Usage Examples

### Create a Card
```swift
let card = CardItem(
    frontText: "Hello",
    backText: "Hola",
    frontLanguage: .english,
    backLanguage: .spanish,
    notes: "Greeting",
    tags: ["basics", "greetings"]
)
CardsProvider.shared.addCard(card)
```

### Filter Cards
```swift
let filteredCards = languageManager.filterCards(cards)
let favoriteCards = cards.filter { $0.isFavorite }
let taggedCards = cards.filter { $0.tagNames.contains("basics") }
```

### Play TTS
```swift
try await TTSPlayer.shared.play("Hello", language: .english)
```

## 🎨 UI Features

### Card Interface
- **3D Flip Animation**: Smooth card flipping with physics
- **TTS Controls**: Tap to hear pronunciation
- **Favorite Toggle**: Heart button for quick favoriting
- **Tag Display**: Visual tag indicators
- **Language Labels**: Clear language identification

### Navigation
- **Filter Bar**: Horizontal scrolling filter buttons
- **Action Buttons**: Menu, shuffle, and add card buttons
- **Settings Access**: Quick access to app settings
- **My Cards**: View and manage all cards

### Visual Design
- **Material Design**: Modern iOS design language
- **Custom Colors**: Dynamic color theming
- **Smooth Animations**: Spring-based animations
- **Responsive Layout**: Adapts to different screen sizes

## 🌍 Language Support

### Supported Languages
- **Western**: English, Spanish, French, German, Italian, Portuguese, Dutch, Swedish
- **Asian**: Chinese (Simplified/Traditional), Japanese, Korean, Vietnamese
- **Other**: Russian, Arabic, Hindi, Croatian, Ukrainian

### RTL Support
- **Arabic**: Full right-to-left interface support
- **Gesture Direction**: Automatic gesture direction adjustment
- **Layout Direction**: Proper text and layout direction

## 📊 Learning Features

### Smart Filtering
- **Language Pairs**: Filter by specific language combinations
- **Tag System**: Organize with custom tags
- **Favorites**: Quick access to favorite cards
- **Search**: Find cards by content

### Progress Tracking
- **Card Count**: Track total cards created
- **Learning Stats**: Monitor learning progress
- **Usage Analytics**: Understand learning patterns

### Preset Collections
- **Essential Phrases**: Common expressions
- **Travel Phrases**: Useful travel vocabulary
- **Business Phrases**: Professional communication
- **Custom Collections**: Create your own

## 🔧 Configuration

### App Settings
- **Language Selection**: Choose native and target languages
- **Background Style**: Select from 12 animated backgrounds
- **Color Theme**: Customize app colors
- **TTS Settings**: Configure text-to-speech options

### Premium Features
- **Unlimited Cards**: Remove card creation limits
- **Advanced Analytics**: Detailed learning insights
- **Premium Backgrounds**: Exclusive background styles
- **Priority Support**: Enhanced customer support

## 🧪 Testing

### Development Testing
```bash
# Check StoreKit sync status
./Flippin/Scripts/check_storekit_sync.sh

# Run in simulator
xcodebuild -scheme Flippin -destination 'platform=iOS Simulator,name=iPhone 15'
```

### User Testing
- **Card Creation**: Test translation and TTS
- **Navigation**: Verify all UI interactions
- **Language Switching**: Test RTL and LTR languages
- **Purchase Flow**: Test premium features

## 📚 Documentation

- **[Purchase System](Flippin/Documentation/PurchaseSystem.md)**: In-app purchase documentation
- **[Preset Localization](Flippin/Documentation/PresetLocalization.md)**: Localized phrase system
- **[StoreKit Setup](Flippin/Documentation/StoreKitSyncSetup.md)**: StoreKit configuration
- **[Card Limit Implementation](CARD_LIMIT_IMPLEMENTATION.md)**: Free user limitations

## 🚀 Getting Started

1. **Clone the repository**
2. **Open in Xcode**: `open Flippin.xcodeproj`
3. **Select target device**: iPhone or iPad
4. **Build and run**: `⌘+R`
5. **Configure languages**: Select your learning languages
6. **Create your first card**: Start learning!

## 🤝 Contributing

We welcome contributions! Please:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow the existing code style
4. **Test thoroughly**: Ensure all features work correctly
5. **Submit a pull request**: Include detailed description

### Development Guidelines
- Follow SwiftUI best practices
- Add proper documentation
- Include accessibility features
- Test on multiple devices
- Maintain consistent code style

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help
- **Documentation**: Check the documentation files
- **Issues**: Report bugs on GitHub Issues
- **Discussions**: Join GitHub Discussions
- **Email**: Contact support@flippin.app

### Common Issues
- **Translation not working**: Check internet connection
- **TTS not playing**: Verify device volume and permissions
- **Cards not saving**: Check Core Data permissions
- **Purchase issues**: Verify StoreKit configuration

## 🙏 Acknowledgments

- **Apple**: For SwiftUI and StoreKit frameworks
- **Google Translate**: For translation services
- **Open Source Community**: For inspiration and tools
- **Beta Testers**: For valuable feedback and testing

---

**Built with ❤️ for language learners worldwide**

*Flippin - Making language learning beautiful and effective* 