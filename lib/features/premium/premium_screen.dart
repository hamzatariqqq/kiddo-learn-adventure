import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/providers/premium_provider.dart';

class PremiumScreen
    extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() =>
      _PremiumScreenState();
}

class _PremiumScreenState
    extends ConsumerState<PremiumScreen> {
  StreamSubscription<PurchaseDetails>?
  _purchaseSubscription;

  bool _buying = false;
  bool _restoring = false;
  bool _purchasePending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _listenToPurchases();
    });
  }

  void _listenToPurchases() {
    final service = ref.read(
      purchaseServiceProvider,
    );

    _purchaseSubscription ??=
        service.purchaseUpdates.listen(
          _onPurchaseUpdated,
        );
  }

  void _onPurchaseUpdated(
      PurchaseDetails purchase,
      ) {
    if (!mounted) return;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        setState(() {
          _purchasePending = true;
          _buying = false;
        });

        _showMessage(
          'Your purchase is pending. Premium will activate after Google Play confirms the payment.',
        );
        break;

      case PurchaseStatus.purchased:
        setState(() {
          _purchasePending = false;
          _buying = false;
          _restoring = false;
        });

        ref
            .read(
          premiumProvider.notifier,
        )
            .refresh();

        _showMessage(
          'Premium activated successfully! 🎉',
        );
        break;

      case PurchaseStatus.restored:
        setState(() {
          _purchasePending = false;
          _buying = false;
          _restoring = false;
        });

        ref
            .read(
          premiumProvider.notifier,
        )
            .refresh();

        _showMessage(
          'Premium purchase restored successfully.',
        );
        break;

      case PurchaseStatus.error:
        setState(() {
          _purchasePending = false;
          _buying = false;
          _restoring = false;
        });

        _showMessage(
          purchase.error?.message ??
              'Purchase failed. Please try again.',
        );
        break;

      case PurchaseStatus.canceled:
        setState(() {
          _purchasePending = false;
          _buying = false;
          _restoring = false;
        });

        _showMessage(
          'Purchase canceled.',
        );
        break;
    }
  }

  Future<void> _buyPremium() async {
    final premiumState =
    ref.read(premiumProvider);

    final isPremium =
        premiumState.value ?? false;

    if (isPremium ||
        _buying ||
        _purchasePending) {
      return;
    }

    final notifier = ref.read(
      premiumProvider.notifier,
    );

    if (!notifier.storeAvailable) {
      _showMessage(
        'Google Play Billing is not available.',
      );
      return;
    }

    final service = ref.read(
      purchaseServiceProvider,
    );

    if (service.premiumProduct == null) {
      _showMessage(
        'Premium product is not available yet. Make sure the app is installed through Google Play testing.',
      );
      return;
    }

    setState(() {
      _buying = true;
    });

    try {
      final started =
      await notifier.buyPremium();

      if (!started && mounted) {
        setState(() {
          _buying = false;
        });

        _showMessage(
          'Unable to start the purchase.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _buying = false;
      });

      _showMessage(
        'Unable to start the purchase. Please try again.',
      );
    }
  }

  Future<void> _restorePurchase() async {
    if (_restoring) return;

    final notifier = ref.read(
      premiumProvider.notifier,
    );

    if (!notifier.storeAvailable) {
      _showMessage(
        'Google Play Billing is not available.',
      );
      return;
    }

    setState(() {
      _restoring = true;
    });

    try {
      await notifier.restorePurchases();

      if (!mounted) return;

      await Future<void>.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      final isPremium =
          ref.read(premiumProvider).value ??
              false;

      setState(() {
        _restoring = false;
      });

      if (!isPremium) {
        _showMessage(
          'No previous Premium purchase was found for this Google Play account.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _restoring = false;
      });

      _showMessage(
        'Unable to restore purchases. Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumState =
    ref.watch(premiumProvider);

    final service = ref.watch(
      purchaseServiceProvider,
    );

    final product =
        service.premiumProduct;

    final price =
        product?.price ??
            'Loading price...';

    final isPremium =
        premiumState.value ?? false;

    final loading =
        premiumState.isLoading;

    return Scaffold(
      backgroundColor:
      const Color(0xFF062B50),
      appBar: AppBar(
        title: const Text(
          'Kiddo Premium',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
        const Color(0xFF062B50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: loading
            ? const Center(
          child:
          CircularProgressIndicator(
            color:
            Color(0xFFFFD83D),
          ),
        )
            : SingleChildScrollView(
          padding:
          const EdgeInsets.all(
            16,
          ),
          child: Column(
            children: [
              if (isPremium) ...[
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFFD83D,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      18,
                    ),
                  ),
                  child:
                  const Column(
                    children: [
                      Icon(
                        Icons
                            .workspace_premium_rounded,
                        size: 48,
                        color: Color(
                          0xFF062B50,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Premium Active',
                        style:
                        TextStyle(
                          color: Color(
                            0xFF062B50,
                          ),
                          fontSize:
                          20,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Your Kiddo Premium lifetime access is active.',
                        textAlign:
                        TextAlign
                            .center,
                        style:
                        TextStyle(
                          color: Color(
                            0xFF062B50,
                          ),
                          fontSize:
                          13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],

              if (_purchasePending) ...[
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Colors
                        .orange
                        .withValues(
                      alpha: 0.18,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      14,
                    ),
                    border:
                    Border.all(
                      color: Colors
                          .orangeAccent,
                    ),
                  ),
                  child:
                  const Row(
                    children: [
                      Icon(
                        Icons
                            .schedule_rounded,
                        color: Colors
                            .orangeAccent,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Payment pending. Premium will activate after Google Play confirms the purchase.',
                          style:
                          TextStyle(
                            color: Colors
                                .white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],

              const _PremiumFeatureCard(
                icon: Icons.block,
                iconColor:
                Colors.redAccent,
                title: 'Remove Ads',
                subtitle:
                'Enjoy learning without banner or rewarded ads.',
              ),

              const SizedBox(
                height: 12,
              ),

              const _PremiumFeatureCard(
                icon: Icons
                    .lock_open_rounded,
                iconColor: Colors.blue,
                title:
                'Premium Learning',
                subtitle:
                'Unlock future premium lessons and activities.',
              ),

              const SizedBox(
                height: 12,
              ),

              const _PremiumFeatureCard(
                icon: Icons
                    .sports_esports_rounded,
                iconColor: Colors.green,
                title:
                'Extra Activities',
                subtitle:
                'Get access to future premium games and rewards.',
              ),

              const SizedBox(
                height: 12,
              ),

              const _PremiumFeatureCard(
                icon:
                Icons.all_inclusive,
                iconColor: Colors.amber,
                title:
                'Lifetime Access',
                subtitle:
                'Pay once and keep Premium on this account.',
              ),

              const SizedBox(
                height: 20,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  20,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius
                      .circular(
                    18,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kiddo Premium Lifetime',
                      style:
                      TextStyle(
                        color: Color(
                          0xFF062B50,
                        ),
                        fontSize: 18,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      isPremium
                          ? 'Already purchased'
                          : 'One-time purchase',
                      style:
                      const TextStyle(
                        color:
                        Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    if (isPremium)
                      const Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons
                                .verified_rounded,
                            color: Colors
                                .green,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'ACTIVE',
                            style:
                            TextStyle(
                              color: Colors
                                  .green,
                              fontSize:
                              22,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        price,
                        style:
                        const TextStyle(
                          color: Color(
                            0xFF062B50,
                          ),
                          fontSize: 26,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      isPremium
                          ? 'Premium is enabled for this account.'
                          : 'Secure payment through Google Play',
                      textAlign:
                      TextAlign
                          .center,
                      style:
                      const TextStyle(
                        color:
                        Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isPremium ||
                      _buying ||
                      _purchasePending
                      ? null
                      : _buyPremium,
                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    const Color(
                      0xFFFFD83D,
                    ),
                    foregroundColor:
                    const Color(
                      0xFF062B50,
                    ),
                    disabledBackgroundColor:
                    isPremium
                        ? Colors.green
                        .shade400
                        : Colors.grey
                        .shade500,
                    disabledForegroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),
                  ),
                  child: _buying
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  )
                      : Text(
                    isPremium
                        ? '✓ Premium Active'
                        : _purchasePending
                        ? 'Payment Pending'
                        : '👑 Unlock Premium',
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ),

              if (!isPremium) ...[
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width:
                  double.infinity,
                  height: 48,
                  child:
                  OutlinedButton
                      .icon(
                    onPressed:
                    _restoring
                        ? null
                        : _restorePurchase,
                    icon: _restoring
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color: Colors
                            .white,
                      ),
                    )
                        : const Icon(
                      Icons
                          .restore_rounded,
                    ),
                    label: Text(
                      _restoring
                          ? 'Restoring...'
                          : 'Restore Purchase',
                    ),
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      Colors.white,
                      side:
                      const BorderSide(
                        color: Colors
                            .white54,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Purchases are securely processed by Google Play.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFeatureCard
    extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _PremiumFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
            BoxDecoration(
              color: iconColor
                  .withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color: Color(
                      0xFF062B50,
                    ),
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style:
                  const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}