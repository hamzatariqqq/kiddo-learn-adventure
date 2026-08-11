import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  PurchaseService({
    this.onPurchaseUpdated,
  });

  static const String premiumProductId = 'premium_unlock';

  final void Function(PurchaseDetails purchase)? onPurchaseUpdated;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? premiumProduct;

  bool isStoreAvailable = false;
  bool isPremium = false;

  bool get storeAvailable => isStoreAvailable;

  Future<void> initialize() async {
    // First restore Premium state from local/Firebase.
    await _loadSavedPremiumStatus();

    // Then initialize Google Play Billing.
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
            debugPrint(
              'Purchase stream error: $error',
            );
          },
        );

    await loadProducts();
  }

  Future<void> _loadSavedPremiumStatus() async {
    final user = _auth.currentUser;

    if (user == null) {
      isPremium = false;
      return;
    }

    final preferences =
    await SharedPreferences.getInstance();

    final cacheKey = 'premium_${user.uid}';

    // Load cached value first.
    isPremium =
        preferences.getBool(cacheKey) ?? false;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      if (data != null) {
        final firestorePremium =
            data['isPremium'] == true;

        isPremium = firestorePremium;

        await preferences.setBool(
          cacheKey,
          firestorePremium,
        );
      }
    } catch (error) {
      debugPrint(
        'Unable to load Premium status from Firestore: $error',
      );

      // Keep locally cached Premium state if Firebase
      // temporarily cannot be reached.
    }
  }

  Future<void> loadProducts() async {
    const productIds = <String>{
      premiumProductId,
    };

    final response =
    await _inAppPurchase.queryProductDetails(
      productIds,
    );

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
      premiumProduct =
          response.productDetails.firstWhere(
                (product) =>
            product.id == premiumProductId,
            orElse: () =>
            response.productDetails.first,
          );
    }
  }

  Future<bool> buyPremium() async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'User must be signed in before purchasing Premium.',
      );
      return false;
    }

    final product = premiumProduct;

    if (!isStoreAvailable || product == null) {
      debugPrint(
        'Premium product is not available.',
      );
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
    if (!isStoreAvailable) {
      debugPrint(
        'Cannot restore because Google Play Billing is unavailable.',
      );
      return;
    }

    await _inAppPurchase.restorePurchases();
  }

  Future<void> _activatePremium() async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'Cannot activate Premium without a signed-in user.',
      );
      return;
    }

    isPremium = true;

    final preferences =
    await SharedPreferences.getInstance();

    final cacheKey = 'premium_${user.uid}';

    await preferences.setBool(
      cacheKey,
      true,
    );

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'isPremium': true,
          'premiumActivatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      debugPrint(
        'Premium status saved successfully.',
      );
    } catch (error) {
      debugPrint(
        'Unable to save Premium to Firestore: $error',
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList,
      ) async {
    for (final purchase
    in purchaseDetailsList) {
      if (purchase.productID !=
          premiumProductId) {
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _activatePremium();
          break;

        case PurchaseStatus.error:
          debugPrint(
            'Purchase error: ${purchase.error}',
          );
          break;

        case PurchaseStatus.pending:
          debugPrint(
            'Purchase is pending.',
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint(
            'Purchase was canceled.',
          );
          break;
      }

      onPurchaseUpdated?.call(purchase);

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(
          purchase,
        );
      }
    }
  }

  Future<void> refreshPremiumStatus() async {
    await _loadSavedPremiumStatus();
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}