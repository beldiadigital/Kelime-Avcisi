# Kelime Avcısı - In-App Purchase Kurulum Rehberi

## ✅ Yapılan Değişiklikler

### 1. Paket Eklendi
- `in_app_purchase: ^3.2.0` paketi pubspec.yaml'a eklendi
- `flutter packages get` komutu ile yüklendi

### 2. IAPService Oluşturuldu
- `lib/services/iap_service.dart` dosyası oluşturuldu
- Üç elmas paketi tanımlandı:
  - `kelimeavcisi_50gems` - 50 Elmas (₺15.99)
  - `kelimeavcisi_100gems` - 100 Elmas + 10 Bonus (₺19.99)
  - `kelimeavcisi_200gems` - 200 Elmas + 30 Bonus (₺29.99)

### 3. Entegrasyon
- `main()` fonksiyonunda `IAPService.initialize()` çağrısı eklendi
- `GemStorePage`'de gerçek satın alma entegrasyonu yapıldı
- Demo mod: In-app purchase kullanılamazsa ücretsiz elmas ekleniyor

### 4. iOS Yapılandırması
- `ios/Runner/Configuration.storekit` dosyası oluşturuldu (Test için)

---

## 📱 iOS için App Store Connect Kurulumu

### Adım 1: App Store Connect'te Ürün Oluşturma

1. **App Store Connect**'e giriş yapın: https://appstoreconnect.apple.com
2. **My Apps** > Uygulamanızı seçin
3. **Features** > **In-App Purchases** sekmesine gidin
4. **Create** butonuna tıklayın

### Adım 2: Her Ürün İçin (3 adet):

#### 50 Elmas Paketi:
- **Type**: Consumable
- **Reference Name**: 50 Elmas
- **Product ID**: `kelimeavcisi_50gems`
- **Pricing**: ₺15.99 (veya $1.99)
- **Display Name (Turkish)**: 50 Elmas
- **Description (Turkish)**: Başlangıç paketi - 50 elmas

#### 100 Elmas Paketi:
- **Type**: Consumable
- **Reference Name**: 100 Elmas
- **Product ID**: `kelimeavcisi_100gems`
- **Pricing**: ₺19.99 (veya $2.99)
- **Display Name (Turkish)**: 100 Elmas
- **Description (Turkish)**: 100 elmas + 10 bonus elmas

#### 200 Elmas Paketi:
- **Type**: Consumable
- **Reference Name**: 200 Elmas
- **Product ID**: `kelimeavcisi_200gems`
- **Pricing**: ₺29.99 (veya $3.99)
- **Display Name (Turkish)**: 200 Elmas
- **Description (Turkish)**: 200 elmas + 30 bonus elmas

### Adım 3: Test Kullanıcısı Oluşturma

1. **Users and Access** > **Sandbox Testers**
2. **Add Sandbox Tester** (+) butonuna tıklayın
3. Test için yeni bir Apple ID oluşturun
4. Bu bilgileri kaydedin

### Adım 4: iOS Ayarları

1. iPhone/iPad'de **Settings** > **App Store**
2. Hesabınızdan çıkış yapın (Sign Out)
3. **Sandbox Account**'a test kullanıcınızla giriş yapın

---

## 🤖 Android için Google Play Console Kurulumu

### Adım 1: Google Play Console'da Ürün Oluşturma

1. **Google Play Console**'a giriş yapın
2. Uygulamanızı seçin
3. **Monetization** > **In-app products** > **Create product**

### Adım 2: Her Ürün İçin:

#### 50 Elmas:
- **Product ID**: `kelimeavcisi_50gems`
- **Name**: 50 Elmas
- **Description**: Başlangıç paketi
- **Price**: ₺15.99

#### 100 Elmas:
- **Product ID**: `kelimeavcisi_100gems`
- **Name**: 100 Elmas
- **Description**: 100 elmas + 10 bonus
- **Price**: ₺19.99

#### 200 Elmas:
- **Product ID**: `kelimeavcisi_200gems`
- **Name**: 200 Elmas
- **Description**: 200 elmas + 30 bonus
- **Price**: ₺29.99

### Adım 3: License Testing

1. **Settings** > **License Testing**
2. Test için Gmail adresinizi ekleyin
3. **License Test Response**: Licensed

---

## 🧪 Test Etme

### iOS'ta Test:
```bash
# Release modda build et (in-app purchase sadece release'de çalışır)
flutter build ios --release

# Xcode'dan çalıştır ve test et
```

### Android'de Test:
```bash
# Internal testing track'e yükle
flutter build appbundle --release

# Google Play Console'dan internal test'e yükle
```

### Geliştirme Ortamında:
- In-app purchase servisi kullanılamazsa otomatik olarak demo moda geçer
- Demo modda elmaslar ücretsiz eklenir
- Gerçek cihazda test etmek için release build gereklidir

---

## 💰 Nasıl Çalışır?

1. **Kullanıcı elmas satın almak ister**:
   - GemStorePage açılır
   - 3 paket gösterilir (50, 100, 200 elmas)

2. **Satın alma başlatılır**:
   - `IAPService.buyProduct()` çağrılır
   - App Store/Play Store satın alma ekranı açılır
   - Kullanıcı ödemeyi yapar

3. **Satın alma tamamlanır**:
   - `_onPurchaseUpdate()` callback çalışır
   - `_verifyAndDeliverProduct()` elmasları hesaba ekler
   - Başarı mesajı gösterilir

4. **Elmaslar kullanılır**:
   - Can satın alma
   - Tema satın alma
   - Power-up satın alma

---

## 🔐 Güvenlik Notları

- Ürün ID'leri asla değiştirilmemelidir
- Server-side verification önerilir (büyük oyunlarda)
- Receipt validation eklenebilir
- Fraud detection sistemi kurulmalıdır

---

## 📝 Yayınlama Öncesi Kontrol Listesi

- [ ] App Store Connect'te ürünler oluşturuldu
- [ ] Google Play Console'da ürünler oluşturuldu
- [ ] Test kullanıcıları ile test edildi
- [ ] Satın alma akışı sorunsuz çalışıyor
- [ ] Elmaslar doğru miktarda ekleniyor
- [ ] Bonuslar doğru hesaplanıyor
- [ ] Hata durumları test edildi
- [ ] Privacy policy güncellendi
- [ ] Terms of service güncellendi

---

## 🆘 Sorun Giderme

### "Products not found" hatası:
- App Store Connect/Play Console'da ürünlerin onaylandığından emin olun
- Product ID'lerin tam olarak eşleştiğinden emin olun
- 24 saat bekleyin (yeni ürünler için)

### Satın alma başlamıyor:
- Release build kullandığınızdan emin olun
- Test kullanıcısı ile giriş yaptığınızdan emin olun
- İnternet bağlantınızı kontrol edin

### Elmaslar eklenmiyor:
- `_verifyAndDeliverProduct()` fonksiyonunu kontrol edin
- Console loglarını inceleyin
- CurrencyManager'ın doğru çalıştığından emin olun

---

**Oluşturulma Tarihi**: 10 Aralık 2025
**Versiyon**: 1.0.0
