# Apple Review Sorunlarının Çözümü

## ✅ Kodda Yapılan Düzeltmeler

### 1. ✅ Guideline 2.3.10 - Google Play Referansı Kaldırıldı

**Dosya:** [lib/main.dart](lib/main.dart)

**Değişiklik:**
- **ÖNCE:** `'🔒 Güvenli ödeme ile App Store/Play Store üzerinden satın alınır'`
- **SONRA:** `'🔒 Güvenli ödeme ile App Store üzerinden satın alınır'`

**Neden:** iOS uygulamalarında Google Play veya Android referansları olmamalı.

---

### 2. ✅ Guideline 1.3 - AdMob ID Kaldırıldı

**Dosya:** [ios/Runner/Info.plist](ios/Runner/Info.plist)

**Değişiklik:**
- `GADApplicationIdentifier` key'i ve değeri tamamen kaldırıldı

**Neden:** Kids Category için third-party analytics/advertising yasak. Şu anda Kids'ten çıkma planımız var ama yine de temizlemek iyi.

---

### 3. ✅ In-App Purchase Bug'ı Düzeltildi

**Dosya:** [lib/services/iap_service.dart](lib/services/iap_service.dart)

**Değişiklik:**
- `buyProduct` metodunda null check hatası düzeltildi
- Try-catch bloğu düzgün şekilde yerleştirildi
- Exception handling iyileştirildi

**Neden:** iPad'de IAP flow sırasında hata oluşuyordu.

---

### 4. ✅ Restore Purchase Butonu Zaten Eklendi

**Konumlar:**
1. ✅ Elmas Mağazası (GemStorePage) - Header'ın altında
2. ✅ Can Mağazası (LifeShopPage) - Mevcut canlar kartından sonra
3. ✅ Ayarlar Sayfası (SettingsSheet) - Reklamsız abonelik bölümünde

**Özellikler:**
- Belirgin turuncu-kırmızı gradient tasarım
- Restore ikonu ile birlikte
- Tıklanınca `IAPService.restorePurchases()` çağrısı yapıyor
- Loading indicator gösteriyor
- Başarı/hata mesajları gösteriyor

---

## 📋 App Store Connect'te Yapılması Gerekenler

### 1. Kids Category'den Çıkış (En Önemli!)

**App Information → Primary Category:**
- ❌ KALDIR: Kids
- ✅ EKLE: Games → Word

**Age Rating:**
- ❌ KALDIR: "Made for Kids" checkbox'ı
- ✅ AYARLA: 9+ veya 12+

**Neden Bu Önemli:**
- Guideline 5.1.4 sorununu çözer (Privacy Policy şartı)
- Guideline 1.3 sorununu çözer (Analytics/Ads yasağı)
- Daha geniş kullanıcı kitlesine ulaşırsınız

---

### 2. Privacy Policy URL Ekle

**App Privacy → Privacy Policy URL:**

**Seçenek 1: GitHub Pages (ÜCRETSİZ - ÖNERİLEN)**
```
1. GitHub repo'nuzda Settings → Pages
2. Source: main branch seçin
3. PRIVACY_POLICY_TR.md dosyasını ekleyin
4. URL: https://[kullaniciadi].github.io/kelimeavcisi/PRIVACY_POLICY_TR.html
```

**Seçenek 2: Google Sites (ÜCRETSİZ)**
```
1. sites.google.com'a gidin
2. Yeni site oluşturun
3. PRIVACY_POLICY_TR.md içeriğini yapıştırın
4. Yayınlayın ve URL'i kopyalayın
```

**Privacy Policy dosyası hazır:** [PRIVACY_POLICY_TR.md](PRIVACY_POLICY_TR.md)

---

### 3. App Privacy Bilgilerini Güncelle

**App Privacy → Data Collection:**

✅ **Toplanan Veriler:**
- Purchase History (satın alma geçmişi)
- In-App Purchase Data
- User ID (sadece satın alma doğrulaması için)

❌ **TOPLANMAYAN:**
- IDFA
- Analytics
- Third-party tracking
- Personal information

**Not:** "We do NOT collect data from children" seçeneğini işaretleyin (9+ yaş için).

---

### 4. In-App Purchase Ürünlerini Kontrol Et

**App Store Connect → Features → In-App Purchases**

**Oluşturulması Gereken Ürünler:**

#### Elmas Paketleri (Consumable):
1. **100 Elmas**
   - Product ID: `kelimeavcisi_100gems`
   - Type: Consumable
   - Price: ₺29.99
   - Display Name: "100 Elmas"
   - Description: "100 elmas satın alın"

