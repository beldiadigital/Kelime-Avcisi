# App Store Connect Ayarları - Düzeltme Rehberi

## 🔥 1. Kids Category'den Çıkış

### Age Rating (Yaş Sınırı)
1. App Store Connect'e giriş yapın
2. **App Information → Age Rating** bölümüne gidin
3. Yaş sınırını **9+** veya **12+** olarak ayarlayın
4. "Made for Kids" checkbox'ını **KALDIR**
5. Tüm "Kids" ile ilgili seçenekleri **KAPATIN**

### Primary Category (Ana Kategori)
1. **App Information → Category** bölümüne gidin
2. Primary Category: **Games**
3. Secondary Category: **Word** veya **Puzzle**
4. **Kids kategorisini seçmeyin!**

---

## 🔧 2. Metadata Düzeltmeleri

### App Description (Uygulama Açıklaması)

**ESKİ (YANLIŞ):**
- "Kids için eğlenceli kelime oyunu"
- "Çocuklar için alfabe öğrenme"
- Abartılı/gerçekdışı özellikler

**YENİ (DOĞRU):**

```
Kelime Avcısı - Eğlenceli Kelime Bulmaca Oyunu

🎮 OYUN ÖZELLİKLERİ:
• 100+ seviye ile zorlayıcı kelime bulmacaları
• Hareket eden harfler ile dinamik oyun mekanikleri
• Can sistemi (10 can, her 30 dakikada 1 can yenilenir)
• İlerleme kayıt sistemi
• Günlük ödüller ve başarımlar

💎 SATIN ALMA SEÇENEKLERİ:
• Elmas paketleri (satın alım yoluyla)
• Restore Purchase özelliği mevcut
• Can satın alabilme imkanı

📊 İSTATİSTİKLER:
• Puan ve seviye takibi
• Başarım sistemi
• Oyuncu profili

⚠️ 9+ yaş için uygundur. Uygulama içi satın alımlar içerir.

Not: Bu oyun eğitim amaçlı değildir, eğlence odaklıdır.
```

### Keywords (Anahtar Kelimeler)
**KULLANMAYIN:** kids, children, çocuk, eğitim, öğrenme

**KULLANIN:** kelime, bulmaca, puzzle, oyun, game, eğlence, zeka

---

## 📸 3. Screenshots (Ekran Görüntüleri)

### Mevcut Sorunlar:
- Çok renkli, çocuksu tasarım
- Alfabe öğretimi görselleri
- Gerçek olmayan özellikler

### Yapılması Gerekenler:
1. **Gerçek oyun ekranlarını** kullanın
2. Renk paletini **sadeleştirin**
3. Yetişkin hedef kitleye uygun tasarım
4. Oyunda **gerçekten olan** özellikleri gösterin
5. Premium/satın alım özellikleri **açıkça belirtilsin**

### Örnek Ekranlar:
- Ana menü (can ve elmas göstergeleriyle)
- Oyun ekranı (seviye oynarken)
- Elmas mağazası (Restore Purchase butonu görünür olsun)
- Başarımlar sayfası
- Seviye haritası

---

## 💳 4. In-App Purchase (Uygulama İçi Satın Alma)

### App Store Connect → Features → In-App Purchases

#### Elmas Paketleri:
1. **100 Elmas - ₺29.99**
   - Product ID: `kelimeavcisi_100gems`
   - Type: Consumable
   - Description: "100 elmas satın alın ve özel içeriklere erişin"

2. **250 Elmas - ₺49.99**
   - Product ID: `kelimeavcisi_250gems`
   - Type: Consumable
   - Description: "250 elmas satın alın - popüler seçim"

3. **500 Elmas - ₺79.99**
   - Product ID: `kelimeavcisi_500gems`
   - Type: Consumable
   - Description: "500 elmas satın alın - en iyi değer"

#### Önemli Notlar:
- Tüm satın alımlar **Apple IAP** üzerinden
- **Restore Purchase** butonu eklendi ✅
- Açıklamada "subscription" veya "purchase" net belirtilmeli
- Fiyatlar açıkça görünmeli

---

## 🔐 5. Privacy Policy (Gizlilik Politikası)

### Yapılması Gerekenler:

