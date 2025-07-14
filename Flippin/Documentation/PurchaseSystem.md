# Система покупок Flippin

## Обзор

Система покупок в приложении Flippin использует StoreKit 2 для обработки in-app покупок. Система поддерживает тестовые покупки и предоставляет полную информацию о транзакциях, включая идентификаторы транзакций.

## Компоненты

### 1. PurchaseService
Основной сервис для управления покупками:
- Загрузка продуктов из App Store
- Выполнение покупок
- Автоматическое прослушивание обновлений транзакций
- Получение истории транзакций
- Восстановление покупок

### 2. PurchaseTestView
UI для тестирования покупок:
- Кнопка для выполнения тестовой покупки
- Отображение последнего transaction ID
- Просмотр доступных продуктов
- История транзакций

### 3. StoreKit Configuration
Конфигурационный файл для тестовых продуктов:
- `com.dor.flippin.unlimited_cards` - Непотребляемый продукт ($0.99)
- `com.dor.flippin.premium_monthly` - Подписка на месяц ($4.99)
- `com.dor.flippin.premium_yearly` - Подписка на год ($39.99)

## Как выполнить тестовую покупку

### Способ 1: Через UI
1. Откройте приложение Flippin
2. Перейдите в Настройки (Settings)
3. Найдите секцию "Purchase Testing"
4. Нажмите "Open Purchase Test"
5. Нажмите "Start Test Purchase"
6. Подтвердите покупку в диалоге StoreKit
7. Получите transaction ID в результатах

### Способ 2: Программно
```swift
// Простая тестовая покупка
Task {
    let result = await PurchaseService.shared.performTestPurchase()
    if result.success {
        print("Transaction ID: \(result.transactionId ?? "Unknown")")
    }
}

// Покупка конкретного продукта
Task {
    let result = await PurchaseService.shared.purchaseProduct("com.dor.flippin.unlimited_cards")
    if result.success {
        print("Transaction ID: \(result.transactionId ?? "Unknown")")
    }
}
```

## Прослушивание обновлений транзакций

Система автоматически запускает прослушивание обновлений транзакций при инициализации `PurchaseService`. Это критически важно для предотвращения потери покупок.

### Автоматическое прослушивание
```swift
// При инициализации PurchaseService автоматически запускается:
private func listenForTransactionUpdates() async {
    for await result in Transaction.updates {
        let transaction = try checkVerified(result)
        // Обработка транзакции
        await transaction.finish()
    }
}
```

### Проверка статуса прослушивания
```swift
let purchaseService = PurchaseService.shared
if purchaseService.isListeningForUpdates {
    print("✅ Transaction listener is active")
} else {
    print("⚠️ Transaction listener is not active")
}
```

## Получение Transaction ID

### Из результата покупки
```swift
let result = await PurchaseService.shared.performTestPurchase()
if result.success {
    let transactionId = result.transactionId
    print("Transaction ID: \(transactionId ?? "Unknown")")
}
```

### Из истории транзакций
```swift
let transactions = await PurchaseService.shared.getTransactionHistory()
for transaction in transactions {
    print("Transaction ID: \(transaction.id.description)")
    print("Product: \(transaction.productID)")
    print("Date: \(transaction.purchaseDate)")
}
```

### Из UI
После успешной покупки transaction ID отображается в секции "Last Transaction ID" и может быть скопирован в буфер обмена.

## Настройка для тестирования

### 1. StoreKit Configuration
Файл `StoreKitConfiguration.storekit` содержит конфигурацию тестовых продуктов. Для использования:

1. Откройте проект в Xcode
2. Выберите схему (scheme) для запуска
3. В настройках схемы включите "StoreKit Configuration"
4. Выберите файл `FlippinTestConfiguration`

### 2. Тестовые аккаунты
Для тестирования в симуляторе:
- Используйте встроенные тестовые аккаунты StoreKit
- Или создайте тестовый аккаунт в App Store Connect

### 3. Режим отладки
В Xcode включите:
- StoreKit Testing
- StoreKit Configuration
- StoreKit Transaction Manager

## Примеры использования

### Полный цикл покупки
```swift
// 1. Загрузить продукты
await PurchaseService.shared.loadProducts()

// 2. Выполнить покупку
let result = await PurchaseService.shared.performTestPurchase()

// 3. Обработать результат
if result.success {
    let transactionId = result.transactionId
    print("Покупка успешна! Transaction ID: \(transactionId ?? "Unknown")")
    
    // 4. Сохранить transaction ID
    UserDefaults.standard.set(transactionId, forKey: "last_transaction_id")
    
    // 5. Получить историю транзакций
    let transactions = await PurchaseService.shared.getTransactionHistory()
    print("Всего транзакций: \(transactions.count)")
} else {
    print("Ошибка покупки: \(result.error ?? "Unknown error")")
}
```

### Проверка покупок
```swift
// Проверить, есть ли покупки
let hasPurchases = await PurchaseExample.hasAnyPurchases()
if hasPurchases {
    print("У пользователя есть покупки")
}

// Получить последний transaction ID
if let lastTransactionId = PurchaseExample.getLastTransactionId() {
    print("Последний Transaction ID: \(lastTransactionId)")
}
```

## Обработка ошибок

### Типичные ошибки
- `Product not found` - Продукт не найден в App Store
- `Purchase cancelled by user` - Пользователь отменил покупку
- `Purchase pending approval` - Покупка ожидает одобрения
- `Transaction verification failed` - Ошибка верификации транзакции

### Обработка ошибок
```swift
let result = await PurchaseService.shared.performTestPurchase()
if !result.success {
    switch result.error {
    case "Product not found":
        print("Продукт не найден")
    case "Purchase cancelled by user":
        print("Пользователь отменил покупку")
    default:
        print("Ошибка: \(result.error ?? "Unknown")")
    }
}
```

## Аналитика

Система автоматически отслеживает события покупок:
- `purchase_completed` - Успешная покупка
- `purchase_failed` - Неудачная покупка
- `purchase_restored` - Восстановление покупок
- `purchase_test_opened` - Открытие тестирования покупок

## Безопасность

- Все транзакции верифицируются через StoreKit
- Transaction ID генерируется Apple и уникален
- Автоматическое прослушивание обновлений транзакций предотвращает потерю покупок
- Поддержка восстановления покупок
- Обработка всех возможных состояний покупки

## Поддержка

При возникновении проблем:
1. Проверьте настройки StoreKit Configuration
2. Убедитесь, что продукты настроены в App Store Connect
3. Проверьте логи Xcode для диагностики
4. Используйте StoreKit Transaction Manager для отладки 