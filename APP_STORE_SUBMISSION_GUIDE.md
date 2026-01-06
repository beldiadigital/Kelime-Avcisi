# � App Store Submission Rehberi - Kelime Avcısı v1.0.0 Build 4

**Tarih:** 25 Aralık 2025  
**Sürüm:** 1.0.0 Build 4  
**Status:** ✅ iOS Build Tamamlandı (22.7MB)  
**Next:** Xcode Archive → Upload → Submit

---

## 📋 Xcode Archive & Upload Adımları

### Kod Hazırlığı
- [x] Test mode kapatıldı (AdMobHelper.isTestMode = false)
- [x] Demo mode kaldırıldı
- [x] Bundle ID güncellendi (com.beldiadigital.kelimeavcisi)
- [x] Lint hataları temizlendi
- [x] Production build test edildi
- [x] Günlük ödül otomatik gösterim aktif
- [x] App Store rating sistemi entegre
- [x] Zamanlayıcı sistemi eklendi
- [x] url_launcher paketi eklendi

### Monetizasyon
- [x] IAP Product ID'leri doğru
  - kelimeavcisi_100gems (₺29.99)
  - kelimeavcisi_250gems (₺49.99)
  - kelimeavcisi_500gems (₺79.99)
  - kelimeavcisi_noads_monthly (₺49.99/ay)
- [x] AdMob Production ID aktif
- [x] Reklamsız abonelik kontrolü çalışıyor
- [x] Banner reklamlar entegre (ana menü + oyun)

---

## 🚀 APP STORE'A GÖNDERİM ADIMLARI

### ADIM 1: Xcode'da Archive Oluştur

#### 1.1. Xcode'u Aç
```bash
open /Users/bahadirarica/development/kelimeavcisi/ios/Runner.xcworkspace
```

#### 1.2. Signing Ayarları
1. Sol panelde **Runner** projesine tıkla
2. **TARGETS** → **Runner** seç
3. **Signing & Capabilities** tab'ı
4. **Team**: Apple Developer hesabını seç
5. **Bundle Identifier**: `com.beldiadigital.kelimeavcisi` kontrol et
6. **Automatically manage signing**: ✅ İşaretli olsun

#### 1.3. Build Configuration
1. Üst menüden **Product** → **Scheme** → **Edit Scheme**
2. **Run** → **Build Configuration**: **Release**
3. Close

#### 1.4. Device Seçimi
1. Üst toolbar'da device selector
2. **Any iOS Device (arm64)** seç
3. Gerçek cihaz bağlıysa onu da seçebilirsiniz

#### 1.5. Clean & Archive
```
1. Product → Clean Build Folder (Shift+Cmd+K)
2. 2-3 saniye bekle
3. Product → Archive
4. Build başlayacak (3-5 dakika)
```

**Başarılı Olursa:**
- Organizer penceresi açılacak
- Archive listede görünecek

**Hata Alırsanız:**
- Hata mesajını okuyun
- Genelde signing veya provisioning profile sorunudur
- Xcode → Preferences → Accounts → Download Manual Profiles

---

### ADIM 2: App Store Connect'e Yükle

#### 2.1. Organizer'da
1. En son archive'ı seç
2. **Distribute App** butonuna tıkla

#### 2.2. Distribution Method
- **App Store Connect** seç
- **Next**

#### 2.3. Distribution Options
- **Upload** seç
- **Next**

#### 2.4. App Store Connect Distribution Options
- **Automatically manage signing** seçili olsun
- **Next**

#### 2.5. Re-sign
- Varsayılan ayarları kabul et
- **Next**

#### 2.6. Review
- Özet bilgileri kontrol et
- **Upload**

#### 2.7. Upload Süreci
- Upload başlayacak (5-10 dakika)
- İnternet hızına bağlı
- Tamamlanınca **"Upload Successful"** mesajı

---

### ADIM 3: App Store Connect'te Uygulama Oluştur

#### 3.1. App Store Connect'e Giriş
https://appstoreconnect.apple.com

