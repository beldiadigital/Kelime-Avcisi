# 📋 KELIME AVCISI - PRODUCTION YAYINLAMA KONTROL LİSTESİ

## ✅ TAMAMLANAN HAZIRLIKLAR

### 1. Kod Kalitesi
- [x] Lint hataları temizlendi (0 hata)
- [x] Compile hataları yok
- [x] Kullanılmayan kod temizlendi
- [x] Test modu KAPALI (AdMobHelper.isTestMode = false)

### 2. Bundle ID / Application ID
- [x] **iOS Bundle ID**: `com.beldiadigital.kelimeavcisi`
- [x] **Android Application ID**: `com.beldiadigital.kelimeavcisi`
- [x] Tüm platform dosyaları güncellendi

### 3. Versiyon Bilgileri
- [x] **Version**: 1.0.0
- [x] **Build Number**: 1
- [x] pubspec.yaml doğru yapılandırıldı

### 4. In-App Purchase (IAP) Konfigürasyonu
#### Product ID'ler:
- [x] **100 Elmas**: `kelimeavcisi_100gems` (₺29.99)
- [x] **250 Elmas**: `kelimeavcisi_250gems` (₺49.99)
- [x] **500 Elmas**: `kelimeavcisi_500gems` (₺79.99)
- [x] **Reklamsız Abonelik**: `kelimeavcisi_noads_monthly` (₺49.99/ay)

#### Demo Modu:
- [x] Test için demo mod aktif (App Store Connect ürünleri olmadan test edilebilir)
- [x] Production'da gerçek ürünler kullanılacak

### 5. AdMob Konfigürasyonu
- [x] **Test Modu**: KAPALI (isTestMode = false)
- [x] **Production Ad Unit ID**: `ca-app-pub-9098317866883430/5233275608`
- [x] Banner reklamlar oyun ekranında ve ana menüde aktif
- [x] Reklamsız abonelik kontrolü entegre

### 6. Monetizasyon Sistemi
- [x] Çift para birimi: Altın (kazanılabilir) + Elmas (satın alınabilir)
- [x] Elmas sadece gerçek parayla satın alınabilir
- [x] Temalar hem altın hem elmas ile satın alınabilir
- [x] Can mağazası altın ile çalışır
- [x] Reklamsız abonelik banner reklamları kaldırır

## ⚠️ YAYINLAMADAN ÖNCE YAPILMASI GEREKENLER

### App Store Connect Yapılandırması

#### 1. Uygulama Kaydı
1. App Store Connect'e giriş yapın
2. "My Apps" → "+" → "New App"
3. **Bundle ID**: `com.beldiadigital.kelimeavcisi`
4. **App Name**: "Kelime Avcısı"
5. **Primary Language**: Turkish
6. **SKU**: `kelimeavcisi-ios`

#### 2. In-App Purchase Ürünleri
**Consumable Products (Tüketilebilir):**

**Ürün 1:**
- Product ID: `kelimeavcisi_100gems`
- Reference Name: 100 Elmas Paketi
- Price: ₺29.99
- Display Name (TR): 100 Elmas
- Description (TR): 100 elmas satın alın ve oyunda kullanın

**Ürün 2:**
- Product ID: `kelimeavcisi_250gems`
- Reference Name: 250 Elmas Paketi
- Price: ₺49.99
- Display Name (TR): 250 Elmas
- Description (TR): 250 elmas satın alın ve oyunda kullanın

**Ürün 3:**
- Product ID: `kelimeavcisi_500gems`
- Reference Name: 500 Elmas Paketi
- Price: ₺79.99
- Display Name (TR): 500 Elmas
- Description (TR): 500 elmas satın alın ve oyunda kullanın

**Auto-Renewable Subscription (Otomatik Yenilenen Abonelik):**

**Subscription Group Oluştur:**
- Name: Premium Features
- Reference Name: premium-features

**Abonelik:**
- Product ID: `kelimeavcisi_noads_monthly`
- Reference Name: Reklamsız Aylık Abonelik
- Duration: **1 Month** (1 Ay)
- Price: ₺49.99/ay
- Display Name (TR): Reklamsız Oyun
- Description (TR): Tüm reklamları kaldırın ve kesintisiz oynayın
- Subscription Group: Premium Features

#### 3. Sandbox Test Kullanıcısı
1. Users and Access → Sandbox → Testers
2. "+" butonuna tıklayın
3. Test e-posta ve şifre oluşturun
4. Test cihazında bu kullanıcı ile test edin

### AdMob Yapılandırması

#### 1. AdMob Hesabı
1. https://admob.google.com adresine gidin
2. Uygulamayı ekleyin:
   - **Platform**: iOS ve Android
   - **App Name**: Kelime Avcısı
   - **Bundle ID (iOS)**: com.beldiadigital.kelimeavcisi
   - **Package Name (Android)**: com.beldiadigital.kelimeavcisi

