import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  PurchaseService();

  static const String premiumProductId = 'premium_unlock';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final StreamController<PurchaseDetails> _purchaseController =
  StreamController<PurchaseDetails>.broadcast();

  Stream<PurchaseDetails> get purchaseUpdates =>
      _purchaseController.stream;

  ProductDetails? premiumProduct;

  bool isStoreAvailable = false;
  bool isPremium = false;

  bool get storeAvailable => isStoreAvailable;

  Future<void> initialize() async {
    await _loadSavedPremiumStatus();

    isStoreAvailable = await _inAppPurchase.isAvailable();

    if (!isStoreAvailable) {
      debugPrint('Google Play Billing is not available.');
      return;
    }

    _purchaseSubscription ??=
        _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdates,
          onDone: () async {
            await _purchaseSubscription?.cancel();
            _purchaseSubscription = null;
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

    for (final product
    in response.productDetails) {
      if (product.id == premiumProductId) {
        premiumProduct = product;
        break;
      }
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

    if (isPremium) {
      debugPrint(
        'Premium is already active.',
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
          await _activatePremium();
          break;

        case PurchaseStatus.restored:
          await _activatePremium();
          break;

        case PurchaseStatus.pending:
          debugPrint(
            'Premium purchase is pending.',
          );
          break;

        case PurchaseStatus.error:
          debugPrint(
            'Premium purchase error: ${purchase.error}',
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint(
            'Premium purchase canceled.',
          );
          break;
      }

      if (!_purchaseController.isClosed) {
        _purchaseController.add(
          purchase,
        );
      }

      if (purchase.pendingCompletePurchase &&
          purchase.status ==
              PurchaseStatus.purchased) {
        await _inAppPurchase.completePurchase(
          purchase,
        );
      }

      if (purchase.pendingCompletePurchase &&
          purchase.status ==
              PurchaseStatus.restored) {
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

    if (!_purchaseController.isClosed) {
      await _purchaseController.close();
    }
  }
}