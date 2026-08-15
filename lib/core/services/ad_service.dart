import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  // =====================================================
  // REAL ADMOB IDS
  // =====================================================

  static const String _androidRealBannerId =
      'ca-app-pub-9973042638438490/7461535076';

  static const String _androidRealInterstitialId =
      'ca-app-pub-9973042638438490/8818848771';

  static const String _androidRealRewardedId =
      'ca-app-pub-9973042638438490/8970057861';

  // =====================================================
  // GOOGLE TEST IDS
  // =====================================================

  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/9214589741';

  static const String _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _androidTestRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  // =====================================================
  // ACTIVE IDS
  // =====================================================

  static String get bannerAdUnitId {
    if (!Platform.isAndroid) {
      return '';
    }

    return kReleaseMode
        ? _androidRealBannerId
        : _androidTestBannerId;
  }

  static String get interstitialAdUnitId {
    if (!Platform.isAndroid) {
      return '';
    }

    return kReleaseMode
        ? _androidRealInterstitialId
        : _androidTestInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (!Platform.isAndroid) {
      return '';
    }

    return kReleaseMode
        ? _androidRealRewardedId
        : _androidTestRewardedId;
  }

  // =====================================================
  // CHILD-SAFE CONFIGURATION
  // =====================================================

  Future<void> configureForChildren() async {
    final requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment:
      TagForChildDirectedTreatment.yes,
      maxAdContentRating: MaxAdContentRating.g,
    );

    await MobileAds.instance.updateRequestConfiguration(
      requestConfiguration,
    );

    debugPrint(
      'AdMob child-directed configuration applied.',
    );
  }

  // =====================================================
  // BANNER ADS
  // =====================================================

  BannerAd createBannerAd({
    required VoidCallback onLoaded,
    required void Function(LoadAdError error) onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint(
            'Banner ad loaded successfully.',
          );

          onLoaded();
        },
        onAdFailedToLoad: (
            ad,
            error,
            ) {
          ad.dispose();

          debugPrint(
            'Banner ad failed to load: $error',
          );

          onFailed(error);
        },
      ),
    );
  }

  // =====================================================
  // REWARDED ADS
  // =====================================================

  void loadRewarded() {
    if (_rewardedAd != null) {
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback:
      RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(
            'Rewarded ad loaded successfully.',
          );

          _rewardedAd = ad;

          ad.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  debugPrint(
                    'Rewarded ad shown.',
                  );
                },
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint(
                    'Rewarded ad dismissed.',
                  );

                  ad.dispose();

                  _rewardedAd = null;

                  loadRewarded();
                },
                onAdFailedToShowFullScreenContent: (
                    ad,
                    error,
                    ) {
                  debugPrint(
                    'Rewarded ad failed to show: $error',
                  );

                  ad.dispose();

                  _rewardedAd = null;

                  loadRewarded();
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'Rewarded ad failed to load: $error',
          );

          _rewardedAd = null;
        },
      ),
    );
  }

  bool get isRewardedReady =>
      _rewardedAd != null;

  void showRewarded({
    required VoidCallback onRewardEarned,
  }) {
    final ad = _rewardedAd;

    if (ad == null) {
      debugPrint(
        'Rewarded ad is not ready.',
      );

      loadRewarded();

      return;
    }

    _rewardedAd = null;

    ad.show(
      onUserEarnedReward: (
          ad,
          reward,
          ) {
        debugPrint(
          'Reward earned: '
              '${reward.amount} ${reward.type}',
        );

        onRewardEarned();
      },
    );
  }

  // =====================================================
  // INTERSTITIAL ADS
  // =====================================================

  void loadInterstitial() {
    if (_interstitialAd != null) {
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback:
      InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(
            'Interstitial ad loaded successfully.',
          );

          _interstitialAd = ad;

          ad.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  debugPrint(
                    'Interstitial ad shown.',
                  );
                },
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint(
                    'Interstitial ad dismissed.',
                  );

                  ad.dispose();

                  _interstitialAd = null;

                  loadInterstitial();
                },
                onAdFailedToShowFullScreenContent: (
                    ad,
                    error,
                    ) {
                  debugPrint(
                    'Interstitial ad failed to show: $error',
                  );

                  ad.dispose();

                  _interstitialAd = null;

                  loadInterstitial();
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'Interstitial ad failed to load: $error',
          );

          _interstitialAd = null;
        },
      ),
    );
  }

  bool get isInterstitialReady =>
      _interstitialAd != null;

  void showInterstitial() {
    final ad = _interstitialAd;

    if (ad == null) {
      debugPrint(
        'Interstitial ad is not ready.',
      );

      loadInterstitial();

      return;
    }

    _interstitialAd = null;

    ad.show();
  }

  // =====================================================
  // CLEANUP
  // =====================================================

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;

    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}