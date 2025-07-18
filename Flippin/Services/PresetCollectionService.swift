//
//  PresetCollectionService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

class PresetCollectionService: ObservableObject {
    static let shared = PresetCollectionService()
    
    @Published var collections: [PresetCollection] = []
    
    private init() {
        loadCollections()
    }
    
    func loadCollections() {
        collections = createPresetCollections()
    }
    
    func getCollections(for userLanguage: Language, targetLanguage: Language) -> [PresetCollection] {
        return collections.filter { collection in
            // For now, return all collections. In the future, we can filter by language support
            return true
        }
    }
    
    func getFeaturedCollections(for userLanguage: Language, targetLanguage: Language) -> [PresetCollection] {
        let allCollections = getCollections(for: userLanguage, targetLanguage: targetLanguage)
        return Array(allCollections.prefix(2))
    }
    
    private func createPresetCollections() -> [PresetCollection] {
        return [
            // Basics Collection
            PresetCollection(
                name: "Essential Phrases",
                description: "Basic words and phrases everyone needs to know",
                icon: "abc",
                category: .basics,
                cards: [
                    PresetCard(
                        frontText: "Hello",
                        backText: "Hola",
                        notes: "Basic greeting",
                        tags: ["basics", "greetings"]
                    ),
                    PresetCard(
                        frontText: "Thank you",
                        backText: "Gracias",
                        notes: "Expressing gratitude",
                        tags: ["basics", "politeness"]
                    ),
                    PresetCard(
                        frontText: "Please",
                        backText: "Por favor",
                        notes: "Making polite requests",
                        tags: ["basics", "politeness"]
                    ),
                    PresetCard(
                        frontText: "Yes",
                        backText: "Sí",
                        notes: "Affirmative response",
                        tags: ["basics", "responses"]
                    ),
                    PresetCard(
                        frontText: "No",
                        backText: "No",
                        notes: "Negative response",
                        tags: ["basics", "responses"]
                    ),
                    PresetCard(
                        frontText: "Goodbye",
                        backText: "Adiós",
                        notes: "Farewell",
                        tags: ["basics", "greetings"]
                    ),
                    PresetCard(
                        frontText: "Excuse me",
                        backText: "Perdón",
                        notes: "Getting attention or apologizing",
                        tags: ["basics", "politeness"]
                    ),
                    PresetCard(
                        frontText: "I don't understand",
                        backText: "No entiendo",
                        notes: "When you need clarification",
                        tags: ["basics", "communication"]
                    )
                ]
            ),
            
            // Travel Collection
            PresetCollection(
                name: "Travel Essentials",
                description: "Essential phrases for traveling and getting around",
                icon: "airplane",
                category: .travel,
                cards: [
                    PresetCard(
                        frontText: "Where is the bathroom?",
                        backText: "¿Dónde está el baño?",
                        notes: "Essential for travelers",
                        tags: ["travel", "directions"]
                    ),
                    PresetCard(
                        frontText: "How much does this cost?",
                        backText: "¿Cuánto cuesta esto?",
                        notes: "Shopping and bargaining",
                        tags: ["travel", "shopping"]
                    ),
                    PresetCard(
                        frontText: "I need help",
                        backText: "Necesito ayuda",
                        notes: "Emergency phrase",
                        tags: ["travel", "emergency"]
                    ),
                    PresetCard(
                        frontText: "Do you speak English?",
                        backText: "¿Habla inglés?",
                        notes: "Language barrier breaker",
                        tags: ["travel", "communication"]
                    ),
                    PresetCard(
                        frontText: "I'm lost",
                        backText: "Estoy perdido",
                        notes: "When you need directions",
                        tags: ["travel", "directions"]
                    ),
                    PresetCard(
                        frontText: "Can you help me?",
                        backText: "¿Puede ayudarme?",
                        notes: "Asking for assistance",
                        tags: ["travel", "communication"]
                    ),
                    PresetCard(
                        frontText: "What time is it?",
                        backText: "¿Qué hora es?",
                        notes: "Time-related questions",
                        tags: ["travel", "time"]
                    ),
                    PresetCard(
                        frontText: "I'm allergic to...",
                        backText: "Soy alérgico a...",
                        notes: "Important for food and medicine",
                        tags: ["travel", "health"]
                    )
                ]
            ),
            
            // Entertainment Collection
            PresetCollection(
                name: "Entertainment & Media",
                description: "Words and phrases about movies, music, games, and entertainment",
                icon: "tv",
                category: .entertainment,
                cards: [
                    PresetCard(
                        frontText: "I love this movie",
                        backText: "Me encanta esta película",
                        notes: "Expressing enjoyment",
                        tags: ["entertainment", "movies"]
                    ),
                    PresetCard(
                        frontText: "What's your favorite music?",
                        backText: "¿Cuál es tu música favorita?",
                        notes: "Music conversation starter",
                        tags: ["entertainment", "music"]
                    ),
                    PresetCard(
                        frontText: "This song is amazing",
                        backText: "Esta canción es increíble",
                        notes: "Music appreciation",
                        tags: ["entertainment", "music"]
                    ),
                    PresetCard(
                        frontText: "I play video games",
                        backText: "Juego videojuegos",
                        notes: "Gaming hobby",
                        tags: ["entertainment", "games"]
                    ),
                    PresetCard(
                        frontText: "Have you seen this show?",
                        backText: "¿Has visto este programa?",
                        notes: "TV show discussion",
                        tags: ["entertainment", "tv"]
                    ),
                    PresetCard(
                        frontText: "I read comics",
                        backText: "Leo cómics",
                        notes: "Comic book interest",
                        tags: ["entertainment", "comics"]
                    ),
                    PresetCard(
                        frontText: "Disney movies are great",
                        backText: "Las películas de Disney son geniales",
                        notes: "Disney appreciation",
                        tags: ["entertainment", "disney"]
                    ),
                    PresetCard(
                        frontText: "What genre do you like?",
                        backText: "¿Qué género te gusta?",
                        notes: "Entertainment preferences",
                        tags: ["entertainment", "preferences"]
                    )
                ]
            ),
            
            // Food Collection
            PresetCollection(
                name: "Food & Dining",
                description: "Essential phrases for restaurants and food experiences",
                icon: "fork.knife",
                category: .food,
                cards: [
                    PresetCard(
                        frontText: "I'm hungry",
                        backText: "Tengo hambre",
                        notes: "Basic food need",
                        tags: ["food", "hunger"]
                    ),
                    PresetCard(
                        frontText: "This is delicious",
                        backText: "Esto está delicioso",
                        notes: "Food appreciation",
                        tags: ["food", "appreciation"]
                    ),
                    PresetCard(
                        frontText: "I'm vegetarian",
                        backText: "Soy vegetariano",
                        notes: "Dietary restriction",
                        tags: ["food", "diet"]
                    ),
                    PresetCard(
                        frontText: "Can I have the menu?",
                        backText: "¿Puedo tener el menú?",
                        notes: "Restaurant request",
                        tags: ["food", "restaurant"]
                    ),
                    PresetCard(
                        frontText: "I'd like to order",
                        backText: "Me gustaría ordenar",
                        notes: "Ready to order",
                        tags: ["food", "restaurant"]
                    ),
                    PresetCard(
                        frontText: "The bill, please",
                        backText: "La cuenta, por favor",
                        notes: "Asking for the check",
                        tags: ["food", "restaurant"]
                    ),
                    PresetCard(
                        frontText: "I'm allergic to nuts",
                        backText: "Soy alérgico a las nueces",
                        notes: "Food allergy",
                        tags: ["food", "allergy"]
                    ),
                    PresetCard(
                        frontText: "What do you recommend?",
                        backText: "¿Qué recomienda?",
                        notes: "Asking for recommendations",
                        tags: ["food", "recommendations"]
                    )
                ]
            ),
            
            // Health Collection
            PresetCollection(
                name: "Health & Medical",
                description: "Important phrases for medical situations and health concerns",
                icon: "cross.case",
                category: .health,
                cards: [
                    PresetCard(
                        frontText: "I don't feel well",
                        backText: "No me siento bien",
                        notes: "General health concern",
                        tags: ["health", "symptoms"]
                    ),
                    PresetCard(
                        frontText: "I have a headache",
                        backText: "Tengo dolor de cabeza",
                        notes: "Common symptom",
                        tags: ["health", "symptoms"]
                    ),
                    PresetCard(
                        frontText: "I need a doctor",
                        backText: "Necesito un médico",
                        notes: "Medical emergency",
                        tags: ["health", "emergency"]
                    ),
                    PresetCard(
                        frontText: "Where is the hospital?",
                        backText: "¿Dónde está el hospital?",
                        notes: "Medical facility location",
                        tags: ["health", "directions"]
                    ),
                    PresetCard(
                        frontText: "I have a fever",
                        backText: "Tengo fiebre",
                        notes: "Common illness symptom",
                        tags: ["health", "symptoms"]
                    ),
                    PresetCard(
                        frontText: "I'm taking medication",
                        backText: "Estoy tomando medicamentos",
                        notes: "Medical information",
                        tags: ["health", "medication"]
                    ),
                    PresetCard(
                        frontText: "I have an allergy",
                        backText: "Tengo una alergia",
                        notes: "Important medical information",
                        tags: ["health", "allergy"]
                    ),
                    PresetCard(
                        frontText: "Call an ambulance",
                        backText: "Llame una ambulancia",
                        notes: "Emergency situation",
                        tags: ["health", "emergency"]
                    )
                ]
            ),
            
            // Leisure Collection
            PresetCollection(
                name: "Leisure & Hobbies",
                description: "Phrases for talking about hobbies, sports, and free time activities",
                icon: "gamecontroller",
                category: .leisure,
                cards: [
                    PresetCard(
                        frontText: "I like to read",
                        backText: "Me gusta leer",
                        notes: "Reading hobby",
                        tags: ["leisure", "reading"]
                    ),
                    PresetCard(
                        frontText: "Do you play sports?",
                        backText: "¿Practicas deportes?",
                        notes: "Sports conversation",
                        tags: ["leisure", "sports"]
                    ),
                    PresetCard(
                        frontText: "I love hiking",
                        backText: "Me encanta hacer senderismo",
                        notes: "Outdoor activity",
                        tags: ["leisure", "outdoors"]
                    ),
                    PresetCard(
                        frontText: "What do you do for fun?",
                        backText: "¿Qué haces para divertirte?",
                        notes: "Hobby conversation starter",
                        tags: ["leisure", "hobbies"]
                    ),
                    PresetCard(
                        frontText: "I enjoy cooking",
                        backText: "Disfruto cocinando",
                        notes: "Cooking hobby",
                        tags: ["leisure", "cooking"]
                    ),
                    PresetCard(
                        frontText: "Let's go for a walk",
                        backText: "Vamos a dar un paseo",
                        notes: "Casual activity suggestion",
                        tags: ["leisure", "walking"]
                    ),
                    PresetCard(
                        frontText: "I play guitar",
                        backText: "Toco la guitarra",
                        notes: "Musical instrument",
                        tags: ["leisure", "music"]
                    ),
                    PresetCard(
                        frontText: "I like photography",
                        backText: "Me gusta la fotografía",
                        notes: "Photography hobby",
                        tags: ["leisure", "photography"]
                    )
                ]
            )
        ]
    }
    
    func convertPresetCardsToCardItems(_ presetCards: [PresetCard], userLanguage: Language, targetLanguage: Language) -> [CardItem] {
        return presetCards.map { presetCard in
            CardItem(
                timestamp: Date(),
                frontText: presetCard.frontText,
                backText: presetCard.backText,
                frontLanguage: userLanguage,
                backLanguage: targetLanguage,
                notes: presetCard.notes,
                tags: presetCard.tags,
                isFavorite: false,
                id: UUID().uuidString
            )
        }
    }
} 