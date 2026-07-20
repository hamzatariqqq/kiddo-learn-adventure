import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import 'daily_reward_provider.dart';
import 'reward_dialog.dart';

class DailyRewardCard extends ConsumerStatefulWidget {
  const DailyRewardCard({super.key});

  @override
  ConsumerState<DailyRewardCard> createState() {
    return _DailyRewardCardState();
  }
}

class _DailyRewardCardState extends ConsumerState<DailyRewardCard> {
  bool _isClaiming = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        ref.invalidate(dailyRewardStatusProvider);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRemaining(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }

  Future<void> _claimReward() async {
    if (_isClaiming) {
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    try {
      final service = ref.read(dailyRewardServiceProvider);
      final claimed = await service.claimReward();

      if (!mounted) {
        return;
      }

      if (claimed) {
        ref.invalidate(dailyRewardStatusProvider);
        await showDailyRewardDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your daily reward is not available yet.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to claim reward: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(dailyRewardStatusProvider);

    return statusAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'Unable to load daily reward.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (status) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.orange.withValues(alpha: 0.30),
                AppColors.yellow.withValues(alpha: 0.25),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎁', style: TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Reward',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.canClaim
                          ? 'Get 100 coins and 20 stars!'
                          : 'Available in ${_formatRemaining(status.remaining)}',
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '🔥 ${status.rewardStreak} day reward streak',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: status.canClaim && !_isClaiming
                    ? _claimReward
                    : null,
                child: _isClaiming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(status.canClaim ? 'Claim' : 'Claimed'),
              ),
            ],
          ),
        );
      },
    );
  }
}