#### 3.2. Yeni Uygulama Oluştur
1. **My Apps** → **+** → **New App**
2. **Platforms**: iOS ✅
3. **Name**: Kelime Avcısı
4. **Primary Language**: Turkish
5. **Bundle ID**: com.beldiadigital.kelimeavcisi (dropdown'dan seç)
6. **SKU**: kelimeavcisi-ios (unique ID)
7. **User Access**: Full Access
8. **Create**

---

### ADIM 4: In-App Purchase Ürünlerini Oluştur

#### 4.1. Consumable Products (Elmas Paketleri)

**Ürün 1: 100 Elmas**
1. In-App Purchases → **+**
2. Type: **Consumable**
3. Reference Name: `100 Elmas Paketi`
4. Product ID: `kelimeavcisi_100gems`
5. Price: Tier 10 (₺29.99)
6. Localizations → **Add Localization**
   - Language: Turkish
   - Display Name: `100 Elmas`
   - Description: `100 elmas satın alın ve oyunda kullanın!`
7. Review Notes: `Elmas paketi - oyun içi premium para birimi`
8. Screenshot: (opsiyonel)
9. **Save**

**Ürün 2: 250 Elmas**
1. In-App Purchases → **+**
2. Type: **Consumable**
3. Reference Name: `250 Elmas Paketi`
4. Product ID: `kelimeavcisi_250gems`
5. Price: Tier 16 (₺49.99)
6. Localizations → Turkish
   - Display Name: `250 Elmas`
   - Description: `250 elmas satın alın - popüler seçim!`
7. **Save**

**Ürün 3: 500 Elmas**
1. In-App Purchases → **+**
2. Type: **Consumable**
3. Reference Name: `500 Elmas Paketi`
4. Product ID: `kelimeavcisi_500gems`
5. Price: Tier 24 (₺79.99)
6. Localizations → Turkish
   - Display Name: `500 Elmas`
   - Description: `500 elmas satın alın - en iyi değer!`
7. **Save**

#### 4.2. Auto-Renewable Subscription (Reklamsız Abonelik)

**Subscription Group Oluştur:**
1. In-App Purchases → **Subscriptions** tab
2. **Create Subscription Group**
3. Reference Name: `Premium Features`
4. **Create**

**Abonelik Ürünü:**
1. Subscription Group → **+**
2. Reference Name: `Reklamsız Oyun - Aylık`
3. Product ID: `kelimeavcisi_noads_monthly`
4. Subscription Duration: **1 Month**
5. Subscription Prices → **Add Subscription Price**
   - Country: Turkey
   - Price: ₺49.99
6. Localizations → Turkish
   - Display Name: `Reklamsız Oyun`
   - Description: `Tüm reklamları kaldırın ve kesintisiz oynayın!`
7. Review Information:
   - Screenshot: (opsiyonel)
   - Review Notes: `Aylık abonelik - tüm reklamları kaldırır`
8. **Save**

#### 4.3. Tüm Ürünleri Submit
- Her ürün için **Submit for Review**
- Status: **Waiting for Review** → **Ready to Submit**

---

### ADIM 5: App Information Doldur

#### 5.1. General Information
1. **App Name**: Kelime Avcısı
2. **Subtitle**: Eğlenceli Kelime Oyunu
3. **Category**: 
   - Primary: Games
   - Secondary: Word
4. **Content Rights**: I certify that...

#### 5.2. App Privacy
1. **Privacy Policy URL**: (website gerekli)
   - Örnek: https://beldiadigital.com/privacy
2. **Privacy Practices**:
   - Data Types: None (eğer kullanıcı verisi toplamıyorsanız)
   - Veya uygun seçenekleri işaretleyin

#### 5.3. Age Rating
1. **Age Rating Questionnaire** doldur
2. Şiddet, argo vb. yok → **4+**

#### 5.4. App Review Information
1. **Contact Information**:
   - First Name: [Adınız]
   - Last Name: [Soyadınız]
   - Phone: +90...
   - Email: [email]
2. **Notes**: (opsiyonel test talimatları)

---

### ADIM 6: Version Information

#### 6.1. Version 1.0.0 Doldur
1. **What's New in This Version**:
```
🎮 Kelime Avcısı'nın ilk sürümü!

✨ Özellikler:
• 3 zorluk seviyesi (Kolay, Orta, Zor)
• Her seviyede 10 farklı bölüm
• Günlük ödül sistemi
• Başarım ve görev sistemi
• 6 farklı tema
• Zamanlayıcı ve yıldız sistemi
• Liderlik tablosu
• Ses efektleri ve müzik

💎 Elmas paketleri ve reklamsız oyun seçeneği!

Eğlenceli bir kelime avı deneyimi için hemen indirin! 🎯
```

#### 6.2. Screenshots Yükle

**Gerekli Ekran Boyutları:**
1. **6.7" Display (iPhone 14 Pro Max, 15 Pro Max)**
   - 1290 x 2796 pixels
   - En az 1 screenshot (maks 10)

2. **6.5" Display (iPhone 11 Pro Max, XS Max)**
   - 1242 x 2688 pixels
   - En az 1 screenshot

3. **5.5" Display (iPhone 8 Plus)**
   - 1242 x 2208 pixels
   - En az 1 screenshot

**Screenshot Önerileri:**
1. Ana menü (oyun adı ve özellikler)
2. Oyun ekranı (balonlar ve kelimeler)
3. Seviye seçimi
4. Başarımlar ekranı
5. Tema mağazası

**Screenshot Alma:**
```bash
# Simulator'da:
1. Simulator aç (iPhone 15 Pro Max)
2. Flutter run
3. Cmd+S (screenshot alır)
4. Desktop'a kaydedilir
```

#### 6.3. App Icon
- 1024 x 1024 pixels
- PNG, JPG veya JPEG
- Transparency yok
- Alpha channel yok

---

### ADIM 7: Build Seçimi

#### 7.1. Build Bekleme
- Upload'tan sonra 10-30 dakika içinde görünür
- **Activity** tab'ından durumu izle
- Processing → Ready to Submit

#### 7.2. Build Seç
1. **Build** sekmesi
2. **Select a build before you submit your app**
3. Upload ettiğiniz build'i seç
4. **Done**

---

### ADIM 8: Submit for Review

#### 8.1. Final Kontrol
- [ ] Tüm bilgiler dolu
- [ ] Screenshots yüklendi
- [ ] Build seçildi
- [ ] IAP ürünleri hazır
- [ ] Privacy policy eklendi
- [ ] Age rating tamamlandı

#### 8.2. Submit
1. **Add for Review** (sağ üst)
2. Export Compliance sorularını cevapla:
   - "Does your app use encryption?" → **No** (basit oyun)
3. **Submit for Review**

#### 8.3. Review Süreci
- Status: **Waiting for Review**
- Ortalama: 24-48 saat
- Bazen 12 saat, bazen 7 gün

---

## 📋 SANDBOX TEST (Submit Öncesi)

### Sandbox Tester Oluştur
1. App Store Connect → Users and Access
2. **Sandbox Testers** tab
3. **+** → Add Tester
4. Email: test@example.com (gerçek email gerekmez)
5. Password: Test1234!
6. Country: Turkey
7. **Invite**

### Test Süreci
1. iPhone'da Settings → App Store
2. **Sandbox Account** girin
3. Uygulamayı çalıştır
4. Elmas satın almayı dene
5. "Sandbox" yazısı görünmeli
6. Satın alma tamamlanmalı
7. Elmaslar hesaba eklenmeli

---

## ⚠️ YAYGINSDK SORUNLAR ve ÇÖZÜMLER

### "No builds are available"
**Çözüm**: Upload'tan sonra 30 dakika bekleyin

### "Invalid Bundle"
**Çözüm**: Bundle ID eşleşmiyor, kontrol edin

### "Missing Compliance"
**Çözüm**: Export compliance sorusunu cevaplayın

### "Missing Privacy Policy"
**Çözüm**: Privacy Policy URL ekleyin

### "Invalid Icon"
**Çözüm**: 1024x1024 PNG, transparency yok

### "Missing Screenshots"
**Çözüm**: En az 1 screenshot her boyut için

---

## 🎉 YAYINLANDIKTAN SONRA

### İlk 24 Saat
- [ ] App Store'da görünürlüğü kontrol et
- [ ] IAP çalışıyor mu test et
- [ ] Reklam gösterimi kontrol et
- [ ] Crash raporlarını izle

### İlk Hafta
- [ ] Kullanıcı yorumlarını cevapla
- [ ] İndirme sayısını takip et
- [ ] Rating ortalamasını izle
- [ ] Analytics verilerini incele

### Güncelleme Planı
- [ ] Bug fix'ler için 1.0.1 hazırla
- [ ] Yeni özellikler için 1.1.0 planla
- [ ] Kullanıcı geri bildirimlerini değerlendir

---

## 📞 YARDIM ve KAYNAKLAR

**Apple Dokümantasyon:**
- https://developer.apple.com/app-store/review/guidelines/
- https://developer.apple.com/in-app-purchase/

**Faydalı Linkler:**
- App Store Connect: https://appstoreconnect.apple.com
- Developer Portal: https://developer.apple.com
- Human Interface Guidelines: https://developer.apple.com/design/

**Destek:**
- Apple Developer Support: https://developer.apple.com/support/
- Stack Overflow: flutter + ios + app-store

---

## ✅ SON KONTROL LİSTESİ

**Kod:**
- [x] Production mode aktif
- [x] Bundle ID doğru
- [x] Version doğru (1.0.0+1)
- [x] Tüm özellikler çalışıyor

**App Store Connect:**
- [ ] Uygulama oluşturuldu
- [ ] IAP ürünleri eklendi (4 adet)
- [ ] Screenshots yüklendi
- [ ] App icon yüklendi
- [ ] Description yazıldı
- [ ] Build seçildi
- [ ] Submit edildi

**Test:**
- [ ] Sandbox'ta IAP test edildi
- [ ] Gerçek cihazda test edildi
- [ ] Tüm akışlar kontrol edildi

---

**BAŞARILAR! 🚀**

İlk yayınınız olacak, heyecan verici! Sorularınız olursa çekinmeden sorun.
