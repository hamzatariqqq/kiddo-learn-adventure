import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;

  // Keep Google TEST IDs during development.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9214589741';
    }

    return '';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }

    return '';
  }

  /// Call BEFORE MobileAds.instance.initialize().
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
          debugPrint('Banner ad loaded successfully.');
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          debugPrint(
            'Banner ad failed to load: $error',
          );

          onFailed(error);
        },
      ),
    );
  }

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
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _rewardedAd = null;
                  loadRewarded();
                },
                onAdFailedToShowFullScreenContent:
                    (ad, error) {
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

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}