import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_reward_service.dart';

final dailyRewardServiceProvider = Provider<DailyRewardService>((ref) {
  return DailyRewardService();
});

final dailyRewardStatusProvider = StreamProvider<DailyRewardStatus>((ref) {
  final service = ref.watch(dailyRewardServiceProvider);

  return service.watchRewardStatus();
});
