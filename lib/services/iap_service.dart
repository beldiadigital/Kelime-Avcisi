import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/currency.dart';

class IAPService {
  static final InAppPurchase _instance = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Elmas paket ID'leri (App Store Connect'te tanımlanmalı)
  static const String gems100 = 'com.kelimeavcisi.gems100';
  static const String gems200 = 'com.kelimeavcisi.gems200';
  static const String gems500 = 'com.kelimeavcisi.gems500';

  static const Set<String> _productIds = {gems100, gems200, gems500};

  static List<ProductDetails> _products = [];
  static bool _isAvailable = false;

  // Purchase callback'leri için
  static Function(String productId, int gemsAdded)? onPurchaseSuccess;
  static Function(String error)? onPurchaseError;

  // Servisi başlat
  static Future<void> initialize() async {
    print('🛍️ Initializing IAP Service...');

    try {
      _isAvailable = await _instance.isAvailable();
      print('IAP Available: $_isAvailable');

      if (!_isAvailable) {
        print('⚠️ WARNING: In-App Purchase is NOT available on this device!');
        print('This might be because:');
        print('1. Running on simulator (IAP only works on real devices)');
        print('2. Paid Apps Agreement not accepted in App Store Connect');
        print('3. Network connectivity issue');
        print('4. IAP products not configured in App Store Connect');
        return;
      }

      // Satın alma stream'ini dinle
      _subscription = _instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          print('Purchase stream done');
          _subscription?.cancel();
        },
        onError: (error) {
          print('❌ Purchase stream error: $error');
        },
      );

      // Ürünleri yükle
      await _loadProducts();

      // Bekleyen satın almaları kontrol et
      await _checkPendingPurchases();

      print('✅ IAP Service initialized successfully');
    } catch (e) {
      print('❌ ERROR initializing IAP: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Ürünleri yükle
  static Future<void> _loadProducts() async {
    try {
      print('📦 Loading products: $_productIds');

      final ProductDetailsResponse response = await _instance
          .queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print(
          '❌ Products NOT FOUND in App Store Connect: ${response.notFoundIDs}',
        );
        print('⚠️ IMPORTANT: Make sure these product IDs are:');
        print('   1. Created in App Store Connect');
        print('   2. Status is "Ready to Submit" or "Approved"');
        print('   3. Have at least 1 localization');
        print('   4. Have a screenshot');
        print('   5. Paid Apps Agreement is accepted');
      }

      if (response.error != null) {
        print('❌ Error loading products: ${response.error}');
      }

      _products = response.productDetails;
      print('✅ Successfully loaded ${_products.length} products');

      for (final product in _products) {
        print('  • ${product.id}: ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('❌ Exception loading products: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Satın alma güncelleme callback'i
  static void _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      print(
        '🔔 Purchase update - Status: ${purchase.status}, ProductID: ${purchase.productID}',
      );

      if (purchase.status == PurchaseStatus.purchased) {
        print('✅ Purchase successful: ${purchase.productID}');
        // iOS'ta receipt doğrulama
        final bool valid = await _verifyPurchase(purchase);
        if (valid) {
          final gemsAdded = await _verifyAndDeliverProduct(purchase);
          if (gemsAdded > 0) {
            print('💎 Successfully added $gemsAdded gems');
            // UI'ya bildirim gönder
            onPurchaseSuccess?.call(purchase.productID, gemsAdded);
          }
        } else {
          print('❌ Purchase verification failed for: ${purchase.productID}');
          onPurchaseError?.call('Satın alma doğrulanamadı');
        }
      } else if (purchase.status == PurchaseStatus.error) {
        print(
          '❌ Purchase error: ${purchase.error?.message ?? "Unknown error"}',
        );
        print('Error details: ${purchase.error?.details}');
        onPurchaseError?.call(purchase.error?.message ?? 'Bilinmeyen hata');
      } else if (purchase.status == PurchaseStatus.pending) {
        print('⏳ Purchase pending: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.canceled) {
        print('🚫 Purchase canceled: ${purchase.productID}');
        onPurchaseError?.call('Satın alma iptal edildi');
      } else if (purchase.status == PurchaseStatus.restored) {
        print('♻️ Purchase restored: ${purchase.productID}');
        final gemsAdded = await _verifyAndDeliverProduct(purchase);
        if (gemsAdded > 0) {
          onPurchaseSuccess?.call(purchase.productID, gemsAdded);
        }
      }

      // Pending olmayan satın almaları tamamla
      if (purchase.pendingCompletePurchase) {
        await _instance.completePurchase(purchase);
        print('✅ Purchase marked as complete: ${purchase.productID}');
      }
    }
  }

  // Receipt doğrulama (iOS için basit kontrol)
  static Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Sandbox ve production ortamında receipt var mı kontrol et
    if (purchase.verificationData.serverVerificationData.isEmpty) {
      print('Warning: No receipt data for purchase: ${purchase.productID}');
      return false;
    }

    // Not: Production'da gerçek server-side validation yapılmalı
    // Şimdilik sandbox test için basit kontrol
    return true;
  }

  // Ürünü doğrula ve elmasları ekle
  static Future<int> _verifyAndDeliverProduct(PurchaseDetails purchase) async {
    int gemsToAdd = 0;

    switch (purchase.productID) {
      case gems100:
        gemsToAdd = 100;
        break;
      case gems200:
        gemsToAdd = 200;
        break;
      case gems500:
        gemsToAdd = 500;
        break;
      default:
        print('❌ Unknown product: ${purchase.productID}');
        return 0;
    }

    if (gemsToAdd > 0) {
      print('💎 Adding $gemsToAdd gems to balance...');
      await CurrencyManager.addGems(gemsToAdd);
      print(
        '✅ Successfully added $gemsToAdd gems for purchase: ${purchase.productID}',
      );
      print('💰 New gem balance: ${CurrencyManager.gems}');
      return gemsToAdd;
    }

    return 0;
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
    print('Attempting to buy product: $productId');

    if (!_isAvailable) {
      print('ERROR: In-app purchase not available on this device');
      return false;
    }

    if (_products.isEmpty) {
      print('ERROR: No products loaded. Please wait for initialization.');
      // Tekrar yüklemeyi dene
      await _loadProducts();
      if (_products.isEmpty) {
        print('ERROR: Still no products available');
        return false;
      }
    }

    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      print('Product found: ${product.title} - ${product.price}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final result = await _instance.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      print('Purchase initiated: $result');
      return result;
    } catch (e) {
      print('ERROR buying product: $e');
      print('Stack trace: ${StackTrace.current}');
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
