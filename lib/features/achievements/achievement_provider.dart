import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers/user_provider.dart';
import 'achievement_model.dart';
import 'achievement_service.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

final achievementsProvider = FutureProvider<List<AchievementModel>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    return const <AchievementModel>[];
  }

  final service = ref.read(achievementServiceProvider);

  return service.getAchievements(user.badges);
});
