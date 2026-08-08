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

  @override
  void initState() {
    super.initState();

    _purchaseService = PurchaseService(
      onPurchaseUpdated: _onPurchaseUpdated,
    );

    _initializeBilling();
  }

  Future<void> _initializeBilling() async {
    await _purchaseService.initialize();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  void _onPurchaseUpdated(PurchaseDetails purchase) {
    if (!mounted) return;

    if (purchase.status == PurchaseStatus.purchased) {
      setState(() {
        _buying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium activated successfully! 🎉'),
        ),
      );
    }

    if (purchase.status == PurchaseStatus.restored) {
      setState(() {
        _buying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium purchase restored successfully.'),
        ),
      );
    }

    if (purchase.status == PurchaseStatus.error) {
      setState(() {
        _buying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            purchase.error?.message ?? 'Purchase failed. Please try again.',
          ),
        ),
      );
    }

    if (purchase.status == PurchaseStatus.canceled) {
      setState(() {
        _buying = false;
      });
    }
  }

  Future<void> _buyPremium() async {
    if (!_purchaseService.storeAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Play Billing is not available.'),
        ),
      );
      return;
    }

    if (_purchaseService.premiumProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Premium product is not available yet. Please try again later.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _buying = true;
    });

    final bool started = await _purchaseService.buyPremium();

    if (!started && mounted) {
      setState(() {
        _buying = false;
      });
    }
  }

  Future<void> _restorePurchase() async {
    if (!_purchaseService.storeAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Play Billing is not available.'),
        ),
      );
      return;
    }

    await _purchaseService.restorePurchases();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProductDetails? product = _purchaseService.premiumProduct;

    final String price = product?.price ?? 'Loading price...';

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
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
                  borderRadius: BorderRadius.circular(18),
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

                    const Text(
                      'One-time purchase',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF062B50),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Secure payment through Google Play',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                  onPressed: _buying ? null : _buyPremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD83D),
                    foregroundColor: const Color(0xFF062B50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _buying
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    '👑 Unlock Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _restorePurchase,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Purchase'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white54,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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