1. **Privacy Policy URL Ekle:**
   - App Store Connect → App Privacy bölümüne gidin
   - Privacy Policy URL'i ekleyin (GitHub Pages, web sitesi vb.)
   - URL: `PRIVACY_POLICY_TR.md` dosyasını bir web sitesinde yayınlayın

2. **Privacy Policy İçeriği:**
   - ✅ `PRIVACY_POLICY_TR.md` dosyası hazırlandı
   - Bu dosyayı bir web sitesinde yayınlamanız gerekiyor
   - Örnek: GitHub Pages, kendi web siteniz, Notion, Google Sites vb.

3. **Veri Toplama Beyanı:**
   - App Privacy → Data Collection
   - "We do NOT collect data from children" seçeneğini işaretleyin
   - Toplanan verileri listeleyin:
     * Purchase History (satın alma geçmişi)
     * In-App Purchase Data
     * Device ID (cihaz kimliği - yalnızca satın alma doğrulaması için)

### Privacy Policy Yayınlama Seçenekleri:

#### Seçenek 1: GitHub Pages (ÜCRETSİZ)
```bash
# 1. GitHub repo'nuzda Settings → Pages'e gidin
# 2. Source: main branch seçin
# 3. PRIVACY_POLICY_TR.md dosyasını commit edin
# 4. URL: https://[kullaniciadi].github.io/kelimeavcisi/PRIVACY_POLICY_TR.html
```

#### Seçenek 2: Web Siteniz
- Kendi web sitenizde bir sayfa oluşturun
- Privacy policy metnini yapıştırın
- URL'i App Store Connect'e ekleyin

#### Seçenek 3: Google Sites (ÜCRETSİZ)
- sites.google.com'a gidin
- Yeni site oluşturun
- Privacy policy metnini yapıştırın
- Yayınlayın ve URL'i alın

---

## ✅ Final Checklist (Son Kontrol Listesi)

### App Store Connect'te Yapılacaklar:

- [ ] Age Rating: 9+ veya 12+ olarak ayarlandı
- [ ] "Made for Kids" checkbox'ı kaldırıldı
- [ ] Category: Games olarak ayarlandı (Kids DEĞİL)
- [ ] App Description güncellendi (yukarıdaki yeni metinle)
- [ ] Keywords'den "kids", "children", "çocuk" kelimeleri kaldırıldı
- [ ] Screenshots değiştirildi (gerçek ekranlar, sadeleştirilmiş)
- [ ] In-App Purchase ürünleri oluşturuldu (3 elmas paketi)
- [ ] Privacy Policy URL eklendi
- [ ] Privacy Policy'de "çocuk verisi toplamıyoruz" belirtildi
- [ ] App Privacy bölümünde veri toplama beyanı yapıldı

### Uygulamada Yapılanlar:

- [x] Can sayısı 10'a çıkarıldı ✅
- [x] Can yenilenme süresi 30 dakika olarak ayarlandı ✅
- [x] Restore Purchase butonu eklendi ✅
- [ ] Görseller sadeleştirilecek
- [ ] "Kids" kelimesi UI'dan kaldırılacak (varsa)

---

## 📧 Apple'a Gönderilecek Mesaj (Appeal için)

```
Merhaba Apple Review Team,

Uygulamam "Kelime Avcısı - Öğretici Oyun" Kids Category reddi aldı. 
Aşağıdaki değişiklikleri yaptım:

1. Age Rating: 9+ olarak ayarlandı
2. Kids Category seçimi kaldırıldı → Games kategorisine taşındı
3. Metadata tamamen güncellendi (gerçek özellikler, Kids kelimesi kaldırıldı)
4. Restore Purchase butonu eklendi
5. Privacy Policy düzgün şekilde bağlandı ve çocuk verisi toplanmadığı belirtildi
6. Ekran görüntüleri güncel gerçek ekranlarla değiştirildi

Uygulama artık genel kitleye (9+) yönelik bir kelime oyunu olarak konumlandırıldı.

Tekrar inceleme için teşekkür ederim.

Saygılarımla,
[İsminiz]
```

---

## 🎯 Sonuç

Bu değişiklikler yapıldıktan sonra:
1. Yeni build hazırlayın
2. App Store Connect'te tüm bilgileri güncelleyin
3. Yeni build'i submit edin
4. Apple'ın incelemesini bekleyin

**Tahmini İnceleme Süresi:** 24-48 saat

İyi şanslar! 🍀
