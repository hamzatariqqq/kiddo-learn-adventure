import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/premium_provider.dart';
import '../services/ad_service.dart';

class PremiumBannerAd extends ConsumerStatefulWidget {
  const PremiumBannerAd({
    super.key,
    this.margin = const EdgeInsets.symmetric(
      vertical: 8,
    ),
  });

  final EdgeInsets margin;

  @override
  ConsumerState<PremiumBannerAd> createState() =>
      _PremiumBannerAdState();
}

class _PremiumBannerAdState
    extends ConsumerState<PremiumBannerAd> {
  BannerAd? _bannerAd;

  bool _isLoaded = false;
  bool _isLoading = false;

  void _loadBanner() {
    if (_isLoading ||
        _isLoaded ||
        _bannerAd != null) {
      return;
    }

    _isLoading = true;

    late final BannerAd ad;

    ad = AdService.instance.createBannerAd(
      onLoaded: () {
        if (!mounted) {
          ad.dispose();
          return;
        }

        setState(() {
          _bannerAd = ad;
          _isLoaded = true;
          _isLoading = false;
        });
      },
      onFailed: (error) {
        if (!mounted) return;

        setState(() {
          _bannerAd = null;
          _isLoaded = false;
          _isLoading = false;
        });
      },
    );

    ad.load();
  }

  void _removeBanner() {
    _bannerAd?.dispose();

    _bannerAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumState =
    ref.watch(premiumProvider);

    if (premiumState.isLoading) {
      return const SizedBox.shrink();
    }

    final isPremium =
        premiumState.value ?? false;

    // Premium users never see ads.
    if (isPremium) {
      if (_bannerAd != null ||
          _isLoaded ||
          _isLoading) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          if (!mounted) return;

          setState(() {
            _removeBanner();
          });
        });
      }

      return const SizedBox.shrink();
    }

    // Free users load the banner.
    if (!_isLoaded &&
        !_isLoading &&
        _bannerAd == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (mounted) {
          _loadBanner();
        }
      });
    }

    final banner = _bannerAd;

    if (!_isLoaded || banner == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(
        ad: banner,
      ),
    );
  }
}