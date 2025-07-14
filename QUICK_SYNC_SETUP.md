# 🚀 Быстрая настройка синхронизации StoreKit

## 1. Проверка текущего статуса
```bash
./Flippin/Scripts/check_storekit_sync.sh
```

## 2. Настройка в App Store Connect
1. Откройте [App Store Connect](https://appstoreconnect.apple.com/)
2. Выберите приложение **"Flippin"**
3. **"Функции"** → **"In-App Purchases"**
4. Создайте продукты:
   - `com.dor.flippin.unlimited_cards` (Non-Consumable, $0.99)
   - `com.dor.flippin.premium_monthly` (Auto-Renewable, $4.99)
   - `com.dor.flippin.premium_yearly` (Auto-Renewable, $39.99)

## 3. Синхронизация в Xcode
1. Откройте проект в Xcode
2. **Product** → **StoreKit** → **Manage StoreKit Configuration**
3. Нажмите **"Sync with App Store Connect"**
4. Войдите в Apple Developer аккаунт
5. Выберите приложение "Flippin"
6. Нажмите **"Sync"**

## 4. Включение в схеме
1. **Edit Scheme...** → **Run** → **Options**
2. Включите **"StoreKit Configuration"**
3. Выберите `FlippinTestConfiguration`

## 5. Тестирование
1. Запустите приложение
2. **Settings** → **Purchase Testing**
3. Проверьте статус "Transaction listener active" ✅
4. Нажмите **"Start Test Purchase"**

## ✅ Готово!
Теперь ваша система покупок синхронизирована с App Store Connect и готова к тестированию!

## 🔧 Устранение проблем
- **Продукты не загружаются**: Проверьте синхронизацию в Xcode
- **Ошибки аутентификации**: Проверьте Apple Developer аккаунт
- **Цены не обновились**: Подождите и повторите синхронизацию 