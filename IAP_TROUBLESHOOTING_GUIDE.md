# 🛍️ IAP Hata Giderme Rehberi

## Apple'ın Reddetme Nedeni
**Guideline 2.1 - Performance - App Completeness**
- IAP ürünlerinde hata oluştu
- Device: iPad Air 11-inch (M3), iPadOS 26.1
- Submission ID: 4d64bf5d-7851-47ae-b72d-3782709f235c

---

## ✅ Çözüm Adımları (Sırasıyla Yapın)

### 1️⃣ Paid Apps Agreement Kontrolü (EN KRITIK!)

**App Store Connect'te:**
```
1. App Store Connect → Business → Agreements, Tax, and Banking
2. "Paid Apps Agreement" bölümüne bakın
3. Status kontrol edin:
   ✅ Active → Sorun yok
   ❌ Pending / Action Required → Devam edin
   
4. Eğer Pending ise:
   - "View Agreement" tıklayın
   - Tüm sayfaları okuyun
   - "Accept" butonuna basın
   - Tax form doldurun (W-8BEN for non-US)
   - Banking info ekleyin (IBAN)
```

**Önemli:**
- Bu sadece **Account Holder** (Ana hesap sahibi) tarafından yapılabilir
- Admin/Developer rolü yeterli değil!
- Agreement kabul edilmeden IAP çalışmaz!

---

### 2️⃣ IAP Products Kontrolü

**App Store Connect → Your App → In-App Purchases**

Her 3 ürün için kontrol edin:

#### Product: com.kelimeavcisi.gems100
- [ ] Reference Name: 100 Gems
- [ ] Product ID: `com.kelimeavcisi.gems100`
- [ ] Type: Consumable
- [ ] Status: Ready to Submit veya Approved
- [ ] Price: ₺49.99 (veya istediğiniz)
- [ ] Display Name (Turkish): 100 Elmas
- [ ] Description (Turkish): 100 elmas paketi
- [ ] Screenshot: Eklendi (en az 1 tane)
- [ ] Review Notes: Sandbox'ta test edilebilir

#### Product: com.kelimeavcisi.gems200
- [ ] Reference Name: 200 Gems  
- [ ] Product ID: `com.kelimeavcisi.gems200`
- [ ] Type: Consumable
- [ ] Status: Ready to Submit veya Approved
- [ ] Price: ₺89.99
- [ ] Display Name (Turkish): 200 Elmas
- [ ] Description (Turkish): 200 elmas paketi
- [ ] Screenshot: Eklendi

#### Product: com.kelimeavcisi.gems500
- [ ] Reference Name: 500 Gems
- [ ] Product ID: `com.kelimeavcisi.gems500`
- [ ] Type: Consumable
- [ ] Status: Ready to Submit veya Approved
- [ ] Price: ₺199.99
- [ ] Display Name (Turkish): 500 Elmas
- [ ] Description (Turkish): 500 elmas paketi
- [ ] Screenshot: Eklendi

**Her ürün için Submit butonuna basın!**

---

### 3️⃣ Sandbox Test Kullanıcısı Oluştur

**App Store Connect → Users and Access → Sandbox Testers**

1. "+" butonuna basın
2. Test kullanıcısı oluşturun:
   ```
   First Name: Test
   Last Name: Kelimeavcisi
   Email: kelimeavcisi.test@icloud.com (unique olmalı)
   Password: Test1234!
   Country: Turkey
   ```
3. Save edin

**iPhone/iPad'de:**
```
Settings → App Store → Sandbox Account
→ Sign in with test account
```

**ÖNEMLİ:** Gerçek Apple ID ile test yapmayın! Sadece sandbox hesabı kullanın.

---

### 4️⃣ Gerçek Cihazda Test

**Simulator çalışmaz! Gerçek iPhone/iPad gerekli.**

```bash
# Build ve deploy
flutter clean
flutter pub get
flutter build ios --release
```

**Xcode'da:**
1. Runner.xcworkspace açın
2. Gerçek cihaz seçin (Simulator değil!)
3. Signing & Capabilities → In-App Purchase capability eklendi mi kontrol edin
4. Run edin

---

### 5️⃣ Test Senaryosu

Uygulamayı açtığınızda **Xcode Console** loglarını izleyin:

#### Beklenen Loglar (Başarılı):
```
🛍️ Initializing IAP Service...
IAP Available: true
📦 Loading products: {com.kelimeavcisi.gems100, ...}
✅ Successfully loaded 3 products
  • com.kelimeavcisi.gems100: 100 Gems - ₺49.99
  • com.kelimeavcisi.gems200: 200 Gems - ₺89.99
  • com.kelimeavcisi.gems500: 500 Gems - ₺199.99
✅ IAP Service initialized successfully
```

#### Hatalı Loglar (Sorun var):
```
❌ Products NOT FOUND in App Store Connect: [com.kelimeavcisi.gems100, ...]
⚠️ WARNING: In-App Purchase is NOT available on this device!
```

#### Satın Alma Testi:
1. 100 Gems'e tıklayın
2. Console'da bakın:
   ```
   Attempting to buy product: com.kelimeavcisi.gems100
   Product found: 100 Gems - ₺49.99
   Purchase initiated: true
   Purchase update - Status: PurchaseStatus.purchased, ProductID: com.kelimeavcisi.gems100
   Added 100 gems for purchase: com.kelimeavcisi.gems100
   Purchase completed: com.kelimeavcisi.gems100
   ```

3. Sandbox popup çıkmalı: "Confirm Your In-App Purchase"
4. Apple ID şifresi: `Test1234!` (sandbox hesabınızın şifresi)
5. Success message görmeli

---

## 🔍 Yaygın Hatalar ve Çözümleri

