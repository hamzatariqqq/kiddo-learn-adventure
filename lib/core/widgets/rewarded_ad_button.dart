import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/app_colors.dart';
import '../providers/premium_provider.dart';
import '../services/ad_service.dart';

class RewardedAdButton
    extends ConsumerStatefulWidget {
  const RewardedAdButton({
    super.key,
    this.rewardCoins = 100,
  });

  final int rewardCoins;

  @override
  ConsumerState<RewardedAdButton>
  createState() =>
      _RewardedAdButtonState();
}

class _RewardedAdButtonState
    extends ConsumerState<RewardedAdButton> {
  bool _isGivingReward = false;
  bool _isShowingAd = false;

  static const String _guestCoinsKey =
      'guest_coins';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _prepareRewardedAd();
    });
  }

  void _prepareRewardedAd() {
    final isPremium =
        ref.read(premiumProvider).value ??
            false;

    if (isPremium) {
      return;
    }

    AdService.instance.loadRewarded();
  }

  // =====================================================
  // GIVE REWARD
  // =====================================================

  Future<void> _giveCoins() async {
    if (_isGivingReward) {
      return;
    }

    setState(() {
      _isGivingReward = true;
    });

    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        // =============================
        // GUEST REWARD
        // =============================

        await _giveGuestCoins();
      } else {
        // =============================
        // FIREBASE ACCOUNT REWARD
        // =============================

        await _giveFirebaseCoins(
          user.uid,
        );
      }

      if (!mounted) return;

      _showMessage(
        '🪙 ${widget.rewardCoins} bonus coins added!',
        AppColors.green,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to add coins. Please try again.',
        AppColors.coral,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGivingReward = false;
        });
      }
    }
  }

  // =====================================================
  // FIREBASE COINS
  // =====================================================

  Future<void> _giveFirebaseCoins(
      String userId,
      ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(
      {
        'coins': FieldValue.increment(
          widget.rewardCoins,
        ),
        'lastRewardedAdAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // =====================================================
  // GUEST COINS
  // =====================================================

  Future<void> _giveGuestCoins() async {
    final prefs =
    await SharedPreferences.getInstance();

    final currentCoins =
        prefs.getInt(_guestCoinsKey) ?? 0;

    await prefs.setInt(
      _guestCoinsKey,
      currentCoins + widget.rewardCoins,
    );
  }

  // =====================================================
  // SHOW AD
  // =====================================================

  void _showAd() {
    if (_isShowingAd ||
        _isGivingReward) {
      return;
    }

    final isPremium =
        ref.read(premiumProvider).value ??
            false;

    if (isPremium) {
      return;
    }

    if (!AdService
        .instance.isRewardedReady) {
      AdService.instance.loadRewarded();

      _showMessage(
        'Ad is still loading. Please try again shortly.',
        AppColors.orange,
      );

      return;
    }

    setState(() {
      _isShowingAd = true;
    });

    AdService.instance.showRewarded(
      onRewardEarned: () async {
        if (mounted) {
          setState(() {
            _isShowingAd = false;
          });
        }

        await _giveCoins();
      },
    );

    // Safety reset in case the ad closes
    // without earning a reward.
    Future<void>.delayed(
      const Duration(seconds: 2),
          () {
        if (!mounted) return;

        if (!_isGivingReward) {
          setState(() {
            _isShowingAd = false;
          });
        }
      },
    );
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  void _showMessage(
      String message,
      Color color,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final premiumState =
    ref.watch(premiumProvider);

    if (premiumState.isLoading) {
      return const SizedBox.shrink();
    }

    final isPremium =
        premiumState.value ?? false;

    // Premium users never see rewarded ads.
    if (isPremium) {
      return const SizedBox.shrink();
    }

    final isBusy =
        _isGivingReward ||
            _isShowingAd;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
        isBusy ? null : _showAd,
        icon: isBusy
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.ondemand_video_rounded,
        ),
        label: Text(
          _isGivingReward
              ? 'Adding Coins...'
              : _isShowingAd
              ? 'Opening Ad...'
              : 'Watch Ad & Earn ${widget.rewardCoins} Coins',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          AppColors.primaryBlue,
          foregroundColor:
          Colors.white,
          disabledBackgroundColor:
          AppColors.primaryBlue
              .withValues(
            alpha: 0.55,
          ),
          disabledForegroundColor:
          Colors.white,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}