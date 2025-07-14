# Настройка синхронизации StoreKit Configuration

## Обзор
Синхронизация StoreKit Configuration позволяет автоматически получать актуальные данные о продуктах из App Store Connect прямо в Xcode для тестирования.

## Пошаговая настройка

### 1. Подготовка в App Store Connect

#### 1.1 Создание продуктов
1. Войдите в [App Store Connect](https://appstoreconnect.apple.com/)
2. Выберите приложение "Flippin"
3. Перейдите в **"Функции"** → **"In-App Purchases"**
4. Создайте следующие продукты:

**Непотребляемый продукт:**
- Product ID: `com.dor.flippin.unlimited_cards`
- Type: Non-Consumable
- Reference Name: Unlimited Cards
- Price: $0.99

**Подписки:**
- Product ID: `com.dor.flippin.premium_monthly`
- Type: Auto-Renewable Subscription
- Reference Name: Premium Monthly
- Price: $4.99

- Product ID: `com.dor.flippin.premium_yearly`
- Type: Auto-Renewable Subscription
- Reference Name: Premium Yearly
- Price: $39.99

#### 1.2 Настройка подписок
1. Создайте **Subscription Group** с именем "Premium"
2. Добавьте оба продукта подписки в эту группу
3. Настройте **Family Sharing** для подписок

### 2. Настройка в Xcode

#### 2.1 Включение StoreKit Configuration
1. Откройте проект `Flippin.xcodeproj`
2. Выберите схему (scheme) для запуска
3. Нажмите **"Edit Scheme..."**
4. В разделе **"Run"** → **"Options"**
5. Включите **"StoreKit Configuration"**
6. Выберите файл `FlippinTestConfiguration`

#### 2.2 Настройка синхронизации
1. В Xcode выберите **"Product"** → **"StoreKit"** → **"Manage StoreKit Configuration"**
2. В открывшемся окне нажмите **"Sync with App Store Connect"**
3. Войдите в свой Apple Developer аккаунт
4. Выберите приложение "Flippin"
5. Нажмите **"Sync"**

### 3. Автоматическая синхронизация

#### 3.1 Настройка автоматической синхронизации
1. В окне **"Manage StoreKit Configuration"**
2. Включите **"Automatic Sync"**
3. Установите интервал синхронизации (рекомендуется: 1 час)

#### 3.2 Проверка синхронизации
После синхронизации в конфигурационном файле должны появиться:
- Актуальные цены из App Store Connect
- Правильные Product ID
- Настройки подписок
- Локализация

### 4. Тестирование синхронизации

#### 4.1 Проверка продуктов
```swift
// В коде проверьте, что продукты загружаются
let products = await PurchaseService.shared.products
print("Loaded \(products.count) products from App Store Connect")
```

#### 4.2 Тестирование покупок
1. Запустите приложение в симуляторе
2. Перейдите в **Settings** → **Purchase Testing**
3. Нажмите **"Start Test Purchase"**
4. Убедитесь, что используются реальные продукты

### 5. Устранение проблем

#### 5.1 Проблемы с синхронизацией
- **Ошибка аутентификации**: Проверьте Apple Developer аккаунт
- **Продукты не найдены**: Убедитесь, что продукты созданы в App Store Connect
- **Цены не обновились**: Подождите несколько минут и повторите синхронизацию

#### 5.2 Проверка статуса
```swift
// Проверьте статус синхронизации
if purchaseService.products.isEmpty {
    print("⚠️ Products not loaded - check sync status")
} else {
    print("✅ Products loaded successfully")
}
```

### 6. Ручная синхронизация

#### 6.1 Принудительная синхронизация
1. В Xcode: **Product** → **StoreKit** → **Manage StoreKit Configuration**
2. Нажмите **"Sync Now"**
3. Дождитесь завершения синхронизации

#### 6.2 Обновление конфигурации
После синхронизации конфигурационный файл автоматически обновится с:
- Актуальными ценами
- Правильными Product ID
- Настройками подписок
- Локализацией

### 7. Мониторинг синхронизации

#### 7.1 Логи синхронизации
В консоли Xcode вы увидите:
```
🔔 Starting transaction updates listener...
📦 Loaded 3 products from App Store Connect
✅ Sync completed successfully
```

#### 7.2 Проверка в UI
В приложении в разделе **Purchase Testing**:
- Статус "Transaction listener active" должен быть зеленым
- Продукты должны отображаться с актуальными ценами
- Тестовые покупки должны работать корректно

## Важные замечания

### Для разработки:
- Используйте **Sandbox** окружение для тестирования
- Создайте тестовые аккаунты в App Store Connect
- Тестируйте в симуляторе и на реальных устройствах

### Для продакшена:
- Убедитесь, что все продукты прошли ревью Apple
- Настройте цены для всех целевых регионов
- Протестируйте покупки в TestFlight

### Безопасность:
- Никогда не коммитьте реальные данные продуктов в git
- Используйте `.gitignore` для конфиденциальных данных
- Регулярно обновляйте конфигурацию

## Команды для отладки

### Проверка синхронизации
```bash
# В терминале Xcode
xcrun simctl spawn booted log show --predicate 'process == "StoreKit"' --last 1h
```

### Сброс конфигурации
```bash
# Удалить кэш StoreKit
rm -rf ~/Library/Developer/Xcode/DerivedData/*/StoreKit
``` 