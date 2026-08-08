import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../services/ad_service.dart';

class RewardedAdButton extends StatefulWidget {
  const RewardedAdButton({
    super.key,
    this.rewardCoins = 100,
  });

  final int rewardCoins;

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isGivingReward = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.loadRewarded();
  }

  Future<void> _giveCoins() async {
    if (_isGivingReward) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please login before claiming this reward.',
        AppColors.coral,
      );
      return;
    }

    setState(() {
      _isGivingReward = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'coins': FieldValue.increment(widget.rewardCoins),
      });

      if (!mounted) return;

      _showMessage(
        '${widget.rewardCoins} bonus coins added!',
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

  void _showAd() {
    if (!AdService.instance.isRewardedReady) {
      AdService.instance.loadRewarded();

      _showMessage(
        'Ad is still loading. Please try again shortly.',
        AppColors.orange,
      );
      return;
    }

    AdService.instance.showRewarded(
      onRewardEarned: _giveCoins,
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGivingReward ? null : _showAd,
        icon: _isGivingReward
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.ondemand_video_rounded),
        label: Text(
          _isGivingReward
              ? 'Adding Coins...'
              : 'Watch Ad & Earn ${widget.rewardCoins} Coins',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}