#### 2. Ad Unit Oluşturma
1. "Ad units" → "Add ad unit"
2. **Format**: Banner
3. **Ad unit name**: Kelime Avcısı Banner
4. Oluşturulan Ad Unit ID'yi not edin

**Mevcut Production ID**: `ca-app-pub-9098317866883430/5233275608`
- Bu ID zaten kodda tanımlı
- Kendi AdMob hesabınızdan aldığınız ID ile değiştirin

#### 3. Ödeme Bilgileri
1. Payments → Settings
2. Ödeme bilgilerinizi ekleyin
3. Vergi bilgilerini tamamlayın

### Test Süreci

#### 1. iOS Test
```bash
# Debug build
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run --debug

# Release build (gerçek cihazda)
flutter build ios --release
```

#### 2. Android Test
```bash
# Debug build
flutter clean
flutter pub get
flutter run --debug

# Release build
flutter build apk --release
flutter build appbundle --release
```

#### 3. IAP Test Kontrolü
- [ ] Sandbox kullanıcısı ile giriş yapıldı
- [ ] 100 Elmas paketi satın alındı ve teslim edildi
- [ ] 250 Elmas paketi satın alındı ve teslim edildi
- [ ] 500 Elmas paketi satın alındı ve teslim edildi
- [ ] Reklamsız abonelik satın alındı
- [ ] Abonelik sonrası reklamlar kayboldu
- [ ] Elmaslar doğru miktarda hesaba eklendi

#### 4. AdMob Test Kontrolü
- [ ] Banner reklamlar ana menüde görünüyor
- [ ] Banner reklamlar oyun ekranında görünüyor
- [ ] Reklamsız abonelik sonrası reklamlar gizlendi
- [ ] Gerçek cihazda reklamlar yüklendi (10-15 dakika bekleyin)

### Build ve Yayınlama

#### iOS Build
```bash
# Archive oluştur
flutter build ipa --release

# Xcode ile manuel archive (önerilen)
open ios/Runner.xcworkspace
# Product → Archive
# Distribute App → App Store Connect
```

#### Android Build
```bash
# App Bundle (önerilen)
flutter build appbundle --release

# APK
flutter build apk --release
```

#### App Store Submission
1. App Store Connect'te version oluştur
2. Screenshots ekle (6.7", 6.5", 5.5" için)
3. App Preview (opsiyonel)
4. Description, keywords, support URL
5. Privacy Policy URL ekle
6. Age Rating: 4+
7. Submit for Review

#### Google Play Submission
1. Google Play Console → Create App
2. App details
3. Store listing
4. Content rating
5. Target audience
6. Privacy policy
7. App access
8. Ads declaration: "Yes, contains ads"
9. Upload AAB file
10. Submit for Review

## 🔒 GÜVENLİK KONTROL LİSTESİ

- [x] API anahtarları kodda yok (AdMob ID hariç - bu public olabilir)
- [x] Demo mode production'da devre dışı
- [x] Test mode kapalı
- [x] Bundle ID production için hazır
- [x] Version ve build number doğru

## 📊 ÖNEMLİ NOTLAR

### Gelir Modeli
- **Ücretsiz Tier**: Reklam destekli
- **IAP Paketleri**: 3 elmas paketi (₺29.99, ₺49.99, ₺79.99)
- **Abonelik**: Reklamsız oyun (₺49.99/ay)

### İlk Yayınlama Süreleri
- **App Store Review**: 24-48 saat
- **Google Play Review**: 1-7 gün
- **AdMob Onay**: 1-2 saat (ilk reklamlar için)
- **IAP Aktif Olması**: Hemen (App Store Connect'te ürün onayı sonrası)

### Beklenmedik Durumlar
- İlk günlerde AdMob reklamları sınırlı gösterilebilir
- IAP test modunda "Sandbox" yazısı görünür (normal)
- Production'da ödeme gerçekleşir (sandbox kullanıcısı hariç)
- Abonelik ilk ay sonunda otomatik yenilenir

## 🎯 BAŞARIYLA YAYINLANDIKTAN SONRA

- [ ] İlk kullanıcı geri bildirimlerini takip et
- [ ] Crash raporlarını izle (Crashlytics önerilir)
- [ ] IAP satışlarını kontrol et
- [ ] AdMob gelirlerini takip et
- [ ] Kullanıcı yorumlarını cevapla
- [ ] Analytics ekle (Firebase Analytics)
- [ ] A/B test için farklı reklam pozisyonları dene

---

**Son Güncelleme**: 11 Aralık 2025
**Hazırlayan**: GitHub Copilot
**Proje**: Kelime Avcısı - Beldia Digital
