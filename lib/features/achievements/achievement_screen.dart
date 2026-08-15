import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/premium_banner_ad.dart';
import 'achievement_card.dart';
import 'achievement_provider.dart';

class AchievementScreen
    extends ConsumerWidget {
  const AchievementScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final achievementsAsync =
    ref.watch(
      achievementsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Achievements'),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(),
        ),
        error: (
            error,
            stackTrace,
            ) =>
            Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),
                child: Text(
                  'Unable to load achievements.\n$error',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),
        data: (achievements) {
          final unlockedCount =
              achievements
                  .where(
                    (achievement) =>
                achievement
                    .isUnlocked,
              )
                  .length;

          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primaryContainer,
                    borderRadius:
                    BorderRadius
                        .circular(
                      22,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .workspace_premium_rounded,
                        size: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Your Achievement Collection',
                        textAlign:
                        TextAlign.center,
                        style:
                        TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        '$unlockedCount / ${achievements.length} unlocked',
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount:
                  achievements.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing:
                    14,
                    mainAxisSpacing:
                    14,
                    childAspectRatio:
                    0.88,
                  ),
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    return AchievementCard(
                      achievement:
                      achievements[
                      index
                      ],
                    );
                  },
                ),

                const SizedBox(
                  height: 18,
                ),

                const PremiumBannerAd(),

                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}