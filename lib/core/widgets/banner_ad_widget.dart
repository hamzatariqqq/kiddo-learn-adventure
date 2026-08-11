import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../features/auth/providers/user_provider.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() =>
      _BannerAdWidgetState();
}

class _BannerAdWidgetState
    extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;

  bool _isLoaded = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final banner = AdService.instance.createBannerAd(
      onLoaded: () {
        if (!mounted) return;

        setState(() {
          _isLoaded = true;
          _hasFailed = false;
        });
      },
      onFailed: (error) {
        if (!mounted) return;

        setState(() {
          _isLoaded = false;
          _hasFailed = true;
        });
      },
    );

    _bannerAd = banner;
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) =>
      const SizedBox.shrink(),
      data: (user) {
        final isPremium = user?.isPremium ?? false;

        if (isPremium) {
          _bannerAd?.dispose();
          _bannerAd = null;

          return const SizedBox.shrink();
        }

        final banner = _bannerAd;

        if (_hasFailed || banner == null) {
          return const SizedBox.shrink();
        }

        if (!_isLoaded) {
          return const SizedBox(
            height: 50,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: banner.size.height.toDouble(),
            child: Center(
              child: SizedBox(
                width: banner.size.width.toDouble(),
                height: banner.size.height.toDouble(),
                child: AdWidget(
                  ad: banner,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}