2. **250 Elmas**
   - Product ID: `kelimeavcisi_250gems`
   - Type: Consumable
   - Price: ₺49.99
   - Display Name: "250 Elmas"
   - Description: "250 elmas satın alın - popüler seçim"

3. **500 Elmas**
   - Product ID: `kelimeavcisi_500gems`
   - Type: Consumable
   - Price: ₺79.99
   - Display Name: "500 Elmas"
   - Description: "500 elmas satın alın - en iyi değer"

#### Abonelik (Auto-Renewable Subscription):
4. **Reklamsız Oyun**
   - Product ID: `kelimeavcisi_noads_monthly`
   - Type: Auto-Renewable Subscription
   - Duration: 1 Month
   - Price: ₺49.99
   - Display Name: "Reklamsız Premium"
   - Description: "Tüm reklamları kaldır"

**Önemli:**
- Her ürün için **screenshot** ekleyin
- Review Notes'a açıklama ekleyin
- Sandbox test hesabıyla test edin

---

### 5. Metadata Güncellemeleri

#### App Description (Açıklama):

```
Kelime Avcısı - Eğlenceli Kelime Bulmaca Oyunu

🎮 OYUN ÖZELLİKLERİ:
• 100+ seviye ile zorlayıcı kelime bulmacaları
• Hareket eden harfler ile dinamik oyun mekanikleri
• Can sistemi (10 can, her 30 dakikada 1 can yenilenir)
• İlerleme kayıt sistemi
• Günlük ödüller ve başarımlar

💎 PREMIUM ÖZELLİKLER:
• Elmas paketleri (100/250/500 elmas)
• Reklamsız oyun aboneliği
• Can satın alma seçenekleri
• Restore Purchase özelliği

📊 İSTATİSTİKLER:
• Puan ve seviye takibi
• Başarım sistemi
• Oyuncu profili

⚠️ 9+ yaş için uygundur. Uygulama içi satın alımlar içerir.
```

#### Keywords (Anahtar Kelimeler):

**KULLANMAYIN:** kids, children, çocuk, eğitim

**KULLANIN:** kelime, bulmaca, puzzle, oyun, game, eğlence, zeka, kelime oyunu, word game

---

### 6. Screenshots (Ekran Görüntüleri)

**Gereksinimler:**
- ✅ Gerçek oyun ekranları
- ✅ Restore Purchase butonu görünür olmalı
- ✅ Can sistemi gösterilmeli
- ✅ Elmas mağazası ekranı
- ❌ Çocuksu/aşırı renkli tasarımlar kullanmayın
- ❌ Gerçekte olmayan özellikler göstermeyin

**Önerilen Ekranlar:**
1. Ana menü (can ve elmas göstergeleriyle)
2. Oyun ekranı (seviye oynarken)
3. Elmas mağazası (Restore Purchase butonu görünür)
4. Başarımlar sayfası
5. Seviye haritası

---

### 7. Paid Apps Agreement

**Agreements, Tax, and Banking → Paid Apps Agreement:**
- Account Holder'ın bu sözleşmeyi kabul etmesi gerekiyor
- Banking ve Tax bilgileri eksiksiz olmalı
- IAP'nin çalışması için zorunlu

**Kontrol:**
1. App Store Connect → Agreements, Tax, and Banking
2. Paid Apps Agreement durumunu kontrol edin
3. Eksikse, gerekli bilgileri tamamlayın

---

## 🧪 Sandbox Test Checklist

### Test Kullanıcısı Oluşturma:

1. **App Store Connect → Users and Access → Sandbox Testers**
2. "+" butonuna tıklayın
3. Test hesabı bilgilerini girin:
   - Email: test@example.com
   - Password: Test1234!
   - First/Last Name
   - Country: Turkey

### Test Senaryoları:

#### ✅ Test 1: Elmas Satın Alma
1. Uygulamayı açın
2. Elmas mağazasına gidin
3. 100 elmas satın almayı deneyin
4. Sandbox login yapın
5. Satın alma işlemini tamamlayın
6. Elmasların hesaba eklendiğini doğrulayın

#### ✅ Test 2: Restore Purchase
1. Elmas/abonelik satın alın
2. Uygulamayı silin ve yeniden kurun
3. "Restore Purchase" butonuna tıklayın
4. Önceki satın almaların geri yüklendiğini doğrulayın

#### ✅ Test 3: Abonelik
1. Reklamsız aboneliği satın alın
2. Abonelik durumunun aktif olduğunu doğrulayın
3. Uygulamayı yeniden başlatın
4. Aboneliğin hala aktif olduğunu kontrol edin

