# Тестирование покупок в Flippin

## Быстрый старт

### 1. Настройка проекта
1. Откройте проект `Flippin.xcodeproj` в Xcode
2. Выберите схему (scheme) для запуска
3. В настройках схемы включите "StoreKit Configuration"
4. Выберите файл `FlippinTestConfiguration` из папки `Configuration`

### ⚠️ Важно: Прослушивание транзакций
Система автоматически запускает прослушивание обновлений транзакций при запуске приложения. Это предотвращает потерю покупок и обеспечивает корректную обработку всех транзакций.

### 2. Запуск приложения
1. Запустите приложение в симуляторе или на устройстве
2. Перейдите в **Настройки** (Settings)
3. Найдите секцию **"Purchase Testing"**
4. Нажмите **"Open Purchase Test"**

### 3. Выполнение тестовой покупки
1. В открывшемся экране нажмите **"Start Test Purchase"**
2. Подтвердите покупку в диалоге StoreKit
3. Получите **Transaction ID** в результатах

## Получение Transaction ID

### Способ 1: Через UI
- После успешной покупки Transaction ID отображается в секции "Last Transaction ID"
- Нажмите "Copy to Clipboard" для копирования

### Способ 2: Программно
```swift
let result = await PurchaseService.shared.performTestPurchase()
if result.success {
    let transactionId = result.transactionId
    print("Transaction ID: \(transactionId ?? "Unknown")")
}
```

### Способ 3: Из истории транзакций
```swift
let transactions = await PurchaseService.shared.getTransactionHistory()
for transaction in transactions {
    print("Transaction ID: \(transaction.id.description)")
}
```

## Доступные продукты для тестирования

- **Unlimited Cards** (`com.dor.flippin.unlimited_cards`) - $0.99
- **Premium Monthly** (`com.dor.flippin.premium_monthly`) - $4.99
- **Premium Yearly** (`com.dor.flippin.premium_yearly`) - $39.99

## Примеры кода

### Простая тестовая покупка
```swift
Task {
    let result = await PurchaseService.shared.performTestPurchase()
    if result.success {
        print("✅ Покупка успешна!")
        print("📋 Transaction ID: \(result.transactionId ?? "Unknown")")
    } else {
        print("❌ Ошибка: \(result.error ?? "Unknown")")
    }
}
```

### Покупка конкретного продукта
```swift
Task {
    let result = await PurchaseService.shared.purchaseProduct("com.dor.flippin.unlimited_cards")
    if result.success {
        print("Transaction ID: \(result.transactionId ?? "Unknown")")
    }
}
```

### Получение истории транзакций
```swift
Task {
    let transactions = await PurchaseService.shared.getTransactionHistory()
    print("Найдено транзакций: \(transactions.count)")
    for transaction in transactions {
        print("ID: \(transaction.id.description)")
        print("Продукт: \(transaction.productID)")
        print("Дата: \(transaction.purchaseDate)")
    }
}
```

## Отладка

### Включение StoreKit Transaction Manager
1. В Xcode выберите **Debug** → **StoreKit** → **Manage Transactions**
2. Просматривайте и управляйте тестовыми транзакциями

### Логи
Все операции покупок логируются в консоль Xcode с эмодзи для удобства:
- 🧪 Тестовая покупка
- ✅ Успешная операция
- ❌ Ошибка
- 📋 Transaction ID
- 📦 Загрузка продуктов

## Структура файлов

```
Flippin/
├── Services/
│   └── PurchaseService.swift          # Основной сервис покупок
├── UI/Settings/
│   └── PurchaseTestView.swift         # UI для тестирования
├── Configuration/
│   └── StoreKitConfiguration.storekit # Конфигурация продуктов
├── Examples/
│   └── PurchaseExample.swift          # Примеры использования
└── Documentation/
    └── PurchaseSystem.md              # Подробная документация
```

## Поддержка

При возникновении проблем:
1. Проверьте настройки StoreKit Configuration в схеме
2. Убедитесь, что приложение запущено в режиме отладки
3. Проверьте логи Xcode
4. Используйте StoreKit Transaction Manager для диагностики

## Безопасность

- Все транзакции верифицируются через StoreKit 2
- Transaction ID генерируется Apple и уникален
- **Автоматическое прослушивание обновлений транзакций** предотвращает потерю покупок
- Поддержка восстановления покупок
- Полная обработка всех состояний покупки 