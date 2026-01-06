# App Store Submission - Düzeltme Raporu

**Tarih:** 6 Ocak 2026  
**Versiyon:** 1.0.0+6

## ✅ Düzeltilen Sorunlar

### 1. ✅ Google Play Referansları Kaldırıldı (Guideline 2.3.10)
**Değişiklik:**
- `lib/main.dart` dosyasında "Play Store" referansı kaldırıldı
- **ÖNCE:** `🔒 Güvenli ödeme ile App Store üzerinden satın alınır`
- **SONRA:** `🔒 Güvenli ödeme sistemi`

**Dosya:** [lib/main.dart](lib/main.dart#L5639)

---

### 2. ✅ "Restore Purchases" Butonu Eklendi (Guideline 3.1.1)
**Değişiklik:**
- Elmas Mağazası sayfasına (GemStorePage) belirgin bir "Satın Alımları Geri Yükle" butonu eklendi
- Can Mağazası sayfasına (LifeShopPage) "Satın Alımları Geri Yükle" butonu eklendi  
- Ayarlar sayfasına (SettingsSheet) "Satın Alımları Geri Yükle" butonu eklendi

**Özellikler:**
- ✅ Kullanıcı tarafından tetiklenen açık buton
- ✅ Görsel olarak belirgin (turuncu renk, icon + text)
- ✅ Loading göstergesi ile feedback
- ✅ Başarı/hata mesajları

**Dosyalar:** 
- [lib/main.dart](lib/main.dart#L5340) - GemStorePage
- [lib/main.dart](lib/main.dart#L4923) - LifeShopPage
- [lib/main.dart](lib/main.dart#L6216) - SettingsSheet

---

### 3. ✅ In-App Purchase Hataları Düzeltildi (Guideline 2.1)
**Sorun:** Ürün ID'leri StoreKit yapılandırması ile uyumsuzdu

**Değişiklikler:**

#### A. IAPService Ürün ID'leri Güncellendi
```dart
// ÖNCE (Hatalı):
gems100 = 'kelimeavcisi_100gems'  → 100 elmas
gems250 = 'kelimeavcisi_250gems'  → 250 elmas
gems500 = 'kelimeavcisi_500gems'  → 500 elmas

// SONRA (Doğru - StoreKit ile uyumlu):
gems50 = 'kelimeavcisi_50gems'    → 50 elmas
gems100 = 'kelimeavcisi_100gems'  → 110 elmas (100+10 bonus)
gems200 = 'kelimeavcisi_200gems'  → 230 elmas (200+30 bonus)
```

#### B. GemStorePage Paketleri Güncellendi
```dart
// ÖNCE:
- 100 Elmas - ₺29.99
- 250 Elmas - ₺49.99
- 500 Elmas - ₺79.99

// SONRA (StoreKit ile uyumlu):
- 50 Elmas - ₺15.99
- 100 Elmas + 10 Bonus - ₺19.99
- 200 Elmas + 30 Bonus - ₺29.99
```

**Dosyalar:**
- [lib/services/iap_service.dart](lib/services/iap_service.dart#L11-L13)
- [lib/main.dart](lib/main.dart#L5151-L5175) - gemPackages
- [ios/Runner/Configuration.storekit](ios/Runner/Configuration.storekit)

---

### 4. ✅ Çocuk Kategorisi Uyumluluk (Guideline 1.3)
**Durum:** Uygulama şu anda **hiçbir** analytics, tracking veya IDFA kullanmıyor.

**Doğrulamalar:**
- ❌ Google AdMob yok
- ❌ Firebase Analytics yok
- ❌ AppTrackingTransparency yok
- ❌ IDFA toplama yok
- ✅ Sadece yerel veri depolama var

**App Store Connect'te Yapılacaklar:**
1. App Privacy bölümünde "Data Used to Track You" → **NO** olarak işaretle
2. Tüm tracking sorularına **NO** yanıtı ver
3. Sadece "In-App Purchase" bilgisini işaretle

---

### 5. ✅ Gizlilik Politikası URL'si (Guideline 5.1.4)
**Oluşturulan Dosya:** `privacy-policy.html`

**Yayınlama Seçenekleri:**

#### Seçenek 1: GitHub Pages (Önerilen)
```bash
# 1. GitHub'a commit et
git add privacy-policy.html
git commit -m "Add privacy policy"
git push

# 2. GitHub Pages'i aktifleştir
# Repo Settings → Pages → Source: main branch → Save

# 3. URL'i App Store Connect'e ekle:
# https://[GITHUB_USERNAME].github.io/kelimeavcisi/privacy-policy.html
```

#### Seçenek 2: Netlify Drop (En Hızlı)
1. [app.netlify.com/drop](https://app.netlify.com/drop) adresine git
2. `privacy-policy.html` dosyasını sürükle-bırak
3. Verilen URL'i App Store Connect'e yapıştır

#### Seçenek 3: Firebase Hosting
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

---

## 📋 App Store Connect'te Yapılması Gerekenler

### A. Privacy Policy URL Ekleme
1. App Store Connect → **Kelime Avcısı** → App Information
2. Privacy Policy URL bölümünü bul
3. Gizlilik politikası URL'ini ekle
4. **Save** butonuna tıkla

### B. App Privacy Bilgilerini Güncelleme
1. App Store Connect → **App Privacy**
2. "Data Used to Track You" → **NO**
3. "Data Collected" bölümünde sadece:
   - ✅ **Purchases** (In-App Purchase için)
   - ❌ Diğer tüm seçenekler NO
4. **Save** ve **Publish**

### C. In-App Purchase Ürünlerini Gönderme
1. **Features → In-App Purchases**
2. Her ürün için:
   - `kelimeavcisi_50gems` → **Submit for Review**
   - `kelimeavcisi_100gems` → **Submit for Review**
   - `kelimeavcisi_200gems` → **Submit for Review**
3. **Screenshot** ekle (her ürün için mağaza ekran görüntüsü)

**Screenshot Gereksinimleri:**
- Elmas mağazası sayfasını gösteren ekran görüntüsü
- Paketlerin ve fiyatların görünür olması
- iPhone ve iPad boyutları

### D. Yeni Build Yükleme
```bash
# Versiyonu artır
# pubspec.yaml → version: 1.0.0+6

# iOS build oluştur
flutter build ios --release

# Xcode ile Archive → Upload to App Store

# App Store Connect'te:
# TestFlight → Yeni build → Review'e gönder
```

---

## 🎯 Özet Checklist

- [x] Google Play referansları kaldırıldı
- [x] "Restore Purchases" butonu 3 yerde eklendi
- [x] IAP ürün ID'leri StoreKit ile uyumlu hale getirildi
- [x] Gizlilik politikası HTML dosyası oluşturuldu
- [ ] Gizlilik politikası online yayınlandı (GitHub Pages/Netlify)
- [ ] App Store Connect'te Privacy Policy URL eklendi
- [ ] App Privacy bilgileri güncellendi (NO tracking)
- [ ] IAP ürünleri screenshot ile submit edildi
- [ ] Yeni build (1.0.0+6) yüklendi

---

## 📞 Sonraki Adımlar

1. **Gizlilik politikasını yayınla** (GitHub Pages veya Netlify)
2. **App Store Connect'i güncelle** (Privacy URL + App Privacy)
3. **IAP ürünlerini submit et** (screenshot ile)
4. **Yeni build yükle** (version 1.0.0+6)
5. **Review'e gönder**

---

## ⚠️ Önemli Notlar

### Kids Category Hakkında
Eğer Apple tekrar "Kids Category" ile ilgili sorun çıkarırsa:

**ÇÖZÜM:** App Store Connect'te kategoriyi değiştir
- **ÖNCE:** Primary: Kids, Secondary: Education
- **SONRA:** Primary: Games, Secondary: Word

Bu şekilde Kids Category gereksinimlerinden kaçınılır.

### IAP Test Edilmesi
Yeni build yüklendikten sonra TestFlight'ta test et:
1. TestFlight'tan uygulamayı indir
2. Elmas mağazasını aç
3. Bir paket satın almayı dene (Sandbox)
4. "Satın Alımları Geri Yükle" butonunu test et
5. Herhangi bir hata varsa düzelt

---

**Hazırlayan:** GitHub Copilot  
**Tarih:** 6 Ocak 2026