#### ✅ Test 4: Hata Durumları
1. İnternet bağlantısını kesin
2. Satın alma yapmayı deneyin
3. Hata mesajının düzgün gösterildiğini doğrulayın

---

## 📝 Review Notes (İnceleme Notları)

**App Store Connect → Version Information → Review Notes:**

```
Merhaba Apple Review Team,

Aşağıdaki güncellemeleri yaptık:

1. ✅ Google Play referansları kaldırıldı
2. ✅ Kids Category'den çıkış yapıldı → Games kategorisine taşındı
3. ✅ Age Rating: 9+ olarak ayarlandı
4. ✅ AdMob/Analytics kaldırıldı
5. ✅ Restore Purchase butonu 3 farklı yerde eklendi:
   - Elmas Mağazası
   - Can Mağazası
   - Ayarlar Sayfası
6. ✅ In-App Purchase bug'ı düzeltildi
7. ✅ Privacy Policy eklendi

Test Bilgileri:
- Test hesabı: [sandbox test email]
- IAP ürünleri sandbox'ta test edildi
- Restore Purchase özelliği test edildi

Tüm IAP ürünleri App Store Connect'te yapılandırıldı ve sandbox'ta çalışıyor.

Teşekkürler!
```

---

## 🚀 Yeni Build Hazırlama

### 1. Version Güncelleme:

**pubspec.yaml:**
```yaml
version: 1.0.0+5  # Build number'ı artırın
```

### 2. Build Alma:

```bash
# iOS Release build
flutter clean
flutter pub get
flutter build ios --release

# Xcode'da
1. Product → Archive
2. Distribute App
3. App Store Connect
4. Upload
```

### 3. TestFlight'ta Test:

1. Build yüklenince TestFlight'ta test edin
2. Tüm IAP özelliklerini kontrol edin
3. Restore Purchase'ın çalıştığından emin olun

### 4. Review'a Gönder:

1. Tüm metadata güncellendiğinden emin olun
2. Screenshots yüklenmiş olsun
3. Review Notes eklenmiş olsun
4. "Submit for Review" butonuna tıklayın

---

## ✅ Final Checklist

### Kodda:
- [x] Google Play referansı kaldırıldı
- [x] AdMob ID kaldırıldı
- [x] IAP bug'ı düzeltildi
- [x] Restore Purchase butonu eklendi (3 yerde)

### App Store Connect:
- [ ] Kids Category kaldırıldı → Games olarak değiştirildi
- [ ] Age Rating: 9+ olarak ayarlandı
- [ ] "Made for Kids" checkbox'ı kapatıldı
- [ ] Privacy Policy URL eklendi
- [ ] App Privacy bilgileri güncellendi
- [ ] IAP ürünleri oluşturuldu (4 adet)
- [ ] Screenshots güncellendi
- [ ] App Description güncellendi
- [ ] Keywords güncellendi
- [ ] Paid Apps Agreement onaylandı
- [ ] Review Notes eklendi

### Test:
- [ ] Sandbox test hesabı oluşturuldu
- [ ] Elmas satın alma test edildi
- [ ] Abonelik satın alma test edildi
- [ ] Restore Purchase test edildi
- [ ] Hata durumları test edildi

### Build:
- [ ] Version number artırıldı
- [ ] Yeni build oluşturuldu
- [ ] TestFlight'a yüklendi
- [ ] TestFlight'ta test edildi
- [ ] Review'a gönderildi

---

## 🎯 Tahmini Onay Süresi

- **İlk İnceleme:** 24-48 saat
- **Metadata İncelemeleri:** 2-6 saat
- **IAP İncelemeleri:** 24 saat

**Toplam Tahmini Süre:** 2-3 gün

---

## 📧 Sorularınız için:

Eğer Apple sorarsa:

**"Kids Category neden kaldırıldı?"**
```
Uygulamayız genel kullanıcılara (9+) yönelik bir kelime oyunudur. 
Kids Category gereksinimleriyle uyumlu olmadığı için Games 
kategorisine taşıdık.
```

**"AdMob neden kaldırıldı?"**
```
Uygulamada şu anda reklam gösterimi yok. AdMob entegrasyonu 
gelecek güncellemelerde eklenebilir ama şu an kullanılmıyor.
```

**"IAP nasıl test edildi?"**
```
Tüm IAP ürünleri sandbox ortamında test edildi. Restore Purchase 
özelliği 3 farklı konumda mevcut ve çalışıyor.
```

---

İyi şanslar! 🍀
