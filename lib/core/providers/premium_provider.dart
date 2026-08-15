import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

final premiumProvider =
AsyncNotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends AsyncNotifier<bool> {
  PurchaseService get _purchaseService =>
      ref.read(purchaseServiceProvider);

  @override
  Future<bool> build() async {
    await _purchaseService.initialize();

    return _purchaseService.isPremium;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _purchaseService.refreshPremiumStatus();

      return _purchaseService.isPremium;
    });
  }

  Future<bool> buyPremium() async {
    return _purchaseService.buyPremium();
  }

  Future<void> restorePurchases() async {
    await _purchaseService.restorePurchases();
  }

  // Used by PremiumScreen to check whether
  // Google Play Billing is available.
  bool get storeAvailable =>
      _purchaseService.storeAvailable;

  bool get isPremium =>
      state.value ?? false;

  // Gives PremiumScreen access to product information
  // such as the Google Play price.
  PurchaseService get purchaseService =>
      _purchaseService;
}