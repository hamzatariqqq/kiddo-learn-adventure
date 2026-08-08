import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  PurchaseService({
    this.onPurchaseUpdated,
  });

  static const String premiumProductId = 'premium_unlock';

  final void Function(PurchaseDetails purchase)? onPurchaseUpdated;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? premiumProduct;

  bool isStoreAvailable = false;
  bool isPremium = false;

  // This getter is required by your existing premium_screen.dart.
  bool get storeAvailable => isStoreAvailable;

  Future<void> initialize() async {
    isStoreAvailable = await _inAppPurchase.isAvailable();

    if (!isStoreAvailable) {
      debugPrint('Google Play Billing is not available.');
      return;
    }

    _purchaseSubscription ??=
        _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdates,
          onDone: () {
            _purchaseSubscription?.cancel();
          },
          onError: (Object error) {
            debugPrint('Purchase stream error: $error');
          },
        );

    await loadProducts();
  }

  Future<void> loadProducts() async {
    const productIds = <String>{
      premiumProductId,
    };

    final response =
    await _inAppPurchase.queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint(
        'Product loading error: ${response.error}',
      );
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'Products not found: ${response.notFoundIDs}',
      );
    }

    if (response.productDetails.isNotEmpty) {
      premiumProduct = response.productDetails.first;
    }
  }

  Future<bool> buyPremium() async {
    final product = premiumProduct;

    if (!isStoreAvailable || product == null) {
      debugPrint('Premium product is not available.');
      return false;
    }

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    return _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList,
      ) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.productID != premiumProductId) {
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        isPremium = true;
      }

      if (purchase.status == PurchaseStatus.error) {
        debugPrint(
          'Purchase error: ${purchase.error}',
        );
      }

      // Notify your existing PremiumScreen.
      onPurchaseUpdated?.call(purchase);

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}