### Hata 1: "Products NOT FOUND"
**Neden:**
- Product ID'ler App Store Connect'te yok
- Product Status "Ready to Submit" değil
- Paid Apps Agreement kabul edilmemiş

**Çözüm:**
1. App Store Connect'te product ID'leri kontrol edin
2. Her product için en az 1 localization ekleyin
3. Her product için 1 screenshot ekleyin
4. "Save" değil "Submit for Review" edin

---

### Hata 2: "IAP not available on this device"
**Neden:**
- Simulator kullanıyorsunuz
- Paid Apps Agreement yok
- Network bağlantısı yok

**Çözüm:**
1. Gerçek cihaz kullanın
2. WiFi bağlantısını kontrol edin
3. Paid Apps Agreement'ı kabul edin

---

### Hata 3: "Cannot connect to iTunes Store"
**Neden:**
- Sandbox hesabı ile login olmamışsınız
- Gerçek Apple ID kullanıyorsunuz

**Çözüm:**
1. Settings → App Store → Sign Out (gerçek hesaptan)
2. Uygulama içinde satın alma yapmayı deneyin
3. Sandbox popup çıktığında test hesabı ile girin

---

### Hata 4: Purchase başarılı ama gems eklenmiyor
**Neden:**
- CurrencyManager çalışmıyor
- SharedPreferences hatası

**Çözüm:**
```dart
// Console'da bakın:
Added 100 gems for purchase: com.kelimeavcisi.gems100
```
Bu log varsa kod çalışıyor, UI'da gems güncellenmiyor olabilir.

---

## 📱 Apple Review İçin Ekran Görüntüleri

Apple reviewer'lar test yaparken sorun yaşamaması için:

### Screenshot 1: IAP Paketi Seçimi
- Mağaza ekranı (gems paketleri görünür)
- Fiyatlar görünür
- "Satın Al" butonu açık

### Screenshot 2: Satın Alma Popup
- Apple'ın native satın alma popup'ı
- Product adı: "100 Gems"
- Fiyat: ₺49.99
- "Confirm" butonu

### Screenshot 3: Satın Alma Başarılı
- Gems sayısı arttı
- Success animasyonu/mesajı
- Kullanıcı gems'i görebiliyor

---

## 📋 Apple'a Göndermeniz Gereken Review Notes

App Store Connect'te Review Notes kısmına ekleyin:

```
IN-APP PURCHASE TESTING:

Test Account (Sandbox):
Email: kelimeavcisi.test@icloud.com
Password: Test1234!

IAP Products:
1. com.kelimeavcisi.gems100 - 100 Gems (₺49.99)
2. com.kelimeavcisi.gems200 - 200 Gems (₺89.99)
3. com.kelimeavcisi.gems500 - 500 Gems (₺199.99)

How to test:
1. Launch the app
2. Tap "MAĞAZA" button on home screen
3. Select any gems package
4. Complete purchase with sandbox account
5. Gems will be added to your balance immediately

All IAP products are configured as consumable and work in sandbox environment.
Paid Apps Agreement has been accepted.

Note: IAP only works on real devices, not on simulator.
```

---

## ✅ Final Checklist (Submit Öncesi)

- [ ] Paid Apps Agreement → **Active** status
- [ ] Tax form dolduruldu (W-8BEN)
- [ ] Banking info eklendi (IBAN)
- [ ] 3 IAP product → **Ready to Submit** veya **Approved**
- [ ] Her product için screenshot var
- [ ] Her product için Turkish localization var
- [ ] Sandbox test kullanıcısı oluşturuldu
- [ ] Gerçek cihazda test edildi
- [ ] Purchase flow çalışıyor (console logları kontrol edildi)
- [ ] Gems ekleniyor (UI'da görünüyor)
- [ ] Restore Purchases çalışıyor
- [ ] StoreKit Configuration file güncellendi (iOS/Runner/Configuration.storekit)
- [ ] Review Notes eklendi (sandbox credentials)
- [ ] Screenshot'lar App Store Connect'e eklendi

---

## 🚀 Submit Sonrası

1. **Resubmit** edin
2. **Reply to Apple** (App Store Connect'te message'a cevap verin):

```
Hello Apple Review Team,

Thank you for your feedback. I have resolved the In-App Purchase issues:

✅ Paid Apps Agreement has been accepted
✅ All IAP products (gems100, gems200, gems500) are configured and submitted
✅ Products tested successfully in sandbox environment
✅ Sandbox test account provided in Review Notes
✅ IAP flow works correctly on real device (tested on iPad)
✅ Enhanced error logging added to help diagnose any issues

The IAP system is now fully functional and ready for review.

Please find the sandbox test credentials in the Review Notes section.

Thank you for your patience!
```

3. **3-5 gün** içinde sonuç gelir

---

## 📞 Acil Durum

Eğer hala sorun devam ederse:

1. **Apple'a telefon talebi gönderin:**
   - App Store Connect → App Review → Request a call
   - 3-5 iş günü içinde ararlar
   - Türkçe destek de var

2. **Apple Developer Forums:**
   - https://developer.apple.com/forums/
   - "In-App Purchase not working in review" başlığıyla konu açın

3. **App Review Appointment:**
   - Meet with Apple için randevu alın
   - Salı/Perşembe günleri mevcut
   - Ekran paylaşımı yaparak sorunu gösterin

---

## 🎯 Özet

**EN ÖNEMLİ 3 ŞEY:**
1. ✅ Paid Apps Agreement → **ACCEPT edilmeli**
2. ✅ IAP Products → **SUBMIT edilmeli** (Save değil!)
3. ✅ Gerçek cihazda → **TEST edilmeli** (Simulator değil!)

Başarılar! 🚀
