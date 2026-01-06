import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class IAPService {
  static final InAppPurchase _instance = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Elmas paket ID'leri (App Store Connect'te tanımlanmalı)
  static const String gems50 = 'kelimeavcisi_50gems';
  static const String gems100 = 'kelimeavcisi_100gems';
  static const String gems200 = 'kelimeavcisi_200gems';

  // Abonelik ID'si
  static const String subscriptionNoAds = 'kelimeavcisi_noads_monthly';

  static const Set<String> _productIds = {
    gems50,
    gems100,
    gems200,
    subscriptionNoAds,
  };

  static List<ProductDetails> _products = [];
  static bool _isAvailable = false;

  // Servisi başlat
  static Future<void> initialize() async {
    _isAvailable = await _instance.isAvailable();

    if (_isAvailable) {
      // Satın alma stream'ini dinle
      _subscription = _instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => print('Purchase stream error: $error'),
      );

      // Ürünleri yükle
      await _loadProducts();

      // Bekleyen satın almaları kontrol et
      await _checkPendingPurchases();
    }
  }

  // Ürünleri yükle
  static Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _instance
          .queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      print('Loaded ${_products.length} products');
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  // Satın alma güncelleme callback'i
  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyAndDeliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        print('Purchase error: ${purchase.error}');
      }

      // Pending olmayan satın almaları tamamla
      if (purchase.pendingCompletePurchase) {
        _instance.completePurchase(purchase);
      }
    }
  }

  // Ürünü doğrula ve elmasları ekle veya aboneliği aktifleştir
  static Future<void> _verifyAndDeliverProduct(PurchaseDetails purchase) async {
    int gemsToAdd = 0;

    switch (purchase.productID) {
      case gems50:
        gemsToAdd = 50;
        break;
      case gems100:
        gemsToAdd = 110; // 100 + 10 bonus
        break;
      case gems200:
        gemsToAdd = 230; // 200 + 30 bonus
        break;
      case subscriptionNoAds:
        // Reklamsız aboneliği aktifleştir
        await activateNoAdsSubscription();
        print('No-ads subscription activated');
        return;
    }

    if (gemsToAdd > 0) {
      await CurrencyManager.addGems(gemsToAdd);
      print('Added $gemsToAdd gems for purchase: ${purchase.productID}');
    }
  }

  // Reklamsız aboneliği aktifleştir
  static Future<void> activateNoAdsSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('noAdsSubscription', true);
    await prefs.setInt(
      'noAdsSubscriptionTime',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Reklamsız abonelik aktif mi kontrol et
  static Future<bool> hasActiveNoAdsSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('noAdsSubscription') ?? false;
  }

  // Bekleyen satın almaları kontrol et
  static Future<void> _checkPendingPurchases() async {
    try {
      await _instance.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }

  // Satın almaları geri yükle (public)
  static Future<void> restorePurchases() async {
    try {
      await _instance.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
      rethrow;
    }
  }

  // Satın alma başlat
  static Future<bool> buyProduct(String productId) async {
    if (!_isAvailable) {
      print('In-app purchase not available');
      return false;
    }

    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // Abonelik ise buyNonConsumable, elmas paketi ise buyConsumable kullan
      if (productId == subscriptionNoAds) {
        return await _instance.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _instance.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      print('Error buying product: $e');
      return false;
    }
  }

  // Servisi kapat
  static void dispose() {
    _subscription?.cancel();
  }

  // Ürün detaylarını al (fiyat gösterimi için)
  static ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Servis kullanılabilir mi?
  static bool get isAvailable => _isAvailable;

  // Tüm ürünler
  static List<ProductDetails> get products => _products;
}
