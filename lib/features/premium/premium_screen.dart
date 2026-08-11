import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late final PurchaseService _purchaseService;

  bool _loading = true;
  bool _buying = false;
  bool _restoring = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();

    _purchaseService = PurchaseService(
      onPurchaseUpdated: _onPurchaseUpdated,
    );

    _initializeBilling();
  }

  Future<void> _initializeBilling() async {
    try {
      await _purchaseService.initialize();

      if (!mounted) return;

      setState(() {
        _isPremium = _purchaseService.isPremium;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        'Unable to initialize purchases right now.',
      );
    }
  }

  void _onPurchaseUpdated(
      PurchaseDetails purchase,
      ) {
    if (!mounted) return;

    if (purchase.status == PurchaseStatus.purchased) {
      setState(() {
        _buying = false;
        _restoring = false;
        _isPremium = true;
      });

      _showMessage(
        'Premium activated successfully! 🎉',
      );
      return;
    }

    if (purchase.status == PurchaseStatus.restored) {
      setState(() {
        _buying = false;
        _restoring = false;
        _isPremium = true;
      });

      _showMessage(
        'Premium purchase restored successfully.',
      );
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      setState(() {
        _buying = false;
        _restoring = false;
      });

      _showMessage(
        purchase.error?.message ??
            'Purchase failed. Please try again.',
      );
      return;
    }

    if (purchase.status == PurchaseStatus.canceled) {
      setState(() {
        _buying = false;
        _restoring = false;
      });
    }
  }

  Future<void> _buyPremium() async {
    if (_isPremium || _buying) {
      return;
    }

    if (!_purchaseService.storeAvailable) {
      _showMessage(
        'Google Play Billing is not available.',
      );
      return;
    }

    if (_purchaseService.premiumProduct == null) {
      _showMessage(
        'Premium product is not available yet. Please try again later.',
      );
      return;
    }

    setState(() {
      _buying = true;
    });

    try {
      final started =
      await _purchaseService.buyPremium();

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

    if (!_purchaseService.storeAvailable) {
      _showMessage(
        'Google Play Billing is not available.',
      );
      return;
    }

    setState(() {
      _restoring = true;
    });

    try {
      await _purchaseService.restorePurchases();

      if (!mounted) return;

      // Google Play sends restored purchases through
      // the purchase stream. We do not mark Premium here
      // unless an actual restored purchase is received.
      setState(() {
        _restoring = false;
      });
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProductDetails? product =
        _purchaseService.premiumProduct;

    final String price =
        product?.price ?? 'Loading price...';

    return Scaffold(
      backgroundColor: const Color(0xFF062B50),
      appBar: AppBar(
        title: const Text(
          'Kiddo Premium',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF062B50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD83D),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isPremium) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD83D),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Color(0xFF062B50),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Premium Active',
                        style: TextStyle(
                          color: Color(0xFF062B50),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your Kiddo Premium lifetime access is active.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF062B50),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const _PremiumFeatureCard(
                icon: Icons.block,
                iconColor: Colors.redAccent,
                title: 'Remove Ads',
                subtitle:
                'Enjoy learning without banner or rewarded ads.',
              ),

              const SizedBox(height: 12),

              const _PremiumFeatureCard(
                icon: Icons.lock_open_rounded,
                iconColor: Colors.blue,
                title: 'Premium Learning',
                subtitle:
                'Unlock future premium lessons and activities.',
              ),

              const SizedBox(height: 12),

              const _PremiumFeatureCard(
                icon: Icons.sports_esports_rounded,
                iconColor: Colors.green,
                title: 'Extra Activities',
                subtitle:
                'Get access to future premium games and rewards.',
              ),

              const SizedBox(height: 12),

              const _PremiumFeatureCard(
                icon: Icons.all_inclusive,
                iconColor: Colors.amber,
                title: 'Lifetime Access',
                subtitle:
                'Pay once and keep Premium on this account.',
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kiddo Premium Lifetime',
                      style: TextStyle(
                        color: Color(0xFF062B50),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isPremium
                          ? 'Already purchased'
                          : 'One-time purchase',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _isPremium
                        ? const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      price,
                      style: const TextStyle(
                        color:
                        Color(0xFF062B50),
                        fontSize: 26,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isPremium
                          ? 'Premium is enabled for this account.'
                          : 'Secure payment through Google Play',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  (_isPremium || _buying)
                      ? null
                      : _buyPremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFFFD83D),
                    foregroundColor:
                    const Color(0xFF062B50),
                    disabledBackgroundColor:
                    Colors.green.shade400,
                    disabledForegroundColor:
                    Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                  child: _buying
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isPremium
                        ? '✓ Premium Active'
                        : '👑 Unlock Premium',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (!_isPremium)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _restoring
                        ? null
                        : _restorePurchase,
                    icon: _restoring
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.restore),
                    label: Text(
                      _restoring
                          ? 'Restoring...'
                          : 'Restore Purchase',
                    ),
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white54,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              const Text(
                'Purchases are securely processed by Google Play.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
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

class _PremiumFeatureCard extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
              iconColor.withValues(alpha: 0.12),
              borderRadius:
              BorderRadius.circular(12),
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
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF062B50),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
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